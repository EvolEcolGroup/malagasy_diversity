setwd("C:\\Users\\eviec\\OneDrive\\Desktop\\PhD")

fam_file <- read.table("Madagascar_full.fam", header = FALSE)
as.data.frame(fam_file)
fam_file_NW=fam_file[grepl("NW",fam_file[,2]),]
#write.table(file="Malagasy_full_Tsim_Saka", fam_file_NW, row.names = FALSE, quote = FALSE, col.names = FALSE)



#############################
#  plink --bfile Madagascar_full --hwe 1e-6 --keep Malagasy_full_cleaned_PLINK_HG37_Tsim_Saka --make-bed --out hwe_results

#############################


#Read in plink results
hwe_res <- read.table("hwe_results.bim",header=FALSE)
bim_file1 <- read.table("Madagascar_full.bim", header = FALSE, col.names = c("chromosome", "snp_id", "genetic_dist", "physical_pos", "allele1", "allele2"))

removed_snps=bim_file1[!(bim_file1[,2] %in% hwe_res[,2]),]
nrow(removed_snps)#115 almost all on 23

biomart_res <- read.table("total_biomart_result",header = FALSE, fill=TRUE)
biomart_pos_H <- biomart_res[grepl("H", biomart_result[,2]),]
sum(biomart_pos_H[, 1] %in% removed_snps[, 2])


