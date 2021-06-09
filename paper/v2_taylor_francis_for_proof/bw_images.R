library(magick)

# convert Figures to bw
path.in <- "C:/Users/nw19521/OneDrive - University of Bristol/projects/broadband.speed.covid/paper/v2_taylor_francis_for_proof/figures"
path.out <- "C:/Users/nw19521/OneDrive - University of Bristol/projects/broadband.speed.covid/paper/v2_taylor_francis_for_proof/figures_for_word_submission"

# Fig 1
# fig1.path.in <- paste0(path.in, "/time.var.plot2020.png")
fig1.path.in <- paste0(path.in, "/Time Var 2020.tiff")
fig1 <- image_read(fig1.path.in)
fig1 <- fig1 %>% image_quantize(colorspace = 'gray')

fig1.path.out <- paste0(path.out, "/Fig1.tiff")

# opt. 1
# fig1
# tiff(fig1.path.out, res = 600)
# dev.off()

# opt. 2
# fig1
# ggsave(fig1.path.out, device='tiff', dpi=600)

#opt. 3 -- it works
image_write(fig1, path = fig1.path.out) #, format = "png")

# Fig 2
# fig2.path.in <- paste0(path.in, "/time.var.plot2019.png")
fig2.path.in <- paste0(path.in, "/TimeVar2019.tiff")
fig2 <- image_read(fig2.path.in)
fig2 <- fig2 %>% image_quantize(colorspace = 'gray')

fig2.path.out <- paste0(path.out, "/Fig2.tiff")

image_write(fig2, path = fig2.path.out, density = "600")
