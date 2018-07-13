# Hackathon dataFin - 15 et 16 juin 2018

Ce projet a été développé dans le cadre du hackathon sur les données financières de l'Etat, qui s'est déroulé les 15 et 16 juin 2018 à l'Assemblée nationale.
La demande de la DGFip consistait à pouvoir filtrer trois types de données (CGE, PLR, RAP) par exercice et par mission. Il st ensuite possible de télécharger un fichier.xls contenant en 3 onglets les données filtrées correspondant aux programmes de la mission sélectionnée.

Une application R Shiny a été développée pour répondre à ce besoin.

Le répertoire contient un dossier de données, organisé en sous-dossiers par type de données. L'intégralité de ces données se trouve sur data.gouv.fr et son en open source. Des modifications mineures ont été apportées à ces fichiers de données, pour que le format de fichier reste stable d'une année sur l'autre : 
- conversion des fichiers .xls en .csv lorsqu'un csv n'était pas directement disponible
- lorsque le fichier contenait initialement une forme d'en-tête, avec quelques lignes vides, ajout de cet en-tête dans tous les fichiers ne le contenant pas.

Par ailleurs, on a trois scripts R : 
- un script *global.R* permettant de charger les données etles packages.
- un script *ui.R* correspondant à l'interface graphique de l'application
- un script *server.R* correspondant au filtrage des données avant affichage.

Le bouton Run App permet de lancer l'application.
