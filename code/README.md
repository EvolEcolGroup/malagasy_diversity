# Code

Scripts should be run in the following order:

s00_merge_neo_dataset: Merges African datasets from Fortez-Lima et al 2024
s01_qc_merge.Rmd: Quality control and merging of all SNP datasets
s02_qc_merge_genetic_dist: Quality control and merging of SNP datasets, checking genetic distance
s03_malagasy_pca: PCA of Malagasy samples
s04_full_pca: PCA of Malagasy samples with African and Asian references
s05_fastmixture: FastMixture analysis of global samples
s05_b_fastmixture_africa: FastMixture analysis of African samples
s06_a_chimpanzee_ref: preparation for f4 ratio statistics
s06_b_f_stats: f3 and f4 statistics
s07_ALDER: ALDER analysis for admixture dating
s07a_convertf.par: Parameter file for converting EIGENSTRAT to PLINK format
s07a_convertf_merina_sep.par: Parameter file for converting EIGENSTRAT to PLINK format for Merina samples
s07_b_ALDER_map: Map of sampling locations with ALDER results
s08_FST: FST calculations between populations
s09_data_source_map: Map of sampling locations
