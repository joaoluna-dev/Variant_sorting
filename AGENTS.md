# Variant Selection Pipeline

## Scripts

### pre_process.sh
VCF preprocessing pipeline using bcftools/samtools.
```bash
./pre_process.sh <input.vcf.gz> <reference_genome.fa.gz>
```
Requirements: bcftools, samtools. Produces filtered `.norm.tsv` output.

### get_variants.py
Filters TSV by clinical significance (Pathogenic, Likely_pathogenic, Uncertain_significance).
```bash
python get_variants.py <input.tsv> <output.txt>
```

## Environment
- Python via conda (`settings.json` configured)
- Bioinformatics tools: bcftools, samtools must be in PATH

## Pré-requisitos do genoma de referência
- Deve estar no formato **chr** (chr1, chr2, chrX...)
- Deve ter índice `.fai` criado com `samtools faidx`
- Exemplo: `hg38.fa` + `hg38.fa.fai`

## Fluxo do pipeline
1. `pre_process.sh` - Pré-processa VCF → TSV
2. `get_variants.py` - Seleciona variantes por classificação clínica

## Observações importantes
- O VCF do ClinVar usa cromossomos sem "chr" (1,2,3...)
- O script faz renomeação automática: 1→chr1, 2→chr2, X→chrX, etc.
- O TSV gerado **não tem header** - usar índice de coluna (15 = CLNSIG)
- O arquivo de saída é `.norm.tsv`

## Estrutura do TSV de saída (colunas)
0: CHROM, 1: POS, 2: END, 3: REF, 4: ALT,
5: AF_ESP, 6: AF_EXAC, 7: AF_TGP, 8: ALLELEID,
9: CLNDN, 10: CLNDNINCL, 11: CLNDISDB, 12: CLNDISDBINCL,
13: CLNHGVS, 14: CLNREVSTAT, **15: CLNSIG** (classificação clínica),
16: CLNSIGCONF, 17: CLNSIGINCL, 18: CLNVC, 19: CLNVCSO,
20: CLNVI, 21: DBVARID, 22: GENEINFO, 23: MC, 24: ORIGIN, 25: RS