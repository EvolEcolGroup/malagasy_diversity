#Create a clean Malagasy set 
cd 'C:\Users\eviec\OneDrive - Anglia Ruskin University\gitdata\data'

plink --bfile raw/data_input/Madagascar_full --extract intermediate/biomart/Madagascar_full_HG38.bim --chr 1-22 --mind 0.05 --geno 0.1 --maf 0.01 --make-bed --out intermediate/biomart/Madagascar_full_extracted_clean

#Find close relatives with KING 
king -b intermediate/biomart/Madagascar_full_extracted_clean.bed --unrelated –out intermediate/biomart
#These are currently left in top level of the data folder - directing output
#–degree 2 gives this output
#Remove close relatives
plink --bfile intermediate/biomart/Madagascar_full_extracted_clean --remove 'C:\Users\eviec\OneDrive - Anglia Ruskin University\gitdata\data\kingunrelated_toberemoved.txt' --make-bed --out intermediate/biomart/Madagascar_full_extracted_clean_auto_no_relatives

#LD pruning (saved separately)
plink --bfile intermediate/biomart/Madagascar_full_extracted_clean_auto_no_relatives --indep-pairwise 50 5 0.5 --out intermediate/biomart/Madagascar_full_extracted_clean_auto_no_relatives_LDpruned
plink --bfile intermediate/biomart/Madagascar_full_extracted_clean_auto_no_relatives --extract intermediate/biomart/Madagascar_full_extracted_clean_auto_no_relatives_LDpruned.prune.in --make-bed --out intermediate/biomart/Madagascar_full_extracted_clean_auto_no_relatives_LDpruned
#258314 of 666007 variants removed