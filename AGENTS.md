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
