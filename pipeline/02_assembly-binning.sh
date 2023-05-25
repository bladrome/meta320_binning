# SAMPLE ASSEMBLY

metawrap assembly -t $cpu -m $mem \
    -1 ../cleandata/$sampleid/${sampleid}_1.fastq \
    -2 ../cleandata/$sampleid/${sampleid}_2.fastq \
    -o ../assembly/${sampleid} \
    -l 500

# BINNING


sampleassembly=`echo ${sampleid%%_*} | awk -F '-' '{print $1 $2}'`
metawrap binning -t $cpu -m $mem \
    -a ../assembly/Goat_110sample/${sampleassembly}.final.contigs.fa \
    -o ../binning/${sampleid} \
    -l 500 \
    --universal \
    --metabat2 \
    --maxbin2 \
    --interleaved \
    ../cleandata/$sampleid/${sampleid}_1.fastq \
    ../cleandata/$sampleid/${sampleid}_2.fastq

# BIN_REFINEMENT

mkdir ../bin_refinement/${sampleid}
metawrap bin_refinement -t $cpu -m $mem \
    -o ../bin_refinement/${sampleid} \
    -A ../binning/${sampleid}/metabat2_bins/ \
    -B ../binning/${sampleid}/maxbin2_bins/ \
    -c 50 -x 10 \
    --quick

# BIN_REASSEMBLY

mkdir ../bin_reassembly/${sampleid}
metawrap reassemble_bins -t $cpu -m $mem \
    -o ../bin_reassembly/${sampleid} \
    -1 ../cleandata/$sampleid/${sampleid}_1.fastq \
    -2 ../cleandata/$sampleid/${sampleid}_2.fastq \
    -c 50 \
    -x 10 \
    -b ../bin_refinement/${sampleid}/metawrap_50_10_bins

# collect all bins

mkdir ../MAGs/

if [ -d ../bin_reassembly/${sampleid}/reassembled_bins/reassembled_best_bins  ]
then
    binsdir=../bin_reassembly/${sampleid}/reassembled_bins/reassembled_best_bins
else
    binsdir=../bin_reassembly/${sampleid}/reassembled_bins/
fi
for bin in $binsdir/*.fa
do
    # echo ${sampleid} ${bin##*/}
    cp $bin ../MAGs/${sampleid}_${bin##*/}
done

# MAG de-replicate

mkdir ../dRep/dRep99

dRep dereplicate ../dRep/dRep99 \
    -g ../MAGs/*.fa \
    -p 30 \
    -d -comp 50 \
    -con 5 \
    -nc 0.25 \
    -pa 0.9 \
    -sa 0.99
