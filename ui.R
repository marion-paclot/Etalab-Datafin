# UI Application Datafin données financières de l'Etat

shinyUI(fluidPage(
  
  # Titre de l'application
  titlePanel("Informations relatives à une mission"),

  fluidRow(
    
    # Choix d'une année, d'une mission. Affichage en gros
    column(3,
           selectizeInput('exercice', "Sélection d'un exercice",
                          choices = annees_col_balance, 
                          selected = '', multiple = FALSE,
                          options = NULL, width = "100%")
           ,
           selectizeInput('mission', "Sélection d'une mission",
                          choices = NULL, multiple = FALSE, width = "100%")
    ),
    column(7, 
           h4('Liste des programmes associés à la mission'),
           h2(verbatimTextOutput("liste_programmes")),
           downloadButton("downloadData", label = "Téléchargement .xls"))
    ),
  mainPanel(width = 12,
            tabsetPanel(type = 'tabs',
                        tabPanel('CGE', br(), dataTableOutput('donnees_cge')),
                        tabPanel('RAP', br(), dataTableOutput('donnees_rap')),
                        tabPanel('PLR', br(), dataTableOutput('donnees_plr')),
                        tabPanel('Sources', br(), verbatimTextOutput('sources'))
                        
                        )
  )
))

