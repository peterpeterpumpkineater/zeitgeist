library(dplyr)
a <- select(data, column1, column2)          #select the columns you want from the data and save it in a#

colnames(data)[4] <- "new name"                  #rename column 4 of data to "new name"#
