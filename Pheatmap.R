plate_1_raw <- read.csv("D:\\code\\Immunoprofiling\\Plate 1.csv")
plate_2_raw <-read.csv("D:\\code\\Immunoprofiling\\Plate 2.csv")
plate_3_raw <-read.csv("D:\\code\\Immunoprofiling\\Plate 3.csv")
plate_4_raw <-read.csv("D:\\code\\Immunoprofiling\\Plate 4.csv")
plate_5_raw <-read.csv("D:\\code\\Immunoprofiling\\Plate 5.csv")
plate_6_raw <-read.csv("D:\\code\\Immunoprofiling\\Plate 6.csv")

library(dplyr)
library(EnvStats)

all_plates_raw <-bind_rows(plate_1_raw, plate_2_raw, plate_3_raw, plate_4_raw, plate_5_raw, plate_6_raw)

all_plates_raw$CT <- as.numeric(all_plates_raw$CT)

averaged_all <- all_plates_raw %>%
  group_by(Sample.Name, Target.Name) %>%
  summarize(averaged_CT = mean(CT))

housekeeper <- averaged_all %>%
  filter(Target.Name %in% c("GAPDH","18s rRNA", "GUSB", "HPRT")) %>%
  group_by(Sample.Name) %>%
  summarize(HKGeomean = geoMean(averaged_CT))

averaged_all_without_HK <- averaged_all %>%
  filter(Target.Name != "GAPDH",Target.Name != "18s rRNA", Target.Name !="GUSB", Target.Name !="HPRT")

averaged_all_add_HK <-merge(averaged_all_without_HK, housekeeper, by = "Sample.Name")

averaged_all_add_HK$deltaCT<- averaged_all_add_HK$averaged_CT - averaged_all_add_HK$HKGeomean

averaged_all_add_HK_sep<- tidyr::separate(averaged_all_add_HK, Sample.Name, into = c("treatment", "cell_line", "donor", "timepoint", "hrs"), sep =" " , remove = F)


split_mock <-  averaged_all_add_HK_sep[1:108,]
split_ZIKA <- averaged_all_add_HK_sep[109:216,]

mergeddct <- merge(split_ZIKA, split_mock, by = c("cell_line", "donor", "timepoint", "hrs", "Target.Name"))

mergeddct$ddCT <- mergeddct$deltaCT.x - mergeddct$deltaCT.y

mergeddct$foldchange <- 2^-(mergeddct$ddCT)

plot_data <- mergeddct[,c(6,1,2,3,4,5,17)]

plot_data <- plot_data %>%
  filter(Target.Name != "IL10")


##Heat map test##

library(reshape2)
library(viridisLite)


### https://cran.r-project.org/web/packages/viridis/vignettes/intro-to-viridis.html ###
###http://slowkow.com/notes/heatmap-tutorial/###

dat1<- filter(plot_data, timepoint == "72")

dat1<- dat1[,c(1,6,7)]
  
dat2 <- tidyr::spread(dat1, Sample.Name.x ,foldchange)

dat2 <- data.frame(dat2[,-1],row.names = dat2[,1])

dat2 <- as.matrix(dat2)


### heatmap 72 hrs only###
library(pheatmap)

pheatmap::pheatmap(mat = log10(dat2),
                   border_color = NA,
                   color = inferno(100),
                   cluster_rows = FALSE, 
                   cluster_cols = FALSE)

dat24 <-  filter(plot_data, timepoint == "24")
dat24<- dat24[,c(1,6,7)]
dat24 <- tidyr::spread(dat24, Sample.Name.x ,foldchange)
dat24 <- data.frame(dat24[,-1],row.names = dat24[,1])
dat24 <- as.matrix(dat24)



###heatmap 24 hrs only###
pheatmap::pheatmap(mat = log10(dat24),
                   border_color = NA,
                   color = inferno(100),
                   cluster_rows = FALSE, 
                   cluster_cols = FALSE)

data_total <- plot_data[,c(1,6,7)]
data_total <- tidyr::spread(data_total, Sample.Name.x ,foldchange)
data_total <- data.frame(data_total[,-1],row.names = data_total[,1])


###rename###
data_total <- dplyr::rename(data_total, Ecto_423_72_HRS = ZIKA.ECTO.423.72.HRS,
              Ecto_439_24_HRS = ZIKA.ECTO.439.24.HRS,
              Ecto_439_24_HRS_2 = ZIKA.ECTO.439.24.HRS_2,
              Ecto_439_72_HRS = ZIKA.ECTO.439.72.HRS,
              Endo_411_72_HRS = ZIKA.ENDO.411.72.HRS,
              Endo_427_72_HRS = ZIKA.ENDO.427.72.HRS,
              Vag_246_72_HRS = ZIKA.VAG.246.72.HRS,
              Vag_429_24_HRS = ZIKA.VAG.429.24.HRS,
              Vag_429_72_HRS = ZIKA.VAG.429.72.HRS)

###rearrange position###
data_total <- data_total[c(2,3,8,9,7,4,1,5,6)]
data_total <- data_total[c(2,3,4,7,11,5,8,6,9,10,1),]


