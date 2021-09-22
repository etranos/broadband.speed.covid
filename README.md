# Working from home and digital divides: resilience during the pandemic

[Hannah Budnitz](https://www.tsu.ox.ac.uk/people/hbudnitz.html)<sup>1</sup> and [Emmanouil Tranos](https://etranos.info/)<sup>2</sup>\* 

<sup>1</sup> Transport Studies Unit, University of Oxford,
[hannah.budnitz@ouce.ox.ac.uk](mailto:hannah.budnitz@ouce.ox.ac.uk)
[@HBudnitz](https://twitter.com/hbudnitz)

<sup>2</sup> University of Bristol and The Alan Turing Institute, [e.tranos@bristol.ac.uk](mailto:e.tranos@bristol.ac.uk), [@emmanouiltranos](https://twitter.com/emmanouiltranos)

\* corresponding author

This is the depository for the 'Working from home and digital divides: resilience during the pandemic' paper.

## Abstract

This paper offers a new perspective on telecommuting from the viewpoint of the complex web of digital divides. Using the UK as a case study, this paper studies how the quality and reliability of internet services, as reflected in *experienced* internet upload speeds during the spring 2020 lockdown, may reinforce or redress the spatial and social dimensions of digital divisions. Fast, reliable internet connections are necessary for the population to be able to work from home. Although not every place hosts individuals in occupations which allow for telecommuting nor with the necessary skills to effectively use the internet to telecommute, good internet connectivity is also essential to local economic resilience in a period like the current pandemic. Employing data on individual broadband speed tests and state-of-the-art time-series clustering methods, we create clusters of UK local authorities with similar temporal signatures of experienced upload speeds. We then associate these clusters of local authorities with their socioeconomic and geographic characteristics to explore how they overlap with or diverge from the existing economic and digital geography of the UK. Our analysis enables us to better understand how the spatial and social distribution of both occupations and online accessibility intersect to enable or hinder the practice of telecommuting at a time of extreme demand.

## Reproduce the analysis

1. `/src/Data_Spatial.Rmd` creates a tidy data set: `/data/temp/TSbb19_20sp.csv`

2. `/src/ts_clusters_k9.Rmd` applies the time-series clustering for k = 9 and produces:

    - `/data/temp/clusters_nodiff.csv` based on the level data used for the next step

    - `/data/temp/clusters.csv`, which also includes clusters based on the 2019-2020 difference not used here
    
    - `/data/temp/clusters_up2019.csv` the 2019 clusters for Appendix 2 

    - `/paper/v2_taylor_francis/figures/map.up.clusters.png` clusters map (Figure 4)

3. `/src/descriptive_Clusters.Rmd` provides descriptive statistics for the clusters and:

    - speed test plots for 2019 and 2020 (Figure 1 and 2)

    - time variation plots for 2019 and 2020 (Figure 3)

4. `/src/LA_Clusters_k9.Rmd` performs the auxiliary regression.
It loads the data created from the previous `LA_CLusers.Rmd` based on k=9.
It creates:

    - the data for regressions as a backup `/data/temp/data_for_aux_k9.csv`

    - all models are saved in `/data/temp/LAs_Clusters_k9.RData`, which is then used in the paper `.Rmd` file
    to produce Tables 2 and 3.

5. `paper/v2_taylor_francis/broadband.speed.covid.Rmd` is the paper .Rmd. It uses:

    - the `.png` files for the plots (`/paper/v2_taylor_francis/figures`)

    - the `/data/temp/LAs_Clusters_k9.RData` for the tables for the tables, and

    - `/data/temp/clusters_nodiff.csv` for Appendix
    
6. `/src/online_appendix.Rmd` for the [Supplemental Material](https://etranos.info/lad_upload_clusters/)
