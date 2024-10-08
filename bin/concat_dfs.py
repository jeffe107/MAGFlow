#!/usr/bin/env python3

import sys
import pandas as pd
import os.path

files = sys.argv[1]
sample = sys.argv[2]
outdir = sys.argv[3]
data = sys.argv[4]

# Get a list of all files in the directory
bins = os.listdir(data)

# Extract filenames without extensions
bin_names = [os.path.splitext(bin)[0] for bin in bins]

# Create a DataFrame with the file names
df_bins = pd.DataFrame(bin_names, columns=["Bin"])
df_bins["Bin"] = df_bins["Bin"].astype(str)

#Creating BUSCO df
path_busco = f"{files}/busco/batch_summary.txt"
if  os.path.isfile(path_busco):
     df_busco = pd.read_csv(path_busco, sep='\t')
     df_busco['Input_file'] = df_busco['Input_file'].apply(lambda x: x.split('.')[0])
     df_busco["Input_file"] = df_busco["Input_file"].astype(str)
else:
     df_busco = pd.DataFrame({'Input_file': ['empty_df']})

#Creating CheckM2 df
path_checkm2 = f"{files}/checkm2/quality_report.tsv"
if  os.path.isfile(path_checkm2):
     df_checkm2 = pd.read_csv(path_checkm2, sep='\t')
     df_checkm2["Name"] = df_checkm2["Name"].astype(str)
else:
     df_checkm2 = pd.DataFrame({'Name': ['empty_df']})

#Creating GUNC df
path_gunc = f"{files}/gunc/GUNC.progenomes_2.1.maxCSS_level.tsv"
if os.path.isfile(path_gunc):
    df_gunc = pd.read_csv(path_gunc, sep='\t')
    df_gunc["genome"] = df_gunc["genome"].astype(str)
else:
    df_gunc = pd.DataFrame({'genome': ['empty_df']})

#Creating and concatenating GTDB-Tk2 dfs
df_gtdbtk2 = pd.DataFrame()
path_gtdbtk2_bac = f"{files}/gtdbtk2/gtdbtk.bac120.summary.tsv"
if os.path.isfile(path_gtdbtk2_bac):
    df_gtdbtk2_bac = pd.read_csv(path_gtdbtk2_bac, sep='\t')
    df_gtdbtk2_bac["user_genome"] = df_gtdbtk2_bac["user_genome"].astype(str)
    df_gtdbtk2 = pd.concat([df_gtdbtk2, df_gtdbtk2_bac], axis=0, ignore_index=True)

path_gtdbtk2_ar = f"{files}/gtdbtk2/gtdbtk.ar53.summary.tsv"
if os.path.isfile(path_gtdbtk2_ar):
    df_gtdbtk2_ar = pd.read_csv(path_gtdbtk2_ar, sep='\t')
    df_gtdbtk2_ar["user_genome"] = df_gtdbtk2_ar["user_genome"].astype(str)
    df_gtdbtk2 = pd.concat([df_gtdbtk2, df_gtdbtk2_ar], axis=0, ignore_index=True)

if len(df_gtdbtk2) == 0:
	df_gtdbtk2 = pd.DataFrame({'user_genome': ['empty_df']})

#Creating QUAST df
path_quast = f"{files}/quast/transposed_report.tsv"
if  os.path.isfile(path_quast):
     df_quast = pd.read_csv(path_quast, sep='\t')
     df_quast["Assembly"] = df_quast["Assembly"].astype(str)
else:
     df_quast = pd.DataFrame({'Assembly': ['empty_df']})

#Merging dfs
df_list = [df_busco, df_checkm2, df_gtdbtk2, df_gunc, df_quast]
column_names = ['Input_file','Name', 'user_genome', 'genome', 'Assembly']
for i in range(len(df_list)):
    df_bins = pd.merge(df_bins, df_list[i], left_on='Bin', right_on=column_names[i], how='left')

df_bins = df_bins.drop(columns=column_names)
df_bins = df_bins.reset_index(drop=True)

#Exporting the file
concat_dfs = df_bins
concat_dfs['sample'] = [sample] * len(concat_dfs)
concat_dfs.to_csv(f"{files}/concat_dfs/dfs.tsv", sep="\t", index=False)

file_path = f"{outdir}/paths.txt"
paths = open(file_path, "a")
paths.write(f"{files}/concat_dfs/dfs.tsv" + '\n')
paths.close()
