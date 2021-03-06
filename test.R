### Amy Willis, October 2017

## A script to enable compiling, building and testing the CatchAll R package

## Create and set the working directory

directory <- "/Users/adw96/Documents/software/CatchAll" ## your local copy here
setwd(directory)

# Download some required packages
library(devtools)
library(roxygen2)
library(testthat)
library(knitr)
library(rstudioapi)
library(Rd2roxygen)
devtools::install_github("hadley/pkgdown")
library(pkgdown)
library(breakaway)
library(tidyverse)

rm(list = ls(all = T))

# to run CatchAll on the apples dataset from the package breakaway
build()
install()
library(CatchAll)
CatchAll(apples) 


## another test set
for (file in list.files("R/", full.names = T)) source(file)
CatchAll(apples)


#CatchAll:CatchAll(apples)
# 
create_package("CatchAll")
build()
install()
#rename to test.csv?2

test_data_set_1 <- read.csv("test.csv", header = F)
x <- CatchAll(test_data_set_1)
x[19:25, 1:5]
x[19:25, 12:14]

## To build the full site -- not yet!!
# roxygenise()
# roxygen_and_build(directory)
# install()
# build_site()
# check()
