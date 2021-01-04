# Working from home and digital divides: resilience during the pandemic

Hannah Budnitz[^1], Emmanouil Tranos[^2][^3]*

[^1]: Transport Studies Unit, University of Oxford, UK

[^2]: School of Geographic Sciences, University of Bristol, UK

[^3]: The Alan Turing Institute, UK

\* corresponding author: Emmanouil Tranos, email: e.tranos@bristol.ac.uk

This paper offers a new perspective on telecommuting from the viewpoint of the complex web of digital divides. Using the UK as a case study, this paper studies how the quality and reliability of internet services, as reflected in *experienced* internet upload speeds during the spring 2020 lockdown, may reinforce or redress the spatial and social dimensions of digital divisions. Fast, reliable internet connections are necessary for the population to be able to work from home. Although not every place hosts individuals in occupations which allow for telecommuting nor with the necessary skills to effectively use the internet to telecommute, good internet connectivity is also essential to local economic resilience in a period like the current pandemic. Employing data on individual broadband speed tests and state-of-the-art time-series clustering methods, we create clusters of UK local authorities with similar temporal signatures of experienced upload speeds. We then associate these clusters of local authorities with their socioeconomic and geographic characteristics to explore how they overlap with or diverge from the existing economic and digital geography of the UK. Our analysis enables us to better understand how the spatial and social distribution of both occupations and online accessibility intersect to enable or hinder the practice of telecommuting at a time of extreme demand.

## Reproduce the analysis

1. /src/Data_Spatial.Rmd creates a tidy data set: /data/temp/TSbb19_20sp.csv

2. /src/ts_clusters.Rmd applies the time-series clustering and produces:

    - /data/temp/clusters_nodiff.csv based on the level data used for the next step

    - /data/temp/clusters.csv, which also includes clusters based on the 2019-2020 difference not used here

    - clusters map (Figure 5)

3. /src/descriptive_Clusters.Rmd provides descriptive statistics for the clusters and:

    - speed test plots for 2019 and 2020 (Figure 1 and 2)

    - time variation plots for 2019 and 2020 (Figure 3 and 4)

4. /src/LA_Clusters.Rmd performs the auxiliary regression.
It creates:

    - the data for regressions as a backup /data/temp/data_for_aux.csv

    - all models are saved in /data/temp/LAs_Clusters.RData, which is then used in the paper .Rmd file
    to produce Tables 2 and 3.

5. paper/v1/broadband.speed.covd.Rmd is the paper .Rmd. It uses:

    - the .png files for the plots (/paper/v1/figures)

    - the /data/temp/LAs_Clusters.RData for the tables for the tables, and

    - /data/temp/clusters_nodiff.csv for Appendix 1
