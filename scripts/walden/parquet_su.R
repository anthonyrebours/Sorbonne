##%######################################################%##
#                                                          #
####           Données Walden avec openalexR            ####
#                                                          #
##%######################################################%##

# Packages ----------------------------------------------------------------
library(tidyverse)
library(openalexR)
library(openalexPro)
library(arrow)

# Requête -----------------------------------------------------------------
api_url <- "https://api.openalex.org/works?page=1&filter=authorships.institutions.lineage:i39804081,publication_year:2018,type:types/article&sort=cited_by_count:desc&per_page=10&include_xpac=true"
json_path <- here::here("data", "walden", "json")
jsonl_path <- here::here("data", "walden", "json_extracted")
parquet_path <- here::here("data", "walden", "parquet")
  
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

su_2018_parquet <- 
  pro_request_jsonl_parquet(
    input_jsonl = jsonl_path,
    output = parquet_path,
    verbose = TRUE
  )


# Data process ------------------------------------------------------------
test <- open_dataset(parquet_path, partitioning = schema(page = utf8()))
authorships_data <- test %>% select(id, authorships)
authorships_test <- authorships_data %>% collect() %>% unnest(authorships, names_sep = "_")
batches <- su_2018_data %>% collect(batch_size = 10000)

