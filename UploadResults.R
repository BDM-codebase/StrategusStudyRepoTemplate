################################################################################
# INSTRUCTIONS: The code below assumes you have access to a PostgreSQL database
# and permissions to insert data into tables created by running the
# CreateResultsDataModel.R script. This script will loop over all of the
# directories found under the "results" folder and upload the results.
#
# This script also contains some commented out code for
# setting read-only permissions for a user account on the results schema.
# This is used when setting up a read-only user for use with a Shiny results
# viewer. Additionally, there is commented out code that will allow you to run
# ANALYZE on each results table to ensure the database is performant.
#
# See the Working with results section
# of the UsingThisTemplate.md for more details.
#
# More information about working with results produced by running Strategus
# is found at:
# https://ohdsi.github.io/Strategus/articles/WorkingWithResults.html
# ##############################################################################

# Code for uploading results to a Postgres database
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

# Setup logging ----------------------------------------------------------------
ParallelLogger::clearLoggers()
ParallelLogger::addDefaultFileLogger(
  fileName = "upload-log.txt",
  name = "RESULTS_FILE_LOGGER"
)
ParallelLogger::addDefaultErrorReportLogger(
  fileName = "upload-errorReport.txt",
  name = "RESULTS_ERROR_LOGGER"
)

# Upload Results ---------------------------------------------------------------
path <- file.path( Sys.getenv("STRATEGUS_ROOT_FOLDER"), "rdb", "LungCancer")
for (resultFolder in list.dirs(path = path, full.names = T, recursive = F)) {
  resultsDataModelSettings <- Strategus::createResultsDataModelSettings(
    resultsDatabaseSchema = resultsDatabaseSchema,
    resultsFolder = resultFolder,
  )

  Strategus::uploadResults(
    analysisSpecifications = analysisSpecifications,
    resultsDataModelSettings = resultsDataModelSettings,
    resultsConnectionDetails = resultsDatabaseConnectionDetails
  )
}

connection <- DatabaseConnector::connect(
  connectionDetails = resultsDatabaseConnectionDetails
)


# Optional scripts to set permissions and to analyze tables ------------------
# # Grant read only permissions to all tables
# sql <- "GRANT USAGE ON SCHEMA @schema TO @results_user;
# GRANT SELECT ON ALL TABLES IN SCHEMA @schema TO @results_user;
# GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA @schema TO @results_user;"
#
# message("Setting permissions for results schema")
# sql <- SqlRender::render(
#   sql = sql,
#   schema = resultsDatabaseSchema,
#   results_user = 'shinyproxy'
# )
# DatabaseConnector::executeSql(
#   connection = connection,
#   sql = sql,
#   progressBar = FALSE,
#   reportOverallTime = FALSE
# )
#
# # Analyze all tables in the results schema
# message("Analyzing all tables in results schema")
# sql <- "ANALYZE @schema.@table_name;"
# tableList <- DatabaseConnector::getTableNames(
#   connection = connection,
#   databaseSchema = resultsDatabaseSchema
# )
# for (i in 1:length(tableList)) {
#   DatabaseConnector::renderTranslateExecuteSql(
#     connection = connection,
#     sql = sql,
#     schema = resultsDatabaseSchema,
#     table_name = tableList[i],
#     progressBar = FALSE,
#     reportOverallTime = FALSE
#   )
# }
# 
# DatabaseConnector::disconnect(connection)

# Unregister loggers -----------------------------------------------------------
ParallelLogger::unregisterLogger("RESULTS_FILE_LOGGER")
ParallelLogger::unregisterLogger("RESULTS_ERROR_LOGGER")