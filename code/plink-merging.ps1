#Change wd
cd 'C:\Users\eviec\OneDrive - Anglia Ruskin University\gitdata\data'

#################### Edit Borneo Sumba and Mikea .fam files as necessary in R at this stage (separate scripts) #################

#ID file requires two rows - a family and individual ID, identical in this case 
plink --bfile intermediate/biomart/data-merge-corrected/1000_full_extracted_RM --keep intermediate/biomart/data-merge-corrected/1000G_keep.txt --make-bed --out intermediate/biomart/data-merge-corrected/1000_full_extracted_keep

#################### Then edit 1000G .fam file in R (separate script) #######################

plink --merge-list intermediate/biomart/data-merge-corrected/merge_corrected_test.txt --extract intermediate/biomart/data-merge-corrected/merge_snps_test.txt --chr 1-22 --mind 0.05 --geno 0.1 --maf 0.01 --make-bed --out intermediate/biomart/data-merge-corrected/merge_test

#Find close relatives with KING 
king -b intermediate/biomart/data-merge-corrected/merge_test.bed --unrelated --degree 2 -out intermediate/biomart
#These are currently left in top level of the data folder - directing and naming output better?
#Warning that it doesn't recognise -out flag
#–degree 2 gives this output
#Remove close relatives
plink --bfile intermediate/biomart/data-merge-corrected/merge_test --remove 'C:\Users\eviec\OneDrive - Anglia Ruskin University\gitdata\data\kingunrelated_toberemoved.txt' --make-bed --out intermediate/biomart/data-merge-corrected/merge_test_no_relatives

#LD pruning (saved separately)
plink --bfile intermediate/biomart/data-merge-corrected/merge_test_no_relatives --indep-pairwise 50 5 0.5 --out intermediate/biomart/data-merge-corrected/merge_test_no_relatives_LDpruned
#167936 of 652160 variants removed
#Check files in biomart before this step - any replicated filenames will throw an error
plink --bfile intermediate/biomart/data-merge-corrected/merge_test_no_relatives --extract intermediate/biomart/data-merge-corrected/merge_test_no_relatives_LDpruned.prune.in --make-bed --out intermediate/biomart/data-merge-corrected/merge_test_no_relatives_LDpruned

#Create a more even number of individuals using --keep with a sample 
plink --bfile intermediate/biomart/data-merge-corrected/merge_test_no_relatives_LDpruned --keep intermediate/biomart/data-merge-corrected/sampled_individuals.txt --make-bed --out intermediate/biomart/data-merge-corrected/merge_test_sampled

