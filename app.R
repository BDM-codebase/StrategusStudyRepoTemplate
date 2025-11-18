################################################################################
# INSTRUCTIONS: The code below assumes you uploaded results to a PostgreSQL 
# database per the UploadResults.R script.This script will launch a Shiny
# results viewer to analyze results from the study.
#
# See the Working with results section
# of the UsingThisTemplate.md for more details.
# 
# More information about working with results produced by running Strategus 
# is found at:
# https://ohdsi.github.io/Strategus/articles/WorkingWithResults.html
# ##############################################################################

library(ShinyAppBuilder)
library(OhdsiShinyModules)

resultsDatabaseSchema <- "strategus_results"

# Specify the connection to the results database
 resultsConnectionDetails <- DatabaseConnector::createConnectionDetails(
   dbms = "postgresql",
   server = Sys.getenv("CLOUD_POSTGRE_SERVER_DB"),
   port=Sys.getenv("CLOUD_POSTGRE_PORT"),
   user = Sys.getenv("CLOUD_BDM_DEVELOPER"),
   password = Sys.getenv("CLOUD_BDM_DEVELOPER_PWD")

 )



# ADD OR REMOVE MODULES TAILORED TO YOUR STUDY
# shinyConfig <- initializeModuleConfig() |>
#   addModuleConfig(
#     createDefaultAboutConfig()
#   )  |>
#   addModuleConfig(
#     createDefaultDatasourcesConfig()
#   )  |>
#   addModuleConfig(
#     createDefaultCohortGeneratorConfig()
#   ) |>
#   addModuleConfig(
#     createDefaultCohortDiagnosticsConfig()
#   ) |>
#   addModuleConfig(
#     createDefaultCharacterizationConfig()
#   ) |>
#   addModuleConfig(
#     createDefaultPredictionConfig()
#   ) |>
#   addModuleConfig(
#     createDefaultEstimationConfig()
#   )


shinyConfig <- initializeModuleConfig() |>
  addModuleConfig(
    createDefaultAboutConfig()
  )  |>
  addModuleConfig(
    createDefaultDatasourcesConfig()
  )  |>
  addModuleConfig(
    createDefaultCohortGeneratorConfig()
  ) |>
  addModuleConfig(
    createDefaultCohortDiagnosticsConfig()
  )


# now create the shiny app based on the config file and view the results
# based on the connection 
ShinyAppBuilder::createShinyApp(
  config = shinyConfig, 
  connectionDetails = resultsConnectionDetails,
  resultDatabaseSettings = createDefaultResultDatabaseSettings(schema = resultsDatabaseSchema),
  title = "Strategus Event November 2025",
  studyDescription = "This study is showcasing the capabilities of running Strategus on NVFlare network"
)
