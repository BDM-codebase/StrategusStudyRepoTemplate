################################################################################
# INSTRUCTIONS: The code below assumes you have access to a PostgreSQL database
# and permissions to create tables in an existing schema specified by the
# resultsDatabaseSchema parameter.
# 
# See the Working with results section
# of the UsingThisTemplate.md for more details.
# 
# More information about working with results produced by running Strategus 
# is found at:
# https://ohdsi.github.io/Strategus/articles/WorkingWithResults.html
# ##############################################################################

# Code for creating the result schema and tables in a PostgreSQL database
resultsDatabaseSchema <- "strategus_results"
analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
  fileName = "inst/Optima/LungCancer/strategusAnalysisSpecification.json"
)


resultsDatabaseConnectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "postgresql",
  server = Sys.getenv("CLOUD_POSTGRE_SERVER_DB"),
  port=Sys.getenv("CLOUD_POSTGRE_PORT"),
  user = Sys.getenv("CLOUD_BDM_DEVELOPER"),
  password = Sys.getenv("CLOUD_BDM_DEVELOPER_PWD")

)
# Create results data model -------------------------

# Use the 1st results folder to define the results data model
path <-file.path(Sys.getenv("STRATEGUS_ROOT_FOLDER"),"rdb","LungCancer")
resultsFolder <- list.dirs(path = path, full.names = T, recursive = F)[1]
resultsDataModelSettings <- Strategus::createResultsDataModelSettings(
  resultsDatabaseSchema = resultsDatabaseSchema,
  resultsFolder = resultsFolder
)

Strategus::createResultDataModel(
  analysisSpecifications = analysisSpecifications,
  resultsDataModelSettings = resultsDataModelSettings,
  resultsConnectionDetails = resultsDatabaseConnectionDetails
)