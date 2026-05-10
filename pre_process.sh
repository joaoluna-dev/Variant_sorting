#!/bin/bash

set -euo pipefail

arquivo=$1
genoma_de_ref=$2
chrom_38="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,X,Y,MT"
filter_param='ILEN>51 | ILEN<-51 | ALT~"R" | ALT~"Y" | ALT~"M" | ALT~"K" | ALT~"S" | ALT~"W" | ALT~"H" | ALT~"B" | ALT~"V" | ALT~"D" | ALT~"N" | ALT~"*"'
query_param='%CHROM\t%POS\t%END\t%REF\t%ALT\t%AF_ESP\t%AF_EXAC\t%AF_TGP\t%ALLELEID\t%CLNDN\t%CLNDNINCL\t%CLNDISDB\t%CLNDISDBINCL\t%CLNHGVS\t%CLNREVSTAT\t%CLNSIG\t%CLNSIGCONF\t%CLNSIGINCL\t%CLNVC\t%CLNVCSO\t%CLNVI\t%DBVARID\t%GENEINFO\t%MC\t%ORIGIN\t%RS\n'

#verificando o numero de variantes antes do pré-processamento
bcftools stats "$arquivo"

#verificando o genoma de referencia
if [ ! -e "$genoma_de_ref" ]; then
    echo "Genoma de referência não existe."
    exit 1
fi

echo "  -> Genoma de referência identificado: $(basename "$genoma_de_ref")"

#verifica se o arquivo .fai existe, caso não, ele é criado automaticamente
if [ ! -f "${genoma_de_ref}.fai" ]; then
    echo "  -> Índice .fai não encontrado. Gerando índice com samtools..."
    samtools faidx "$genoma_de_ref"
    echo "  -> Índice criado com sucesso!"
fi

#indexando o VCF se necessário
if [ ! -f "${arquivo}.csi" ] && [ ! -f "${arquivo}.tbi" ]; then
    echo "  -> Indexando VCF com bcftools..."
    bcftools index "$arquivo"
    echo "  -> Índice criado com sucesso!"
fi

#removendo cromossomos inválidos para o GRCh38
bcftools view -r "$chrom_38"  -O z -o {"$arquivo"}.exChr.vcf.gz "$arquivo"

#realizando a normalizacao
bcftools norm \
  -m -any \
  -O z \
  -cs \
  -f "$genoma_de_ref" \
  -o {"$arquivo"}.norm1.vcf.gz \
  {"$arquivo"}.exChr.vcf.gz


#removendo variantes duplicadas
bcftools norm \
  --no-version \
  -d none \
  -O z \
  -o {"$arquivo"}.norm2.vcf.gz \
  {"$arquivo"}.norm1.vcf.gz

#filtrando variantes sem alelo alternativo, sem alelos de referencia e com mais de 50 pares de base
bcftools view \
  --no-version \
  --type snps,indels \
  -e "$filter_param" \
  -O z -o {"$arquivo"}.norm3.vcf.gz \
  {"$arquivo"}.norm2.vcf.gz

#criando arquivo TSV a partir do VCF

bcftools query -f "$query_param" {"$arquivo"}.norm3.vcf.gz > {"$arquivo"}.norm.tsv

sed -e 's/%3D/=/g' -i {"$arquivo"}.norm.tsv
