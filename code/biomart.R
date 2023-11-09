library(dplyr)
library(sets)
library(ggplot2)
library(biomaRt)
#browseVignettes("biomaRt")
#New dplyr not compatible with biomart gives ensembl errors
(devtools::install_version("dbplyr", version = "2.3.4"))

#setwd("C:\\Users\\eviec\\OneDrive\\Desktop\\PhD")
path_resrepo("data/raw/default")
#../

bim_file1 <- read.table("Malagasy_full_cleaned_PLINK_HG37.bim", header = FALSE, col.names = c("chromosome", "snp_id", "genetic_dist", "physical_pos", "allele1", "allele2"))
as.data.frame(bim_file1)

#Remove VG entries 
filtered_bim_VG_id <-bim_file1[grepl("VG",bim_file1[,2]),]
clean_bim=anti_join(bim_file1,filtered_bim_VG_id)
#write.table(file="rs_id_Malagasy_full_cleaned_PLINK_HG37", clean_bim[,2], row.names = FALSE, quote = FALSE, col.names = FALSE)
cat("Number of VG entries:",sum(nrow(bim_file1)-nrow(clean_bim)))#108

#Ensembl Release 110 (July 2023) GRCH38.14
snpmart = useEnsembl(biomart = "ENSEMBL_MART_SNP", dataset="hsapiens_snp")

#Chunking data to avoid timeout issues with getBM
snps=clean_bim[,2]
chunk=split(snps, ceiling(seq_along(snps)/50000))
chunk[1]

#Biomart function to run
get_and_combine_data <- function(chunk, mart) {
  result_df <- data.frame() 
  
  for (i in 1:length(chunk)) {
    data <- chunk[[i]]
    snp_data <- getBM(attributes = c("refsnp_id", "chr_name", "chrom_start", "allele_1", "allele"),
                      filters = "snp_filter", values = data, mart = mart)
    
    result_df <- rbind(result_df, snp_data)  
  }
  
  return(result_df)
}

biomart_result=get_and_combine_data(chunk,snpmart)
#write.table(file="total_biomart_result", biomart_result, row.names = FALSE, quote = FALSE, col.names = FALSE)
colnames(biomart_result)[1] <- "snp_id"

#Non-numeric entries (all start with H)
biomart_pos_H=biomart_result[grepl("H", biomart_result[,2]),]
nrow(biomart_pos_H)#57349
cat("Number of unique patches/alt entries:",length(unique(biomart_pos_H[,2])))
#365 unique patch/ctg's
biomart_no_patches=anti_join(biomart_result,biomart_pos_H)
nrow(biomart_no_patches)#692001 

#Missing entries
missing_total=clean_bim[!(clean_bim$snp_id %in% biomart_no_patches$snp_id),]
nrow(missing_total)#942
which(missing_total[,4]>0)
missing_non_0=missing_total[874:942,]
#write.table(file = "0_position_SNPs",missing_total[,2],row.names = FALSE, quote = FALSE, col.names = FALSE)

new_bim=left_join(clean_bim,biomart_no_patches, by = "snp_id")
sum(is.na(new_bim$chrom_start))#942 ^ as above
new_bim=new_bim[,c(1:3,5:8)]



