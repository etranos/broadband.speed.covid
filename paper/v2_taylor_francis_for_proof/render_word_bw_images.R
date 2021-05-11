library(rmarkdown)
library(magick)

# render to .Rmd to word
path <- "C:/Users/nw19521/OneDrive - University of Bristol/projects/broadband.speed.covid/paper/v2_taylor_francis_for_proof/broadband.speed.covid.Rmd"
render(path, word_document())

# convert Fig 1 to bw
path <- "C:/Users/nw19521/OneDrive - University of Bristol/projects/broadband.speed.covid/paper/v2_taylor_francis_for_proof/figures_for_word_submission"

fig1.path <- paste0(path, "/Fig1.png")

fig1 <- image_read(fig1.path)
fig1 <- fig1 %>% image_quantize(colorspace = 'gray')

image_write(fig1, path = fig1.path, format = "png")

# convert Fig 2 and 2 to bw
fig2.path <- paste0(path, "/Fig2.png")

fig2 <- image_read(fig1.path)
fig2 <- fig2 %>% image_quantize(colorspace = 'gray')

image_write(fig2, path = fig2.path, format = "png")
