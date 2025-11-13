##%######################################################%##
#                                                          #
####          Données Sorbonne Université sous          ####
####           format parquet depuis OpenAlex           ####
#                                                          #
##%######################################################%##


# Packages ----------------------------------------------------------------
library(here)
library(tidyverse)
library(openalexPro)


# Requête -----------------------------------------------------------------
api_url <- "https://api.openalex.org/works?page=1&filter=authorships.institutions.lineage:i39804081,publication_year:2018-2024&sort=cited_by_count:desc&per_page=10&include_xpac=true"
json_path <- here("walden", "data", "json")
jsonl_path <- here("walden", "data", "json_extracted")
parquet_path <- here("walden", "data", "parquet")
  
su_2018 <- 
  pro_request(
    query_url = api_url,
    verbose = TRUE,  
    output = json_path
  ) 

su_2018_jsonl <- 
  pro_request_jsonl(
    input_json = json_path,
    output = jsonl_path,
    verbose = TRUE
  )

unlink(json_path, recursive = TRUE)

su_2018_parquet <- 
  pro_request_jsonl_parquet(
    input_jsonl = jsonl_path,
    output = parquet_path,
    verbose = TRUE
  )

unlink(jsonl_path, recursive = TRUE)




