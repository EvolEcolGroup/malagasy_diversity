#Editing Mikea fam file

fam <- read.table(resrepo::path_resrepo("data/intermediate/biomart/Mikea_full_extracted.fam"))
colnames(fam) <- c("FID", "IID", "V3","V4","V5","V6")
pop_table <- read.table(resrepo::path_resrepo("/data/raw/data_input/Madagascar_Borneo.poptable"), sep = "\t", fill = TRUE)
colnames(pop_table) <- c("IID", "V2","FID","Population","V5","V6","V7")
pop_table_sub <- subset(pop_table,pop_table$IID %in% fam$IID & pop_table$V5 =="Madagascar")
matching_m <- match(fam$IID, pop_table_sub$IID)
fam$FID <- ifelse(!is.na(matching_m), pop_table_sub$FID[matching_m], fam$FID)

write.table(fam, resrepo::path_resrepo("data/intermediate/biomart/Mikea_full_extracted_fixed.fam"), row.names = FALSE, col.names = FALSE, quote = FALSE, sep="\t")
