# Serveur Application Datafin données financières de l'Etat

shinyServer(function(input, output, session) {
  
  ### Exercice
  exercice = reactive({
    exercice = input$exercice
    return(exercice)
  })
  
  ### Mission
  mission = reactive({
    mission = input$mission
    return(mission)
  })
  
  ### Programmes de la mission.
  programmes = reactive({
    rap_encours = rap[[input$exercice]]
    code_pgm = rap_encours[rap_encours$Mission == mission(),c('COD_PGM', 'Programme')]

    code_pgm = unique(code_pgm)
    code_pgm= code_pgm[code_pgm$COD_PGM != '',]
    return(list(code_pgm = code_pgm$COD_PGM, nom_pgm = code_pgm$Programme))
  })
  
  # Menu déroulant mission, adaptation après sélection de l'exercice.
  missions_choix = observe({
    exercice = input$exercice
    choix = unique(rap[[exercice]]$Mission)
    updateSelectizeInput(session, 'mission', choices =choix, server = TRUE)
    })

  # Boite avec informations
  output$liste_programmes <- renderText({
    pg_df = data.frame(nom = programmes()$nom_pgm, code = programmes()$code_pgm)
    if (nrow(pg_df) == 0){
      return('Choisir une mission')    
      }
    
    pg_df$complet_pgm = paste0(pg_df$nom, ' (', pg_df$code, ')')
    pg_df = pg_df[order(pg_df$code),]
    paste0(paste0(pg_df$complet_pgm, collapse = '\n'))
  })
  
  output$sources <- renderText({
    paste0("Les sources utilisées par cette application sont toutes disponibles sur le site data.gouv.fr.\n\n",
           "CGE : 2012 - 2017_Balances des comptes de l'État.csv\n\n",
           "PLR : \n", 
           "\tPLR2014-Exec-Msn_CP.csv\n", 
           "\tPLR2015-Exec-Min_CP-BG.csv\n",
           "\tPLR2016-Exec-Min_CP-BG.csv\n", 
           "\tPLR2017-Exec-Min_CP-BG.csv\n\n",
           "RAP : conversion en csv de certains fichiers xls\n",
           "\tPERF_SSI_RAP_2012_20131219_123202265\n",
           "\tPERF_SSI_RAP_2013_20141219_103540142\n",
           "\tPERF_SSI_RAP_2014_20151222_181223175\n",
           "\tPERF_SSI_RAP_2015_DATAGOUV\n",
           "\tPERF_SSI_RAP_2016_DATAGOUV\n",
           "\tPERF_SSI_RAP_2017_20180517_122845769"
           )
  })
  
  # Filtrage des données pour affichage dans les onglets
  
  donnees_filtrees = reactive({

    if (mission() == ''){
      return(list(donnees_plr = NULL, donnees_rap = NULL, donnees_cge = NULL))
    }
    
    code_pgm = programmes()$code_pgm
    code_pgm_ssP =gsub('P(.*)', '\\1', code_pgm)
    
    # RAP
    donnees_rap = rap[[exercice()]]
    donnees_rap = subset(donnees_rap, COD_PGM %in% code_pgm)
    colnames(donnees_rap) = gsub('\\.', ' ', colnames(donnees_rap))

    # PLR
    donnees_plr = plr[[exercice()]]
    donnees_plr = subset(donnees_plr, Programme %in% code_pgm_ssP)
    colnames(donnees_plr) = gsub('\\.', ' ', colnames(donnees_plr))

    # CGE
    donnees_cge = cge
    col_cge = colnames(donnees_cge)
    col_balance = col_cge[grepl('Balance.Sortie', col_cge)]
    autres_col = col_cge[! grepl('Balance.Sortie', col_cge)]
    col_balance_encours = col_balance[grepl(exercice(), col_balance)]
    donnees_cge = donnees_cge[, c(autres_col, col_balance_encours)]

    ###Filtrage sur le programme
    donnees_cge = subset(donnees_cge, Programme %in% code_pgm_ssP)
    colnames(donnees_cge) = gsub('\\.', ' ', colnames(donnees_cge))

    return(list(donnees_plr = donnees_plr,
                donnees_rap = donnees_rap,
                donnees_cge = donnees_cge))
  })
  

  # Affichage des tableaux
  output$donnees_rap = renderDataTable({
    donnees_filtrees()[['donnees_rap']]
  })

  output$donnees_plr = renderDataTable({
    donnees_filtrees()[['donnees_plr']]
  })
  
  output$donnees_cge = renderDataTable({
    donnees_filtrees()[['donnees_cge']]
  })
  
  # Téléchargement des données
  output$downloadData <- downloadHandler(
    filename = function() {
      m = stri_trans_general(mission(), "Latin-ASCII")
      m = gsub(',', ' ', m)
      m = gsub('\\s+', ' ', m)
      paste0(m, '_', exercice(), '.xlsx')
    },
    content = function(file) {
      wb <- loadWorkbook(file,create = TRUE)

      createSheet(wb,"CGE")
      writeWorksheet(wb,data = donnees_filtrees()[['donnees_cge']], sheet = "CGE")
      setColumnWidth(wb, sheet = "CGE", column = 1:ncol(donnees_filtrees()[['donnees_cge']]), width = -1)
      
      createSheet(wb,"RAP")
      writeWorksheet(wb,data = donnees_filtrees()[['donnees_rap']], sheet = "RAP")
      setColumnWidth(wb, sheet = "RAP", column = 1:ncol(donnees_filtrees()[['donnees_rap']]), width = -1)
      
      createSheet(wb,"PLR")
      writeWorksheet(wb,data = donnees_filtrees()[['donnees_plr']], sheet = "PLR")
      setColumnWidth(wb, sheet = "PLR", column = 1:ncol(donnees_filtrees()[['donnees_plr']]), width = -1)
      
      saveWorkbook(wb)
    },
    contentType="application/xlsx"
    
  )
    
     
   
 
})

