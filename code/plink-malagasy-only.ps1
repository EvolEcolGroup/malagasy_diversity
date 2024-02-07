#Create a clean Malagasy set 
cd 'C:\Users\eviec\OneDrive - Anglia Ruskin University\gitdata\data'

#plink --bfile raw/data_input/Madagascar_full --extract intermediate/biomart/Madagascar_full_HG38.bim --chr 1-22 --mind 0.05 --geno 0.1 --maf 0.01 --make-bed --out intermediate/biomart/Madagascar_full_extracted_clean

plink --bfile raw/data_input/Madagascar_full --extract intermediate/biomart/Madagascar_full_HG38.bim --make-bed --out intermediate/biomart/Madagascar_full_extracted
plink --bfile raw/data_input/Pierron_Malagasy --extract intermediate/biomart/Mikea_updated_full.bim --make-bed --out intermediate/biomart/Mikea_full_extracted
#Edit .fam files as necessary in R at this stage (separate scripts)


#Create the text file of files to merge
#Merge files
plink --merge-list intermediate/biomart/merge_malagasy_mikea.txt --extract intermediate/biomart/merge_malagasy_mikea_snps.txt --chr 1-22 --mind 0.05 --geno 0.1 --maf 0.01 --make-bed --out intermediate/biomart/merged_malagasy_clean_auto


#Find close relatives with KING 
king -b intermediate/biomart/merged_malagasy_clean_auto.bed --unrelated --degree 2 –out intermediate/biomart
#These are currently left in top level of the data folder - directing output
#–degree 2 gives this output
#Remove close relatives
plink --bfile intermediate/biomart/merged_malagasy_clean_auto --remove 'C:\Users\eviec\OneDrive - Anglia Ruskin University\gitdata\data\kingunrelated_toberemoved.txt' --make-bed --out intermediate/biomart/merged_malagasy_clean_auto_no_relatives

#LD pruning (saved separately)
plink --bfile intermediate/biomart/merged_malagasy_clean_auto_no_relatives --indep-pairwise 50 5 0.5 --out intermediate/biomart/merged_malagasy_clean_auto_no_relatives_LDpruned
plink --bfile intermediate/biomart/merged_malagasy_clean_auto_no_relatives --extract intermediate/biomart/merged_malagasy_clean_auto_no_relatives_LDpruned.prune.in --make-bed --out intermediate/biomart/merged_malagasy_clean_auto_no_relatives_LDpruned
#258314 of 666007 variants removed
#221732 of 619413 variants removed


#ROH:
plink --bfile intermediate/biomart/merged_malagasy_clean_auto_no_relatives_LDpruned --homozyg --out intermediate/biomart/merged_malagasy_clean_auto_no_relatives_LDpruned_ROH


#IBS-MDS
plink --bfile intermediate/biomart/merged_malagasy_clean_auto_no_relatives_LDpruned --cluster --genome --out intermediate/biomart/merged_malagasy_clean_auto_no_relatives_LDpruned_IBS
plink --bfile intermediate/biomart/merged_malagasy_clean_auto_no_relatives_LDpruned --read-genome intermediate/biomart/merged_malagasy_clean_auto_no_relatives_LDpruned_IBS.genome --cluster --mds-plot 2 --out intermediate/biomart/merged_malagasy_clean_auto_no_relatives_LDpruned_IBS_MDS