data_total <- as.matrix(data_total)

###heatmap total###
pheatmap::pheatmap(mat = log2(data_total),
                   border_color = NA,
                   color = inferno(100),
                   cluster_rows = FALSE, 
                   cluster_cols = FALSE)

###drop duplicated sample###
data_total_1 <- data_total[,2:9]
data_total_1 <-as.data.frame(data_total_1)
data_total_1 <-dplyr::rename(data_total_1, Ecto_439_24_HRS = Ecto_439_24_HRS_2)



data_total_1 <-data_total_1[c(2,1,5,7,3,6,8,4)]

data_total_1 <-as.matrix(data_total_1)

pheatmap::pheatmap(mat = log2(data_total_1),
                   border_color = NA,
                   color = inferno(100),
                   cluster_rows = FALSE, 
                   cluster_cols = FALSE)


###ADD TNF AND IL1A ###
a <- read.csv("D:\\code\\TNF\\il1a_tnfa.csv")

a <- plater::add_plate(a, "D:\\code\\TNF\\plate.csv", "Well.Position")

library(dplyr)

a$CT <- as.numeric(as.character(a$CT))

b <- a %>%
  group_by(tissue, Sample.Name, Target.Name) %>%
  summarise(CT = mean(CT))

b[17,4] <- 35.972
b[3,4] <- 32.134

cz <- b %>%
  filter(Sample.Name == "ZIKA")
cm <- b %>%
  filter(Sample.Name == "MOCK")

c <- cbind(cz, cm)

c$HKgeomean_zika <- c(20.585125, 20.585125, 21.633625, 21.633625, 22.002125, 22.002125, 20.8675, 20.8675, 20.8145, 20.8145)
c$HKgeomean_mock <- c(20.5245, 20.5245, 21.573, 21.573, 21.086125, 21.086125, 20.55025, 20.55025, 20.271875, 20.271875)

c$dCTZ <- c$CT - c$HKgeomean_zika
c$dCTM <- c$CT1 - c$HKgeomean_mock

c$ddCT <- c$dCTZ - c$dCTM

c$fold_change <- 2^(-c$ddCT)

library(ggplot2)

c[9,1] <- "Vag 429"
c[10,1] <- "Vag 429"

ggplot(c, aes(tissue, fold_change)) +
  geom_point(aes(col = Target.Name))

d <- c[c(1,3,14)]

d <- tidyr::spread(d, tissue, fold_change)

d <-data.frame(d)
d <- data.frame(d[,-1], row.names = d[,1])

colnames(d) <- c("Ecto_423_72_HRS", "Endo_411_72_HRS", "Endo_427_72_HRS", "Vag_246_72_HRS", "Vag_429_72_HRS")

data_combine <- data.frame(data_total_1)

data_combine2 <- bind_rows(data_combine, d)

row.names(data_combine2) <- c("CCL5","CXCL10","CXCL11","IFNB1","IRF7","CXCL9","IFNL2","IFNA1","IL1B","IL1RN","CCL2", "IL1A","TNF")

data_combine2 <- as.matrix(data_combine2)


pheatmap::pheatmap(mat = log2(data_combine2),
                   border_color = NA,
                   color = inferno(100),
                   cluster_rows = FALSE, 
                   cluster_cols = FALSE)

data_wo_24 <- data_combine2[,3:8]
data_rearranged <- data_wo_24[,c(2,5,1,4,3,6)]

data_rearranged <- data.frame(data_rearranged)

data_rearranged$HSV_Vaginal_8hrs <- c(1.085693, 0.992858, 0.983455503, NA,0.94056304,NA,NA,NA,1.436835013,0.555808846,NA,10.73432748,NA)


colnames(data_rearranged) <- c("Endo 411", "Endo 427", "Ecto 439", "Ecto 423", "Vag 429", "Vag 246", "Vag pool")

data_rearranged <- as.matrix(data_rearranged)

###see exel for calculation###
data_rearranged[12,3] <- 2.3021806140522
data_rearranged[13,3] <- 2.25479985844315


rowname <- colnames(data_rearranged)

annotate_col <- data.frame(Infection = c(rep("ZIKA 72 hrs", times = 6), "HSV2 8 hrs"), Cell_Type = c("Endocervical","Endocervical","Ectocervical","Ectocervical","Vaginal","Vaginal","Vaginal") )

rownames(annotate_col) = colnames(data_rearranged)


ann_colors = list(
  Infection = c(`ZIKA 72 hrs` = "#1B9E77", `HSV2 8 hrs` = "#D95F02"),
  Cell_Type = c(Endocervical = "#66c2a5", Ectocervical = "#fc8d62", Vaginal = "#8da0cb"))

tiff('test.tiff', width = 6, height = 5,unit = "in", res = 300)

pheatmap::pheatmap(mat = log2(data_rearranged),
                   border_color = NA,
                   color = inferno(100),
                   cluster_rows = F, 
                   cluster_cols = F,
                   annotation_col = annotate_col,
                   annotation_colors = ann_colors,
                   breaks = seq(-3, 10,length.out=101))

dev.off()   ### make sure the device is not turned off otherwise the plot wouldn't show sometimes ###





