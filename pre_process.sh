#!/bin/bash

set -euo pipefail

arquivo=$1
genoma_de_ref=$2
chrom_38="chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22,chrX,chrY,chrM"
filter_param='ILEN>51 | ILEN<-51 | ALT~"R" | ALT~"Y" | ALT~"M" | ALT~"K" | ALT~"S" | ALT~"W" | ALT~"H" | ALT~"B" | ALT~"V" | ALT~"D" | ALT~"N" | ALT~"*"'
query_param='%CHROM\t%POS\t%END\t%REF\t%ALT\t%AF_ESP\t%AF_EXAC\t%AF_TGP\t%ALLELEID\t%CLNDN\t%CLNDNINCL\t%CLNDISDB\t%CLNDISDBINCL\t%CLNHGVS\t%CLNREVSTAT\t%CLNSIG\t%CLNSIGCONF\t%CLNSIGINCL\t%CLNVC\t%CLNVCSO\t%CLNVI\t%DBVARID\t%GENEINFO\t%MC\t%ORIGIN\t%RS\n'

#verificando o numero de variantes antes do pré-processamento
echo "[1/9] Verificando variantes no VCF de entrada..."
bcftools stats "$arquivo" > /dev/null 2>&1
echo "  -> Total de registros no VCF: $(bcftools stats "$arquivo" 2>/dev/null | grep 'number of records' | awk '{print $NF}')"

#verificando o genoma de referencia
if [ ! -e "$genoma_de_ref" ]; then
    echo "Genoma de referência não existe."
    exit 1
fi

echo "  -> Genoma de referência identificado: $(basename "$genoma_de_ref")"

#verifica se o arquivo .fai existe, caso não, ele é criado automaticamente
echo "[2/9] Verificando índice do genoma de referência..."
if [ ! -f "${genoma_de_ref}.fai" ]; then
    echo "  -> Índice .fai não encontrado. Gerando índice com samtools..."
    samtools faidx "$genoma_de_ref"
    echo "  -> Índice criado com sucesso!"
else
    echo "  -> Índice .fai encontrado."
fi

#indexando o VCF se necessário
echo "[3/9] Verificando índice do VCF..."
if [ ! -f "${arquivo}.csi" ] && [ ! -f "${arquivo}.tbi" ]; then
    echo "  -> Indexando VCF com bcftools..."
    bcftools index "$arquivo"
    echo "  -> Índice criado com sucesso!"
else
    echo "  -> Índice do VCF encontrado."
fi

#criar arquivo de mapeamento de cromossomos (formato 'chr')
echo -e "1\tchr1\n2\tchr2\n3\tchr3\n4\tchr4\n5\tchr5\n6\tchr6\n7\tchr7\n8\tchr8\n9\tchr9\n10\tchr10\n11\tchr11\n12\tchr12\n13\tchr13\n14\tchr14\n15\tchr15\n16\tchr16\n17\tchr17\n18\tchr18\n19\tchr19\n20\tchr20\n21\tchr21\n22\tchr22\nX\tchrX\nY\tchrY\nMT\tchrM" > "${HOME}/chrom_map.txt"

#renomear cromossomos para formato "chr" (Vcf usa 1,2, genoma usa chr1,chr2)
echo "[4/9] Renomeando cromossomos para formato 'chr'..."
bcftools annotate --rename-chrs "${HOME}/chrom_map.txt" -O z -o {"$arquivo"}.chr.vcf.gz "$arquivo"
echo "  -> Cromossomos renomeados: $(basename "$arquivo").chr.vcf.gz"

#removendo cromossomos inválidos para o GRCh38
echo "[5/9] Filtrando cromossomos válidos (GRCh38)..."
bcftools view -r "$chrom_38"  -O z -o {"$arquivo"}.exChr.vcf.gz {"$arquivo"}.chr.vcf.gz
echo "  -> Arquivo filtrado: $(basename "$arquivo").exChr.vcf.gz"

#realizando a normalizacao
echo "[6/9] Normalizando variantes (left-align e decomposição)..."
bcftools norm \
  -m -any \
  -O z \
  -cs \
  -f "$genoma_de_ref" \
  -o {"$arquivo"}.norm1.vcf.gz \
  {"$arquivo"}.exChr.vcf.gz
echo "  -> Normalização concluída: $(basename "$arquivo").norm1.vcf.gz"

#removendo variantes duplicadas
echo "[7/9] Removendo variantes duplicadas..."
bcftools norm \
  --no-version \
  -d none \
  -O z \
  -o {"$arquivo"}.norm2.vcf.gz \
  {"$arquivo"}.norm1.vcf.gz
echo "  -> Duplicatas removidas: $(basename "$arquivo").norm2.vcf.gz"

#filtrando variantes sem alelo alternativo, sem alelos de referencia e com mais de 50 pares de base
echo "[8/9] Aplicando filtros de qualidade..."
bcftools view \
  --no-version \
  --type snps,indels \
  -e "$filter_param" \
  -O z -o {"$arquivo"}.norm3.vcf.gz \
  {"$arquivo"}.norm2.vcf.gz
echo "  -> Filtros aplicados: $(basename "$arquivo").norm3.vcf.gz"

#criando arquivo TSV a partir do VCF
echo "[9/9] Convertendo para formato TSV..."
bcftools query -f "$query_param" {"$arquivo"}.norm3.vcf.gz > {"$arquivo"}.norm.tsv

sed -e 's/%3D/=/g' -i {"$arquivo"}.norm.tsv

echo "  -> Arquivo TSV gerado: $(basename "$arquivo").norm.tsv"
echo ""
echo "=== Pipeline concluído com sucesso! ==="
