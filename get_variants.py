import pandas as pd
import sys

if len(sys.argv) != 3:
    print("Erro: Uso: python get_variants.py <input.tsv> <output.txt>")
    sys.exit(1)

print("[1/4] Carregando arquivo TSV: " + sys.argv[1])
tsv_file = sys.argv[1]
txt_file = sys.argv[2]

df = pd.read_table(tsv_file, sep="\t")
print(f"  -> Total de variantes carregadas: {len(df)}")

df['CLNSIG'] = df['CLNSIG'].fillna('Unknown')

print("[2/4] Filtrando variantes por significado clínico...")

pathogenic_df = df[df['CLNSIG'] == "Pathogenic"]
pathogenic = pathogenic_df.sample(n=min(5, len(pathogenic_df))) if len(pathogenic_df) > 0 else pd.DataFrame()
print(f"  -> Patogênicas: {len(pathogenic)}")

likely_pathogenic_df = df[df['CLNSIG'] == "Likely_pathogenic"]
likely_pathogenic = likely_pathogenic_df.sample(n=min(3, len(likely_pathogenic_df))) if len(likely_pathogenic_df) > 0 else pd.DataFrame()
print(f"  -> Provavelmente patogênicas: {len(likely_pathogenic)}")

uncertain_df = df[df['CLNSIG'] == "Uncertain_significance"]
uncertain = uncertain_df.sample(n=min(2, len(uncertain_df))) if len(uncertain_df) > 0 else pd.DataFrame()
print(f"  -> Significado incerto: {len(uncertain)}")

print("[3/4] Combinando variantes selecionadas...")
selected = pd.concat([pathogenic, likely_pathogenic, uncertain])
print(f"  -> Total de variantes selecionadas: {len(selected)}")

if len(selected) == 0:
    print("AVISO: Nenhuma variante encontrada com os critérios selecionados!")
    sys.exit(0)

print("[4/4] Gravando arquivo de saída: " + txt_file)
selected.to_csv(txt_file, sep='\t', index=False, header=True)

print("=== Seleção concluída com sucesso! ===")