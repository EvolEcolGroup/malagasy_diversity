#Vietnamese population from 1000G

G_1000_fam <- read.table(resrepo::path_resrepo("data/raw/data_input/1000_Genomes_b37_clean.fam"))
vietnamese <- read.table(resrepo::path_resrepo("data/intermediate/biomart/vietnamese.txt."))

G_1000_V <- subset(G_1000_fam,G_1000_fam[,1] %in% vietnamese[,1])

vietnamese <- G_1000_V[,c(1,2)]
#vietnamese$V1 <- "VNM"

#write.table(file=resrepo::path_resrepo("data/intermediate/biomart/vietnamese_ID.txt"), vietnamese, sep="\t",row.names = FALSE, quote = FALSE, col.names = FALSE)


bangladeshi <- read.table(resrepo::path_resrepo("data/intermediate/biomart/bangladeshi.txt."))

G_1000_B <- subset(G_1000_fam,G_1000_fam[,1] %in% bangladeshi[,1])
bangladeshi <- G_1000_B[,c(1,2)]
#bangladeshi$V1 <- "BDG"

#write.table(file=resrepo::path_resrepo("data/intermediate/biomart/bangladeshi_ID.txt"), bangladeshi, sep="\t",row.names = FALSE, quote = FALSE, col.names = FALSE)

keep <- rbind(vietnamese,bangladeshi)

write.table(file=resrepo::path_resrepo("data/intermediate/biomart/1000G_keep_ID.txt"), keep, sep="\t",row.names = FALSE, quote = FALSE, col.names = FALSE)



