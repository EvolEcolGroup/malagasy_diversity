#Working with autosomes only 

#Change wd
cd 'C:\Users\eviec\OneDrive - Anglia Ruskin University\gitdata\data'

#Create new binary filesets for each dataset
plink --bfile raw/data_input/Madagascar_full --extract intermediate/biomart/Madagascar_full_HG38.bim --make-bed --out intermediate/biomart/Madagascar_full_extracted
plink --bfile raw/data_input/Borneo_raw_data --extract intermediate/biomart/Borneo_raw_data_updated_full.bim --make-bed --out intermediate/biomart/Borneo_full_extracted
plink --bfile raw/data_input/SAN_SA_OmniEx_hg19 --extract intermediate/biomart/SAN_SA_OmniEx_updated_full.bim --make-bed --out intermediate/biomart/SAN_SA_OmniEx_full_extracted
plink --bfile raw/data_input/GSE76645_INDONESIA_SUMBA_TIMOR --extract intermediate/biomart/Sumba_Timor_updated_full.bim --make-bed --out intermediate/biomart/Sumba_Timor_full_extracted
#Edit .fam files as necessary in R at this stage (separate scripts)

#Create the text file of files to merge
#merge.txt in data/intermediate/biomart

#Merge files
plink --merge-list intermediate/biomart/merge.txt --chr 1-22 --mind 0.05 --geno 0.1 --maf 0.01 --make-bed --out intermediate/biomart/merge_full_auto

#Find close relatives with KING
C:\Users\eviec\OneDrive\Desktop\King\king.exe -b intermediate/biomart/merge_full_auto.bed --unrelated –out intermediate/biomart
#Manually move these files to a ‘king’ folder in intermediate – for now
#–degree 2 gives this output
#Remove close relatives
plink --bfile intermediate/biomart/merge_full_auto --remove 'C:\Users\eviec\OneDrive - Anglia Ruskin University\gitdata\data\kingunrelated_toberemoved.txt' --make-bed --out intermediate/biomart/merge_full_auto_no_relatives

#Move these king files afterwards (manually for now - issue with king outputs?)


#LD pruning (saved separately)
plink --bfile intermediate/biomart/merge_full_auto_no_relatives --indep-pairwise 50 5 0.5 --out intermediate/biomart/merge_full_auto_no_relatives_LDpruned
plink --bfile intermediate/biomart/merge_full_auto_no_relatives --extract intermediate/biomart/merge_full_no_relatives_LDpruned.prune.in --make-bed --out intermediate/biomart/merge_full_auto_no_relatives_LDpruned
#296055 of 670081 variants removed


#ROH:
	plink --bfile intermediate/biomart/merge_full_auto_no_relatives_LDpruned --homozyg --out intermediate/biomart/ROH


#Checking monomorphic SNPs
#plink --bfile raw/data_input/Madagascar_full --maf 0.000000001 --make-bed --out intermediate/biomart/Madagascar_monomorphic_test
