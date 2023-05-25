import pandas as pd
import os
import re


magsfile = "/path/to/all/MAGS_TABLE.tsv"
allcazydir = "/path/to/all/cazy_pul/results"
outdir = "/CAZY_TABLE/"

# pivot = "DIAMOND"
# pivot = "dbCAN_sub"
pivot = "HMMER"

allcazydf = []
for sample in os.listdir(allcazydir):
    if not sample.startswith("outdir"):
        continue
    cazyoverview = os.path.join(allcazydir, sample, "overview.txt")
    if not os.path.exists(cazyoverview):
        print(cazyoverview, "not exists")
        continue
    df = pd.read_csv(cazyoverview, sep="\t")

    stats = []
    for i in df[pivot]:
        if i.startswith("-"):
            continue
        i=re.sub('\(.*?\)','',i)
        stats.extend(i.split("+"))
    df = pd.DataFrame({pivot:stats}).value_counts().reset_index()
    df['Bin id'] = sample.lstrip("outdir_")
    allcazydf.append(df)

print("allcazydf len: ", len(allcazydf))
allcazydf = pd.concat(allcazydf)
allcazydf.rename(columns={0: "values"}, inplace=True)

allcazydf = allcazydf.pivot_table(index="Bin id", columns=pivot, values="values").reset_index()
allcazydf = allcazydf.fillna(0).convert_dtypes()

allpuldf = []
pulsdir = "/path/to/puls/result"
for pulsample in os.listdir(pulsdir):
    if not 'sum' in pulsample:
        continue
    if os.path.getsize(os.path.join(pulsdir, pulsample)) == 0:
        continue
    df = pd.read_csv(os.path.join(pulsdir, pulsample), sep="\t")
    df = df[['pulid', 'pattern']]
    df['Bin id'] = pulsample.rstrip(".pulls.sum.tsv")
    allpuldf.append(df)

pulcountdf = pd.DataFrame([(df['Bin id'][0], df.shape[0]) for df in allpuldf],
                          columns=("Bin id", "pulcount"))
allpuldf = pd.concat(allpuldf)
allpuldf = allpuldf.pivot(index="Bin id", columns="pulid", values="pattern").reset_index()
pulcolumns = ['Bin id'] + [f"PUL{i}" for i in range(1, allpuldf.shape[1]) ]
allpuldf = allpuldf[pulcolumns]
allpuldf.to_csv(os.path.join(outdir, f"CAZY_PUL_TABLE.csv"), index=False)


allcazydf = pd.merge(allcazydf, pulcountdf, how='left')
allcazydf['pulcount'] = allcazydf['pulcount'].fillna(0).convert_dtypes()


magsdf = pd.read_csv(magsfile, sep="\t")
taxdf = magsdf['classification'].str.split(";", expand=True)
taxdf.rename(columns={0: "Domain",
                      1: "Phylum",
                      2: "Class",
                      3: "Order",
                      4: "Family",
                      5: "Genus",
                      6: "Species"  }, inplace=True)
magsdf = magsdf[["user_genome", "Genome name", "Bin id"]]
magsdf = pd.concat([magsdf, taxdf], axis=1)
outdf = pd.merge(magsdf, allcazydf, how='left')
outdf.fillna(0, inplace=True)

outdf.to_csv(os.path.join(outdir, f"CAZY_{pivot}.csv"), index=False)
