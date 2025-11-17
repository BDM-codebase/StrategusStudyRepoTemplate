# -------------------------------------------------------
#                     PLEASE READ
# -------------------------------------------------------
#
# You must call "renv::restore()" and follow the prompts
# to install all of the necessary R libraries to run this
# project. This is a one-time operation that you must do
# before running any code.
#
# !!! PLEASE RESTART R AFTER RUNNING renv::restore() !!!
#
# -------------------------------------------------------
#renv::restore()

# ENVIRONMENT SETTINGS NEEDED FOR RUNNING Strategus ------------
Sys.setenv("_JAVA_OPTIONS"="-Xmx4g") # Sets the Java maximum heap space to 4GB
Sys.setenv("VROOM_THREADS"=1) # Sets the number of threads to 1 to avoid deadlocks on file system

##=========== START OF INPUTS ==========
# schema containing federated site omop data.The user (as identified in the connection details) will need to have read access to this database schema.
cdmDatabaseSchema <-"synthea_bdm"
# schema that will contain the analysis result. The user (as identified in the connection details) will need to have write access to this database schema.
workDatabaseSchema <- "strategus_results"

#folder where result will be recorded
outputLocation <- Sys.getenv("STRATEGUS_ROOT_FOLDER")

#Only used as a folder name for results from the study
databaseName <- "rdb"


dbUser <- Sys.getenv("CLOUD_BDM_DEVELOPER")

#database path in the form server/bdname
# bdmserver <-  Sys.getenv("CLOUD_POSTGRE_SERVER_DB")

# Create the connection details for your CDM
# More details on how to do this are found here:
# https://ohdsi.github.io/DatabaseConnector/reference/createConnectionDetails.html
 connectionDetails <- DatabaseConnector::createConnectionDetails(
   dbms = "postgresql",
   server = Sys.getenv("CLOUD_POSTGRE_SERVER_DB"),
   port=Sys.getenv("CLOUD_POSTGRE_PORT"),
   user = Sys.getenv("CLOUD_BDM_DEVELOPER"),
   password = Sys.getenv("CLOUD_BDM_DEVELOPER_PWD")

 )


minCellCount <- 5 #The minimum number of subjects contributing to a count before it can be included in results.

cohortTableName <- CohortGenerator::getCohortTableNames(cohortTable = "cohort") 






# For this example we will use the Eunomia sample data
# set. This library is not installed by default so you
# can install this by running:
#
# install.packages("Eunomia")
#connectionDetails <- Eunomia::getEunomiaConnectionDetails()

# You can use this snippet to test your connection
#conn <- DatabaseConnector::connect(connectionDetails)
#DatabaseConnector::disconnect(conn)

analysisName <- "LungCancer"
strategusWorkFolder <- file.path(outputLocation, databaseName, analysisName,"strategusWork")
strategusOutputFolder <- file.path(outputLocation, databaseName, analysisName,"strategusOutput")
##=========== END OF INPUTS ==========
analysisSpecifications <- ParallelLogger::loadSettingsFromJson(fileName = file.path("inst","Optima",analysisName,"strategusAnalysisSpecification.json")
)

# ====================================================================
# Creating execution settings
# ====================================================================
executionSettings <- Strategus::createCdmExecutionSettings(
  workDatabaseSchema = workDatabaseSchema, # database schema
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortTableNames = cohortTableName,
  workFolder = strategusWorkFolder,
  resultsFolder = strategusOutputFolder,
  minCellCount = minCellCount
)

if (!dir.exists(file.path(outputLocation, databaseName,analysisName))) {
  dir.create(file.path(outputLocation, databaseName,analysisName), recursive = T)
}
ParallelLogger::saveSettingsToJson(
  object = executionSettings,
  fileName = file.path(outputLocation, databaseName,analysisName, "executionSettings.json")
)

Strategus::execute(
  analysisSpecifications = analysisSpecifications,
  executionSettings = executionSettings,
  connectionDetails = connectionDetails
)