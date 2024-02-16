#Sort HGDP 

fam <- read.table(resrepo::path_resrepo("data/intermediate/biomart/1000_full_extracted_V.fam"))
colnames(fam) <- c("FID", "IID", "V3","V4","V5","V6")
G1000_groups <- read.table(resrepo::path_resrepo("/data/intermediate/biomart/1000G_keep_all.txt"),sep = "\t")
colnames(G1000_groups) <- c("FID","IID", "Population", "Sex")
sub <- fam[fam$IID %in% G1000_groups$IID,] 

#Missing is individuals in the metadata G1000_groups who were filtered out in QC process
missing <- dplyr::anti_join(G1000_groups,sub,by = "IID")
G1000_groups <- dplyr::anti_join(G1000_groups,missing,by="IID")

#Match based on individual ID
matching_indices <- match(fam$IID, G1000_groups$IID)
#Replace FID column in fam with FID given in G1000_groups
fam$FID <- ifelse(!is.na(matching_indices), G1000_groups$FID[matching_indices], fam$FID)

#Check 
unique(fam$FID)

#Write out 
write.table(fam, resrepo::path_resrepo("data/intermediate/biomart/1000_full_extracted_V_fixed.fam"), row.names = FALSE, col.names = FALSE, quote = FALSE, sep="\t")



