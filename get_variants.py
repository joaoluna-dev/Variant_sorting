import pandas as pd
import sys

print("[1/4] Carregando arquivo TSV: " + sys.argv[1])
tsv_file = sys.argv[1]
txt_file = sys.argv[2]

df = pd.read_table(tsv_file, sep="\t")
print(f"  -> Total de variantes carregadas: {len(df)}")

print("[2/4] Filtrando variantes por significado clínico...")
pathogenic = df[df['CLNSIG'] == "Pathogenic"].sample(n=5)
print(f"  -> Patogênicas: {len(pathogenic)}")
likely_pathogenic = df[df['CLNSIG'] == "Likely_pathogenic"].sample(n=3)
print(f"  -> Provavelmente patogênicas: {len(likely_pathogenic)}")
uncertain = df[df['CLNSIG'] == "Uncertain_significance"].sample(n=2)
print(f"  -> Significado incerto: {len(uncertain)}")

print("[3/4] Combinando variantes selecionadas...")
selected = pd.concat([pathogenic, likely_pathogenic, uncertain])
print(f"  -> Total de variantes selecionadas: {len(selected)}")

print("[4/4] Gravando arquivo de saída: " + txt_file)
with open(txt_file, 'w') as f:
    for _, row in selected.iterrows():
        f.write('\t'.join(map(str, row.values)) + '\n')

print("=== Seleção concluída com sucesso! ===")



