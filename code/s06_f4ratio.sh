#!/usr/bin/env bash
set -euo pipefail

MERGED_BED="../data/intermediate/rbind_data/mad_bor_g1000_sum_neo_clean_ld_snps.bed"

# 1. Download chimp reference genome
echo "[1] Downloading chimp reference genome (FASTA)..."

#wget -c -O ../data/raw/data_input/PanTro3-v2.0_chimp.fna.gz https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/028/858/775/#GCF_028858775.2_NHGRI_mPanTro3-v2.0_pri/GCF_028858775.2_NHGRI_mPanTro3-v2.0_pri_genomic.fna.gz

#gunzip -c ../data/raw/data_input/PanTro3-v2.0_chimp.fna.gz > ../data/raw/data_input/PanTro3-v2.0_chimp.fa

# 2. Download overchain
echo "[2] Downloading hg19 to chimp overchain..."

#wget -c -O ../data/raw/data_input/hg19ToPanTro3.over.chain.gz https://hgdownload.cse.ucsc.edu/goldenpath/hg19/liftOver/hg19ToPanTro3.over.chain.gz

# 3. Index 
echo "[3] Indexing FASTA..."

#samtools faidx ../data/raw/data_input/PanTro3-v2.0_chimp.fa

# 4. LiftOver
echo "[4] liftOver the .bed to chimp positions..."

liftOver ${MERGED_BED} ../data/raw/data_input/hg19ToPanTro3.over.chain.gz ../data/intermediate/pan_tro_liftover/merged_data_pan_tro.bed ../data/intermediate/pan_tro_liftover/unmapped.bed

echo "Mapped SNPs: $(wc -l < ../data/intermediate/pan_tro_liftover/merged_data_pan_tro.bed)"
echo "Unmapped SNPs: $(wc -l < ../data/intermediate/pan_tro_liftover/unmapped.bed)"

# 5. 
