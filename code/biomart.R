library(dplyr)
library(sets)
library(ggplot2)
library(biomaRt)
#New dplyr not compatible with biomart gives ensembl errors
(devtools::install_version("dbplyr", version = "2.3.4"))
library(resrepo)

setwd("C:/Users/eviec/Git/malagasy_diversity/")

bim_file1 <- read.table(resrepo::path_resrepo("data/raw/data_input/Malagasy_full_cleaned_PLINK_HG37.bim")
           , header = FALSE, col.names = c("chromosome", "snp_id", "genetic_dist", "physical_pos", "allele1", "allele2"))
as.data.frame(bim_file1)


#Remove VG entries - clean_bim
filtered_bim_VG_id <-bim_file1[grepl("VG",bim_file1[,2]),]
clean_bim=anti_join(bim_file1,filtered_bim_VG_id)
cat("Number of VG entries removed:",sum(nrow(bim_file1)-nrow(clean_bim)))
cat("Number of SNPs remaining after removing VG id SNPs:", nrow(clean_bim))


#Ensembl Release 110 (July 2023) GRCH38.14
snpmart = useEnsembl(biomart = "ENSEMBL_MART_SNP", dataset="hsapiens_snp")

#Chunking data to avoid timeout issues with ensembl getBM
snps=clean_bim[,2]
chunk=split(snps, ceiling(seq_along(snps)/50000))


#Find biomart entries for all our SNPs
get_and_combine_data <- function(chunk, mart) {
  result_df <- data.frame() 
  
  for (i in 1:length(chunk)) {
    data <- chunk[[i]]
    snp_data <- getBM(attributes = c("refsnp_id", "chr_name", "chrom_start", "allele_1", "allele","minor_allele","chrom_strand"),
                      filters = "snp_filter", values = data, mart = mart)
    
    result_df <- rbind(result_df, snp_data) 
    
    cat("Chunk", i, "complete.\n")
  }
  
  return(result_df)
}

biomart_result=get_and_combine_data(chunk,snpmart)
colnames(biomart_result)[1] <- "snp_id"
colnames(biomart_result)[4] <- "ancestral_allele"


#################### Update our data to HG38 using biomart result


#Patch entries (all start with H)
biomart_pos_H=biomart_result[grepl("H", biomart_result[,2]),]
cat("Number of SNPs affected by patched entries:", nrow(biomart_pos_H))
cat("Number of unique patches covering SNPs:",length(unique(biomart_pos_H[,2])))

#Removing these patch entries
biomart_no_patches=anti_join(biomart_result,biomart_pos_H)
cat("Number of SNPs in biomart output after removing patch entries:", nrow(biomart_no_patches))

#Missing entries
missing_total=clean_bim[!(clean_bim$snp_id %in% biomart_no_patches$snp_id),]
cat("Number of SNPs missing in biomart output:",nrow(missing_total))
which(missing_total[,4]>0)
missing_non_0=missing_total[874:942,]

#Removing missing entries and writing new .bim
new_bim=left_join(clean_bim,biomart_no_patches, by = "snp_id")
sum(is.na(new_bim$chrom_start))#942 ^ as above
new_bim=new_bim[,c(7,2:3,8,5:6)]
new_bim_no_NA <- na.omit(new_bim)


#new_bim_no_NA is our .bim updated to HG38 positions
base_dir <- file.path("C:/Users/eviec")
write.table(file=path_resrepo("data/intermediate/biomart/Malagasy_full_cleaned_PLINK_HG38.bim"), new_bim_no_NA, sep="\t",row.names = FALSE, quote = FALSE, col.names = FALSE)




#################### Create new .bim files for each dataset 
data_pipeline_bim <- function(x, y) {
  # where x is new data to convert to HG38 positions
  # and y is the current dataset e.g., updated Malagasy biomart positions
  
  # Read in the data
  new_data <- read.table(x, col.names = c("chromosome", "snp_id", "genetic_dist", "physical_pos", "allele1", "allele2"))
  comparative_data <- read.table(y, col.names = c("chromosome", "snp_id", "genetic_dist", "physical_pos", "allele1", "allele2"))
  
  # Later add something to check the cols are in the expected order?
  
  # Find overlap between SNPs in each set
  overlap <- sum(new_data$snp_id %in% comparative_data$snp_id)
  cat("Supplied .bim contains",nrow(new_data), "SNPs", "\n")
  cat(overlap,"SNPs overlap with our dataset")
  
  # Exit at this point if overlap is less than 200,000
  if (overlap < 200000) {
    warning("Less than 200,000 overlapping SNPs found.")
    return(new_data)
  }
  
  # Find matching SNP IDs
  match_indices <- match(new_data$snp_id, comparative_data$snp_id)
  
  # Identify rows with matches and update physical_pos
  matching_rows <- !is.na(match_indices)
  new_data$physical_pos[matching_rows] <- comparative_data$physical_pos[match_indices[matching_rows]]
  new_data$chromosome[matching_rows] <- comparative_data$chromosome[match_indices[matching_rows]]
  
  # Non-overlapping rows are not updated
  # These remain in the output, will be removed in plink 
  
  return(new_data)
}

