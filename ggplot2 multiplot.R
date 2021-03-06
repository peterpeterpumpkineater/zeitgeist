
pa <- read.csv("C:\\Users\\ruofaw\\Desktop\\plaque assay.csv")
dd <- read.csv("C:\\Users\\ruofaw\\Desktop\\ddpcr.csv")

library(dplyr)

avg_pa <- pa %>%
  group_by(sample, tp) %>%
  summarize(value = mean(value))

avg_d <- dd %>%
  group_by(sample, tp) %>%
  summarize(value = mean(value))

###correct data with only 2 data points###
avg_pa[11,3] <- 42375
avg_pa[13,3] <- 900
avg_pa[14,3] <- 23500
avg_pa[16,3] <- 38500
avg_pa[19,3] <- 32500
avg_pa[15,3] <- 42375
avg_pa[20,3] <- 38500

avg_d[16,3] <- 9306338

avg_pa$assay <- "plaque"
avg_d$assay <- "ddpcr"

comp <- rbind(avg_pa, avg_d)

comp$value <- as.numeric(comp$value)
###plot###

library(ggplot2)

a <- ggplot(comp, aes(tp, value))+
  geom_point(aes(col = assay)) +
  scale_y_log10() +
  scale_x_discrete(limits = c("3 hr", "24 hr", "48 hr", "72 hr", "144 hr")) +
  geom_boxplot(aes(col=assay), alpha = 0.1) +
  xlab("timepoint") +
  ylab("ZIKA RNA copies / Virion") +
  ggtitle("ddPCR vs Plaque Assay") +
  theme(plot.title = element_text(hjust = 0.5))

b<- ggplot(comp, aes(tp, value))+
  geom_point(aes(col = assay)) +
  scale_x_discrete(limits = c("3 hr", "24 hr", "48 hr", "72 hr", "144 hr")) +
  geom_boxplot(aes(col=assay), alpha = 0.1) +
  xlab("timepoint") +
  ylab("ZIKA RNA copies / Virion") +
  ggtitle("ddPCR vs Plaque Assay") +
  theme(plot.title = element_text(hjust = 0.5))

c<-  ggplot(comp, aes(tp, value))+
  geom_jitter(aes(col = assay)) +
  scale_y_log10() +
  scale_x_discrete(limits = c("3 hr", "24 hr", "48 hr", "72 hr", "144 hr")) +
  geom_boxplot(aes(col=assay), alpha = 0.1) +
  xlab("timepoint") +
  ylab("ZIKA RNA copies / Virion") +
  ggtitle("ddPCR vs Plaque Assay") +
  theme(plot.title = element_text(hjust = 0.5))

d<- ggplot(comp, aes(tp, value))+
  geom_jitter(aes(col = sample, shape = assay)) +
  scale_shape_manual(values = c(16, 1)) +
  scale_y_log10() +
  scale_x_discrete(limits = c("3 hr", "24 hr", "48 hr", "72 hr", "144 hr")) +
  xlab("timepoint") +
  ylab("ZIKA RNA copies / Virion") +
  ggtitle("ddPCR vs Plaque Assay") +
  theme(plot.title = element_text(hjust = 0.5))

### Pearson Analysis###


comp2 <- filter(comp, tp != "24 hr" & tp != "3 hr")

comp2wide <- tidyr::spread(comp2, assay, value)

e<- ggplot(comp2wide, aes(plaque, ddpcr)) +
  geom_point(aes(col = sample)) +
  geom_smooth(method = "lm")+
  scale_x_log10()+
  scale_y_log10()


### without 3 hrs time point ###

comp3 <- filter(comp, tp != "3 hr")
comp3wide <- tidyr::spread(comp3, assay, value)
comp3wide$tp <- factor(comp3wide$tp, levels = c("24 hr", "48 hr", "72 hr", "144 hr"))

f<-  ggplot(comp3wide, aes(plaque, ddpcr)) +
  geom_point(aes(col = sample, shape = tp)) +
  scale_x_log10()+
  scale_y_log10()+
  geom_smooth(method = "lm")+
  ggtitle("Plaque Assay vs ddPCR Correlation") +
  xlab("PFU)") +
  ylab("ZIKA RNA copies")+
  theme(plot.title = element_text(hjust = 0.5)) +
  annotate("text", x = 100, y = 20000000, hjust = 0, label = "Pearson's R = 0.6186862\np-value = 0.0002681", size = 3)

### all ###
comp4wide <- tidyr::spread(comp, assay, value)

g<-  ggplot(comp4wide, aes(plaque, ddpcr)) +
  geom_point(aes(col = sample)) +
  scale_x_log10()+
  scale_y_log10()+
  geom_smooth(method = "lm")




# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

multiplot(a, b, c, d, cols=2)







### see details about changing shapes and stuff at: www.sthda.com/english/wiki/ggplot2-point-shapes 
http://www.cookbook-r.com/Graphs/Multiple_graphs_on_one_page_(ggplot2)/
###




