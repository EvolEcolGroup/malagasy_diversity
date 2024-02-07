
#Change wd
cd 'C:\Users\eviec\OneDrive - Anglia Ruskin University\gitdata\data'

#Create new binary filesets for each dataset
plink --bfile raw/data_input/Madagascar_full --extract intermediate/biomart/Madagascar_full_HG38.bim --make-bed --out intermediate/biomart/Madagascar_full_extracted
plink --bfile raw/data_input/Borneo_raw_data --extract intermediate/biomart/Borneo_raw_data_updated_full.bim --make-bed --out intermediate/biomart/Borneo_full_extracted
plink --bfile raw/data_input/SAN_SA_OmniEx_hg19 --extract intermediate/biomart/SAN_SA_OmniEx_updated_full.bim --make-bed --out intermediate/biomart/SAN_SA_OmniEx_full_extracted
plink --bfile raw/data_input/GSE76645_INDONESIA_SUMBA_TIMOR --extract intermediate/biomart/Sumba_Timor_updated_full.bim --make-bed --out intermediate/biomart/Sumba_Timor_full_extracted
plink --bfile raw/data_input/1000_Genomes_b37_clean --extract intermediate/biomart/1000_updated_full.bim --make-bed --out intermediate/biomart/1000_full_extracted
plink --bfile raw/data_input/Pierron_Malagasy --extract intermediate/biomart/Mikea_updated_full.bim --make-bed --out intermediate/biomart/Mikea_full_extracted
#Edit .fam files as necessary in R at this stage (separate scripts)
#Borneo Sumba and Mikea separately 

#ID file requires two rows - a family and individual ID, identical in this case 
#plink --bfile intermediate/biomart/1000_full_extracted --keep intermediate/biomart/vietnamese_ID.txt --make-bed --out intermediate/biomart/1000_full_extracted_V
#plink --bfile intermediate/biomart/1000_full_extracted --keep intermediate/biomart/1000G_keep_ID.txt --make-bed --out intermediate/biomart/1000_full_extracted_V

plink --bfile intermediate/biomart/1000_full_extracted --keep intermediate/biomart/1000G_keep.txt --make-bed --out intermediate/biomart/1000_full_extracted_V



#Create the text file of files to merge
#merge.txt in data/intermediate/biomart

#Merge files
plink --merge-list intermediate/biomart/merge_1000G.txt --extract intermediate/biomart/merged_1000G_snps.txt --chr 1-22 --mind 0.05 --geno 0.1 --maf 0.01 --make-bed --out intermediate/biomart/merge_full_auto_1000G_V

#Find close relatives with KING 
king -b intermediate/biomart/merge_full_auto_1000G_V.bed --unrelated --degree 2 -out intermediate/biomart
#These are currently left in top level of the data folder - directing and naming output better?
#Warning that it doesn't recognise -out flag
#–degree 2 gives this output
#Remove close relatives
plink --bfile intermediate/biomart/merge_full_auto_1000G_V --remove 'C:\Users\eviec\OneDrive - Anglia Ruskin University\gitdata\data\kingunrelated_toberemoved.txt' --make-bed --out intermediate/biomart/merge_full_auto_1000G_V_no_relatives

#Move these king files afterwards (manually for now - issue with king outputs?)

#LD pruning (saved separately)
plink --bfile intermediate/biomart/merge_full_auto_1000G_V_no_relatives --indep-pairwise 50 5 0.5 --out intermediate/biomart/merge_full_auto_1000G_V_no_relatives_LDpruned
#Check files in biomart before this step - any replicated filenames will throw an error
plink --bfile intermediate/biomart/merge_full_auto_1000G_V_no_relatives --extract intermediate/biomart/merge_full_auto_1000G_V_no_relatives_LDpruned.prune.in --make-bed --out intermediate/biomart/merge_full_auto_1000G_V_no_relatives_LDpruned
                                                                                                       
#265123 of 640973 variants removed
#231423 of 649319 variants removed after adding all 1000G in 1000G_keep.txt
#203134 of 607975 variants removed after adding Mikea


#ROH:
plink --bfile intermediate/biomart/merge_full_auto_1000G_V_no_relatives_LDpruned --homozyg --out intermediate/biomart/ROH_1000G_V
#found 7576 ROH


#IBS for MDS


#Create a more even number of individuals using --keep with a sample 
plink --bfile intermediate/biomart/merge_full_auto_1000G_V_no_relatives_LDpruned --keep intermediate/biomart/sampled_individuals.txt --make-bed --out intermediate/biomart/merge_full_sampled