# Example
res_borneo=data_pipeline_bim(resrepo::path_resrepo("data/raw/data_input/Borneo_raw_data.bim"),
                             resrepo::path_resrepo("data/intermediate/biomart/Malagasy_full_cleaned_PLINK_HG38.bim"))


#write.table(file = "HG38_updated_Borneo_raw_data.bim",res_borneo, sep="\t",row.names = FALSE, quote = FALSE, col.names = FALSE)



############## Deal with our 71 cases missing allele A UNFINISHED


missing <- function(x,y){
  
  #Check for missing values at each allele
  missing_values_alleleA <- subset(x, is.na(x[,5]) | x[,5]==0)
  missing_values_alleleB <- subset(x, is.na(x[,6]) | x[,6]==0)
  cat(nrow(missing_values_alleleA),": SNPs with missing A values","\n")
  cat(nrow(missing_values_alleleB),": SNPs with missing B values","\n")
  
  #Compare
  df <- merge(x, y, by.x = "snp_id", by.y = "snp_id", all.x = TRUE)
  to_change <- subset(df,df$snp_id %in% missing_values_alleleA$snp_id)
  

  no_biomart_comparison <- subset(to_change,to_change[,9]=="" & to_change[,11]=="")
  print(nrow(no_biomart_comparison)) #drop these 6?
  
  matching_6_9 <- subset(to_change,to_change[,6] == to_change[,9] & to_change[,11] == "")
  print(nrow(matching_6_9))
  #matching_6_9[,5] <- complement_base(matching_6_9[,9])
  matching_6_9 <- subset(to_change,to_change[,6] == to_change[,9] & to_change[,11] == "")
  print(nrow(matching_6_9))
  
  
  matching_6_11 <- subset(to_change, to_change[,6] == to_change[,11])
  print(nrow(matching_6_11))
  
  flipped <- subset(to_change, to_change[, 6] == complement_base(to_change[, 9]) | to_change[, 6] == complement_base(to_change[, 11]))
  print(nrow(flipped))
  
  #other <- subset(to_change, !(to_change$snp_id %in% c(no_biomart_comparison$snp_id, matching$snp_id, flipped$snp_id)))
  #print(nrow(other))

  
  
  return(list(x,to_change,matching_6_9))
}

new_bim_no_NA_missingrm <- missing(new_bim_no_NA,biomart_no_patches)





############## Testing this function with borneo data

