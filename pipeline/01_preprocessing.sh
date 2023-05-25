# PREPARE CLEAN DATA

cd 1.rawdata/${sampleid}
parallel gunzip {} ::: *gz
cd -

kneaddata \
    --input1 rawdata/${sampleid}_1.fq \
    --input1 rawdata/${sampleid}_1.fq \
    -db ${REF_DATABASE} \
    --trimmomatic-options 'ILLUMINACLIP:adapters_path:2:30:10 SLIDINGWINDOW:4:20 MINLEN:50' \
    --bowtie2-options '--very-sensitive' \
    --output trimcleandata/${sampleid}

cp trimcleandata/${sampleid}/${sampleid}{1..2}.fastq \
    cleandata/${sampleid}/

mv cleandata/${sampleid}1.fastq cleandata/${sampleid}_1.fastq
mv cleandata/${sampleid}2.fastq cleandata/${sampleid}_2.fastq
