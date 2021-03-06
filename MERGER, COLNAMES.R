SEZIKA <- read.csv("C:\\Users\\ruofaw\\Desktop\\SE + ZIKA\\050918.csv")

ZIKA <- SEZIKA[1:64,]
RPP30 <- SEZIKA[65:128,]



### MERGER TWO DOCUMENTS BY SHARED COLUMN ###
merged <- merge(ZIKA, RPP30, by = "Well")





###CHANGE COLUMN NAME###

colnames(merged)[4]<- "ZIKA per 20 uL Well"
colnames(merged)[7]<- "RPP30 per 20 uL Well"

merged_1 <- merged[c(1,4,7)]

merged_2 <- tidyr::separate(merged_1, Well, into = c("x", "y"), sep = "0", remove = F)

SE_ZIKA_ONLY <- dplyr::filter(merged_2, y != c("7", "8"))

SE_ZIKA_plate <- plater::add_plate(SE_ZIKA_ONLY, ("C:\\Users\\ruofaw\\Desktop\\SE + ZIKA\\plate.csv"), "Well")

library(dplyr)

SE_ZIKA_avg <- SE_ZIKA_plate %>%
  group_by(order) %>%
  summarise(Zaveraged = mean(`ZIKA per 20 uL Well`), RPP30 = mean(`RPP30 per 20 uL Well`))
  
SE_ZIKA_avg[20,3] <- 740


SE_ZIKA_avg$ZIKA_ori_conc <- (SE_ZIKA_avg$Zaveraged/5)*100
SE_ZIKA_avg$RPP30_ori_conc <- (SE_ZIKA_avg$RPP30/5)*100


SE_ZIKA_avg$ZIKA_per_RPP30 <- SE_ZIKA_avg$ZIKA_ori_conc/SE_ZIKA_avg$RPP30_ori_conc

id<-read.csv("C:\\Users\\ruofaw\\Desktop\\SE + ZIKA\\id.csv")

SE_ZIKA_ID <- cbind(SE_ZIKA_avg, id)

plot_SE_ZIKA <- SE_ZIKA_ID[c(8, 6)]

plot_SE_ZIKA <- tidyr::separate(plot_SE_ZIKA, ID, sep = " ", into = c("a", "b", "c", "d"), remove = F)

library(ggplot2)

ggplot(plot_SE_ZIKA, aes(d, ZIKA_per_RPP30)) +
  geom_point() +
  geom_boxplot()+
  facet_grid(~b)
 

### ZIKA Stock RNA DATA ###


ZIKA_stock <- dplyr::filter(merged_2, y == c("7", "8"))
ZIKA_stock <- ZIKA_stock[c(1,2,3,4)]

ZIKA_stock <- ZIKA_stock[3:14,]

stock_cal <- ZIKA_stock %>%
  group_by(x) %>%
  summarise(ZIKA_per_20uL = mean(`ZIKA per 20 uL Well`))
  
  
stock_cal$dilution <- c(1/5000,1/10000,1/50000,1/100000,1/500000,1/1000000)
  
ggplot(stock_cal, aes(dilution, ZIKA_per_20uL)) +
  geom_point() +
  scale_x_log10()+
  scale_y_log10() +
  geom_smooth(method = "lm", se = F)
  
  

