# MAG abundance

metawrap quant_bins \
    -t 90 \
    -b ../dRep/dRep99/dereplicated_genomes \
    -o ../MAGs_quant_noassemble \
    ../cleandata/*/*.fastq
    # -a assembly/all_contigs.fa

emapper.py  \
    -i ../combined_${slice}.fa \
    --itype genome \
    -m mmseqs \
    --cpu 250 \
    --data_dir /your/path/to/eggnog/databank \
    --dbmem \
    --output_dir output_${slice} \
    -o ${slice}.log > output_${slice}/${slice}.log 2 >& 1

run_dbcan \
    ${sample_mag}.fa meta \
    --dia_cpu 64 \
    --hmm_cpu 64 \
    --out_dir ${sample_mag}_ourdir
    --db_dir db \
    --tools all \
    --use_signalP 1 \
    --dbcan_thread 64 \
    --tf_cpu 64 \
    --stp_cpu 64 \
    --pul db/PUL.faa \
    --out ${sample_mag}_ourdir/pulresults.txt
