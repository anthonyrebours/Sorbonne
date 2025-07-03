# Extraction des documents HAL affiliés à Sorbonne université dans OpenAlex
  
# Author: Cellule scientométrie - BSU
# Version: 2025-06-30

# Packages
library(tidyverse)
library(openalexR)
library(openalexPro)
library(data.table)

# Paramètres
  # Sorbonne université et institutions connexes
su_chu <- 
  c(
    "i39804081",
    "i4210121705",
    "i4210102928",
    "i4210166768", 
    "i4210153132", 
    "i4210134887",
    "i4210090185", 
    "i2801203653",  
    "i4210086685"
  )


# ============================================================================

# Requête OpenAlex sous format parquet
query <- 
  oa_query(
    entity = "works",
    authorships.institutions.lineage = su_chu,
    primary_location.source.id = "s4306402512"
  ) %>% 
  pro_request(verbose = TRUE) %>% 
  source_to_parquet(corpus = "hal_su")



