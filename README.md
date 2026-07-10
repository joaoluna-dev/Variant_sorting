# Variant Selection Pipeline

Pipeline de pré-processamento e seleção de variantes genômicas a partir de arquivos VCF do ClinVar. Composto por duas etapas: (1) normalização/filtragem com `bcftools`/`samtools` e (2) seleção por significado clínico com `pandas`.

## Visão Geral

O pipeline processa VCFs do ClinVar (cromossomos sem prefixo "chr") e produz um arquivo TSV filtrado e normalizado. Na segunda etapa, as variantes são selecionadas de acordo com sua classificação clínica (Patogênica, Provavelmente Patogênica, Significado Incerto), gerando um subconjunto para análise.

```
input.vcf.gz  ──►  pre_process.sh  ──►  input.norm.tsv  ──►  get_variants.py  ──►  output.txt
```

## Pré-requisitos

- **bcftools** (≥ 1.9)
- **samtools** (≥ 1.9)
- **Python 3** com pandas
- Genoma de referência **GRCh38** no formato `chr` (chr1, chr2, chrX...) com índice `.fai`

### Verificação das ferramentas

```bash
bcftools --version
samtools --version
python --version
```

## Instalação

```bash
git clone https://github.com/anomalyco/variant-selection.git
cd variant-selection
pip install pandas
```

O ambiente conda (opcional) pode ser ativado conforme configurado em `.vscode/settings.json`.

## Uso

### 1. Pré-processamento do VCF

```bash
./pre_process.sh <input.vcf.gz> <referencia.fa.gz>
```

Exemplo:

```bash
./pre_process.sh clinvar.vcf.gz hg38.fa.gz
```

Saída: `clinvar.vcf.gz.norm.tsv`

### 2. Seleção por significado clínico

```bash
python get_variants.py <input.tsv> <output.txt>
```

Exemplo:

```bash
python get_variants.py clinvar.vcf.gz.norm.tsv variantes_selecionadas.txt
```

Seleciona:
- **5** variantes Patogênicas
- **3** Provavelmente Patogênicas
- **2** de Significado Incerto

### Fluxo completo

```bash
./pre_process.sh clinvar.vcf.gz hg38.fa.gz
python get_variants.py clinvar.vcf.gz.norm.tsv variantes_selecionadas.txt
```

## Etapas do pre_process.sh

| Etapa | Descrição |
|---|---|
| 1 | Verifica o VCF de entrada |
| 2 | Gera índice `.fai` do genoma de referência (se ausente) |
| 3 | Indexa o VCF (`.csi`/`.tbi`) |
| 4 | Renomeia cromossomos: `1→chr1`, `X→chrX`, etc. |
| 5 | Filtra apenas cromossomos válidos do GRCh38 |
| 6 | Normaliza variantes (left-align + decomposição multialélica) |
| 7 | Remove duplicatas |
| 8 | Remove variantes >50bp, IUPAC ambiguity e alelos nulos |
| 9 | Converte VCF → TSV com campos ClinVar |

## Estrutura do TSV (sem header)

| Coluna | Campo | Descrição |
|---|---|---|
| 0 | CHROM | Cromossomo |
| 1 | POS | Posição inicial |
| 2 | END | Posição final |
| 3 | REF | Alelo de referência |
| 4 | ALT | Alelo alternativo |
| 5 | AF_ESP | Frequência alélica (ESP) |
| 6 | AF_EXAC | Frequência alélica (ExAC) |
| 7 | AF_TGP | Frequência alélica (1000 Genomes) |
| 8 | ALLELEID | ID do alelo ClinVar |
| 9 | CLNDN | Nome da doença |
| 10 | CLNDNINCL | Doenças incluídas |
| 11 | CLNDISDB | Banco de dados da doença |
| 12 | CLNDISDBINCL | Bancos de dados incluídos |
| 13 | CLNHGVS | HGVS do alelo |
| 14 | CLNREVSTAT | Status de revisão |
| **15** | **CLNSIG** | **Significado clínico** |
| 16 | CLNSIGCONF | Conflitos de significado |
| 17 | CLNSIGINCL | Significados incluídos |
| 18 | CLNVC | Tipo de variante ClinVar |
| 19 | CLNVCSO | SO do tipo de variante |
| 20 | CLNVI | ID de submissão |
| 21 | DBVARID | ID dbVar |
| 22 | GENEINFO | Informação do gene |
| 23 | MC | Código de significado |
| 24 | ORIGIN | Origem da variante |
| 25 | RS | ID dbSNP (rs) |

## Feedback

Reporte bugs ou sugira melhorias em [github.com/anomalyco/variant-selection/issues](https://github.com/anomalyco/variant-selection/issues).

## Contribuições

Contribuições são bem-vindas! Faça um fork do repositório, crie um branch para sua feature, e abra um Pull Request.