flip <- function(x, y) {
  # where x is new data to convert to our strands
  # and y is the current dataset e.g., updated Malagasy biomart positions
  
  
  ################# Remove SNPs that aren't in our dataset 
  
  # Find overlap between SNPs in each set
  overlap <- sum(x$snp_id %in% y$snp_id)
  cat("Supplied .bim contains",nrow(x), "SNPs", "\n")
  cat(overlap,"SNPs overlap with our dataset","\n")
  
  # Find matching SNP IDs
  match_indices <- match(x$snp_id, y$snp_id)
  
  # Identify matching rows
  matching_rows <- !is.na(match_indices)
  
  # Remove non-matching rows
  x <- x[matching_rows, ]
  
  
  df <- left_join(x, y, by = "snp_id")
  
  # Create list of ambiguous SNPs in our data to remove later in plink
  ambiguous <- subset(df, df$allele1.y == "A" & df$allele2.y == "T" |
                        df$allele1.y == "T" & df$allele2.y == "A" |
                        df$allele1.y == "G" & df$allele2.y == "C" |
                        df$allele1.y == "C" & df$allele2.y == "G")
  cat(nrow(ambiguous), ": ambiguous SNPs", "\n")
  ambiguous_list <- ambiguous$snp_id
  
  #Remove ambiguous SNPs for now
  df <- anti_join(df,ambiguous)
  cat(nrow(df),": left after removing ambiguous SNPs", "\n")
  
  #Create function to find complementary bases
  complement_base <- function(base) {
    switch(base,
           A = "T",
           T = "A",
           C = "G",
           G = "C",
           base  
    )
  }
  
  
  #Finding same strand (matching) and those to flip (flipped_condition)
  process_row <- function(row) {
    
    # Check for missing values
    missing_values <- any(is.na(row[c(5, 6, 9, 10)]) | row[c(5, 6, 9, 10)]==0)
    
    
    #Same strand - matching ancestral, minor, allele1, allele2 
    matching <- (row[5] == row[10] & row[6] == row[11] | row[5] == row[11] & row[6] == row[10])
    
    
    #Opposite strand - matching ancestral, minor, allele1, allele2
    flipped_condition_5_10 <- (row[5] == complement_base(row[10]) & row[6] == complement_base(row[11]))
    flipped_condition_5_11 <- (row[5] == complement_base(row[11]) & row[6] == complement_base(row[10]))
    
    
    #Rows with N as allele A?
    #N_condition <- (row[5]=="N")
    N_6_10 <-(row[6] == row[10] & row[5]=="N")
    N_6_11 <- (row[6] == row[11]& row[5]=="N")
    N_flip_6_10 <- (row[6] == complement_base(row[10]) & row[5]=="N")
    N_flip_6_11 <- (row[6] == complement_base(row[11]) & row[5]=="N")
    
    if (missing_values) {
      return(c(row, type = "missing values"))
      
    } else if (N_6_10){
      row[5] <- row[11] 
      return(c(row, type = "N 6 10"))
    } else if (N_6_11){
      row[5] <- row[10]
      return(c(row, type = "N 6 11"))
    } else if (N_flip_6_10){
      row[5] <- complement_base(row[11])
      return(c(row, type = "N flip 6 10"))
    } else if (N_flip_6_11){
      row[5] <- complement_base(row[10])
      return(c(row, type = "N flip 6 11"))
      
    } else if (matching) {
      return(c(row, type = "matching"))
    } else if (flipped_condition_5_10) {
      row[5] <- row[10] #Need to check this
      row[6] <- row[11]
      return(c(row, type = "flipped"))
    } else if (flipped_condition_5_11){
      row[5] <- row[11]
      row[6] <- row[10]
      return(c(row, type = "flipped"))
    } else{
      return(c(row,type = "?"))
    }
  }
  
  processed_rows <- apply(df, 1, process_row)
  processed_rows <- t(processed_rows)
  
  processed_rows <- as.data.frame(processed_rows, 
                                  colnames=c("snp_id","chr_name","chrom_start","updated_allele_a","allele","updated_allele_B","chrom_strand","genetic_dist","allele1","allele2","type"))
  
  #names(processed_rows)[names(processed_rows) == 'ancestral_allele'] <- 'updated_allele_A'
  #names(processed_rows)[names(processed_rows) == 'minor_allele'] <- 'updated_allele_B'
  
  
  cat("Processing finished", "\n")
  
  ############### Checking numbers of each case/how many unprocessed rows#########
  
  
  matching_both_ways <- processed_rows[processed_rows$type == "matching", ]
  cat(nrow(matching_both_ways), ": Same strand ", "\n")
  
  flipped_rows <- processed_rows[processed_rows$type == "flipped", ]
  cat(nrow(flipped_rows), ": Opposite strand ", "\n")
  missing <- processed_rows[processed_rows$type == "missing values", ]
  cat(nrow(missing),": SNPs with missing values","\n")
  to_remove <- processed_rows[processed_rows$type == "?", ]
  cat(nrow(to_remove),": SNPs to exclude","\n")
  
  
  ########### Borneo specific issue 
  cat("Fixing cases where allele A is N in Borneo data","\n")
  
  #N_condition <-processed_rows[processed_rows$type == "N condition",]
  #cat(nrow(N_condition),": SNPs with N as allele A?","\n")
  N_6_10 <-processed_rows[processed_rows$type == "N 6 10",]
  cat(nrow(N_6_10),": N 6 10","\n")
  N_6_11 <-processed_rows[processed_rows$type == "N 6 11",]
  cat(nrow(N_6_11),": N 6 11","\n")
  N_flip_6_10 <-processed_rows[processed_rows$type == "N flip 6 10",]
  cat(nrow(N_flip_6_10),": N flip 6 10","\n")
  N_flip_6_11 <-processed_rows[processed_rows$type == "N flip 6 11",]
  cat(nrow(N_flip_6_11),": N flip 6 11","\n")
  
  other <- df[!(df[,2] %in% processed_rows[,2]),]
  cat(nrow(processed_rows),": Processed","\n")
  cat(nrow(other),": left","\n") 
  cat(sum(nrow(processed_rows), nrow(other)),": Total","\n")
  
  
  ###########################
  
  
  
  return(list(processed_rows,ambiguous_list,to_remove))
}


some_flips <- flip(res_borneo, new_bim_no_NA) 




#Test that the function hasn't created any spurious AT CG pairs

N_6_10 <- some_flips[[5]]
wrong <- subset(N_6_10,N_6_10$allele1.x == "A" & N_6_10$allele2.x == "T" |
         N_6_10$allele1.x == "T" & N_6_10$allele2.x == "A" |
         N_6_10$allele1.x == "G" & N_6_10$allele2.x == "C" |
         N_6_10$allele1.x == "C" & N_6_10$allele2.x == "G")
nrow(wrong)

N_flip_6_10 <- some_flips[[7]]
wrong <- subset(N_flip_6_10,N_flip_6_10$allele1.x == "A" & N_flip_6_10$allele2.x == "T" |
                  N_flip_6_10$allele1.x == "T" & N_flip_6_10$allele2.x == "A" |
                  N_flip_6_10$allele1.x == "G" & N_flip_6_10$allele2.x == "C" |
                  N_flip_6_10$allele1.x == "C" & N_flip_6_10$allele2.x == "G")
nrow(wrong)




