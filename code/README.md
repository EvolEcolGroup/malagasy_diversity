# Code

Scripts should be run in the following order:

* s00_merge_neo_dataset: Merges African datasets from Fortez-Lima et al 2024
* s01_qc_merge.Rmd: Quality control and merging of all SNP datasets
* s02_qc_merge_genetic_dist: Quality control and merging of SNP datasets, checking genetic distance
* s03_malagasy_pca: PCA of Malagasy samples
* s04_full_pca: PCA of Malagasy samples with African and Asian references
* s05_admixture: Unsupervised ADMIXTURE analysis of global samples
* s05_admixture_supervised.sh: Shell script for supervised ADMIXTURE
* s05_b_supervised: Supervised ADMIXTURE analysis of Malagasy samples
* s06_a_chimpanzee_ref: preparation for f4 ratio statistics
* s06_b_f_stats: f3 and f4 statistics
* s06_c_f3_map: f3 statistics map
* s07_MALDER: MALDER analysis for dating waves of genetic admixture
* s07a_convertf.par: Parameter file for converting EIGENSTRAT to PLINK format
* s07a_convertf_merina_sep.par: Parameter file for converting EIGENSTRAT to PLINK format for Merina samples
* s07_b_MALDER_map: Map of MALDER results
* s08_FST: FST calculations between populations
* s09_data_source_map: Map of sample locations
* s10: Supplementary Information and Supplementary data 
