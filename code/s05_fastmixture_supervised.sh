#!/bin/bash

source /home/EJC199/miniconda3/etc/profile.d/conda.sh
conda activate /home/EJC199/miniconda3/envs/cfastmixture

cd /home/EJC199/Dropbox/gitdata/malagasy_diversity/data/intermediate/rbind_data

# Using binary PLINK files for K=3
fastmixture --bfile mad_bor_g1000_sum --K 2 --threads 2 --seed 1 --out s05_supervised --supervised /home/EJC199/Git/malagasy_diversity/results/s05_fastmixture/data_labels

