import numpy as np
import os

len_combined_fa = 10000
n_slice = 20

index = np.linspace(1, len_combined_fa + 1, n_slice, dtype=int)
start = index[:-1]
end = index[1:] - 1

for i, (a, b) in enumerate(zip(start, end)):
    cmd = f"seqkit range -r {a}:{b} meta320_all_mags.fa > {i+1}.fa"
    print(cmd)
    # os.system(cmd)
