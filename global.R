# Préparation des jeux de données

options(scipen = 999)

lire_liste_fichiers = function(fichier){
  if (grepl('PLR', fichier)){
    donnees = read.csv2(fichier, stringsAsFactors = F, dec = ",", skip = 4)
    if ('Code.Programme' %in% colnames(donnees)){
      colnames(donnees) = gsub('^Programme$', 'Libellé.programme', colnames(donnees))
      colnames(donnees) = gsub('^Code.Programme$', 'Programme', colnames(donnees))
      }

    } else{
      donnees = read.csv2(fichier, stringsAsFactors = F, dec = ",")
    }
  
  for (c in colnames(donnees)){
    donnees[,c] = gsub('([0-9]+) ([0-9]+)', '\\1\\2', donnees[,c])
    donnees[,c] = gsub('([0-9]+) ([0-9]+)', '\\1\\2', donnees[,c])
    donnees[,c] = gsub('([0-9]+) ([0-9]+)', '\\1\\2', donnees[,c])
  }

  # Imputation de COD_PGM quand nom disponible alors que numéro.indicateur est présent.
  if (all(c('COD_PGM', 'Numéro.indicateur') %in% colnames(donnees))){
    donnees[, 'COD_PGM'] = ifelse(donnees[, 'COD_PGM'] ==  '', 
                                  gsub('([A-Z]+[0-9]+).*', '\\1', donnees[,'Numéro.indicateur']), 
                                  donnees[, 'COD_PGM'])
    
    dico = unique(donnees[, c('COD_PGM', 'Programme')])
    dico = dico[dico$Programme != '',]
    donnees[, 'Programme'] = dico[match(donnees[, 'COD_PGM'], dico[, 'COD_PGM']), 'Programme']
  }
  
  return(assign(fichier, donnees))
}



# CGE
cge = read.csv2("./Donnees/CGE/2012 - 2017_Balances des comptes de l'État.csv", 
                stringsAsFactors = F, dec = ",")
cge$Programme = gsub('\\s+', '', cge$Programme)
cge$Programme = gsub('^0', '', cge$Programme)

col_balance = colnames(cge)[grepl('Balance.Sortie', colnames(cge))]
annees_col_balance = as.numeric(gsub('Balance.Sortie.(.*)', '\\1', col_balance))
annees_col_balance = annees_col_balance[annees_col_balance>2013]

# PLR
plr_files = list.files('./donnees/PLR', full.names = T)
plr = Map(lire_liste_fichiers, plr_files)
names(plr) = gsub('.*PLR([0-9]+)-.*', '\\1', names(plr))

# RAP
rap_files = list.files('./donnees/RAP', full.names = T)
rap = Map(lire_liste_fichiers, rap_files)
names(rap) = gsub('.*PERF_SSI_RAP_([0-9]+)_.*', '\\1', names(rap))

