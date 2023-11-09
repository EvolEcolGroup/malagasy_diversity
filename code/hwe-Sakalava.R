setwd("C:\\Users\\eviec\\OneDrive\\Desktop\\PhD")

fam_file <- read.table("Madagascar_full.fam", header = FALSE)
as.data.frame(fam_file)
fam_file_NW=fam_file[grepl("NW",fam_file[,2]),]
#write.table(file="Malagasy_full_Tsim_Saka", fam_file_NW, row.names = FALSE, quote = FALSE, col.names = FALSE)



#############################
#  plink --bfile Malagasy_full_cleaned_PLINK_HG37 --hwe 1e-6 --keep Malagasy_full_cleaned_PLINK_HG37_Tsim_Saka --make-bed --out hwe_results

#############################



hwe_res <- read.table("hwe_results.bim",header=FALSE)
bim_file1 <- read.table("Madagascar_full.bim", header = FALSE, col.names = c("chromosome", "snp_id", "genetic_dist", "physical_pos", "allele1", "allele2"))

removed_snps=bim_file1[!(bim_file1[,2] %in% hwe_res[,2]),]
nrow(removed_snps)


#With cleaned data 
#2, 4, and 26 SNPs respectively at 1e-6, 1e-5, and 1e-4 p-val thresholds

#With raw data
#115
#1345
