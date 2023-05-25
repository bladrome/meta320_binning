# Taxonomic classification and phylogenetic analysis

mkdir ../Taxonomy/gtdbtk

gtdbtk classify_wf \
    --cpus 90 \
    --out_dir ../Taxonomy/gtdbtk \
    --genome_dir ../dRep/dRep99/dereplicated_genomes \
    --extension fa

ls ../Taxonomy/gtdbtk/*.tree | parallel echo \
    'gtdbtk convert_to_itol \
    --input_tree {} \
    --output_tree {.}_itol.tree '
