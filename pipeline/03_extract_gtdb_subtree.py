import pandas as pd
from ete3 import PhyloTree

t = PhyloTree("gtdbtk.bac120.classify.tree", format=1, quoted_node_names=True)

uniq92df = pd.read_csv("uniq_92_Genome_name.csv")
uniq92df = uniq92df[['user_genome', 'Genome name']]
uniq92mags = uniq92df['user_genome']

genomeName = {}
for i, user_genome, genomename in uniq92df.itertuples():
    genomeName[user_genome] = genomename

t.prune(uniq92mags, preserve_branch_length=True)

for i, node in enumerate(t):
    node.name = genomeName[node.name]

t.write(outfile="uniq92mags.tree")
