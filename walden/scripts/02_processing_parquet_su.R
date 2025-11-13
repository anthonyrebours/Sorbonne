##%######################################################%##
#                                                          #
####    Manipulation données OpenAlex format parquet    ####
#                                                          #
##%######################################################%##



# Package et data path ----------------------------------------------------
library(tidyverse)
library(arrow)
library(data.table)
library(dtplyr)
library(tidyfast)

## Chemin d'accès à la base de données parquet
parquet_path <- here::here("walden", "data", "parquet")


# Data process ------------------------------------------------------------
su <- open_dataset(parquet_path, partitioning = schema(page = utf8()))

authorships_data <- su_2018_parquet %>% select(id, authorships) %>% as.data.table()
authorships_test <- authorships_data %>% unnest_longer(authorships, keep_empty = TRUE) %>% as.data.table()

institutions_data <- su_2018_parquet %>% select(id, institutions) %>% as.data.table()
institutions_test <- dt_unnest(institutions_data, institutions)

location <- su_2018_parquet %>% select(id, primary_location) %>% as.data.table()

topics <- su_2018_parquet %>% select(id, primary_topic) %>% as.data.table()