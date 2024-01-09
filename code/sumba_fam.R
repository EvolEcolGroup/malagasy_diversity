#Editing Sumba fam file

fam <- read.table(resrepo::path_resrepo("data/intermediate/biomart/Sumba_Timor_full_extracted.fam"))
summary(fam)
timor <- read.table(resrepo::path_resrepo("data/raw/data_input/timor"))
timor <- subset(fam, fam$V2 %in% timor$V2)
timor$V1 <- "Timor"
sumba <- fam[!(fam$V2 %in% timor$V2),]
sumba$V1 <- "Sumba"
new_fam <- rbind(sumba,timor)
write.table(new_fam, resrepo::path_resrepo("data/intermediate/biomart/Sumba_Timor_full_extracted_fixed.fam"), row.names = FALSE, col.names = FALSE, quote = FALSE, sep="\t")