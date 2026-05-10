import pandas as pd
import sys

tsv_file = sys.argv[1]
txt_file = sys.argv[2]

df = pd.read_table(tsv_file, sep="\t")

pathogenic = df[df['CLNSIG'] == "Pathogenic"].sample(n=5)
likely_pathogenic = df[df['CLNSIG'] == "Likely_pathogenic"].sample(n=3)
uncertain = df[df['CLNSIG'] == "Uncertain_significance"].sample(n=2)

selected = pd.concat([pathogenic, likely_pathogenic, uncertain])

with open(txt_file, 'w') as f:
    for _, row in selected.iterrows():
        f.write('\t'.join(map(str, row.values)) + '\n')



