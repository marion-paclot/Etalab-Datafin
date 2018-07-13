library(shiny)
library(grid)
library(gridExtra)
library(plyr)
library(stringi)
# library(png)
library(XLConnect)

options(shiny.usecairo=T)
options(scipen = 999)

################################################################################
## Chargement des logos
# logo_datafin = readPNG("Logos/logo_Datafin.png")
# logo_etalab = readPNG("Logos/logo_Etalab.png")

################################################################################
## Chargement des données

donnees = list.files('./Donnees_traitees/', full.names = T)

rap = list()
for (d in donnees[grepl('RAP', donnees)]){
  cat('Chargement des données :', d, '\n')
  annee = gsub('.*_(.*)\\.csv', '\\1', d)
  rap[[annee]] = read.csv2(d, stringsAsFactors = T, dec = ',', encoding = 'utf-8')
}

plr = list()
for (d in donnees[grepl('PLR', donnees)]){
  cat('Chargement des données :', d, '\n')
  annee = gsub('.*_(.*)\\.csv', '\\1', d)
  plr[[annee]] = read.csv2(d, stringsAsFactors = T, dec = ',', encoding = 'utf-8')
}

cat('Chargement du CGE \n')
cge = read.csv2(donnees[grepl('CGE', donnees)], stringsAsFactors = T, dec = ',',
                encoding = 'utf-8')

# Liste des exerices dans le menu déroulant
col_balance = colnames(cge)[grepl('Balance.Sortie', colnames(cge))]
annees_col_balance = as.numeric(gsub('Balance.Sortie.(.*)', '\\1', col_balance))
annees_col_balance = annees_col_balance[annees_col_balance>2013]


