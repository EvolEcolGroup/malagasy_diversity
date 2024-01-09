#Editing Borneo .fam file

fam <- read.table(resrepo::path_resrepo("data/intermediate/biomart/Borneo_full_extracted.fam"))
fam$V1[1:39] <- sub("_.*","",fam$V1[1:39])
write.table(fam, resrepo::path_resrepo("data/intermediate/biomart/Borneo_full_extracted_fixed.fam"), row.names = FALSE, col.names = FALSE, quote = FALSE, sep="\t")