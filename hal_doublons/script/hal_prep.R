# Préparation des données HAL
  
# Author: Cellule scientométrie - BSU
# Version: 2025-06-30
  
# Packages
library(tidyverse)
library(data.table)
library(arrow)

# Import des données
hal <- open_dataset(here::here("hal_su"))
# ============================================================================

# Extraction des données sous format data.table
hal_dt <- 
  as.data.table(
    hal %>% 
      select(
        "id",
        "title",
        "publication_year",
        "doi",
        "type",
        "authorships",
        "primary_location",
        "primary_topic",
        "updated_date",
        "created_date"
      ) %>% 
      collect()
  )


# Sélection des variable nécessaires
hal_dt <- 
  hal_dt %>%
  select(
    "id",
    "title",
    "doi",
    "type",
    "publication_year", 
    "authorships", 
    "primary_location" = "primary_location.source.display_name",
    "landing_page_url" = "primary_location.landing_page_url",
    "primary_topic" = "primary_topic.display_name",
    "subfield" = "primary_topic.subfield.display_name",
    "field" = "primary_topic.field.display_name",
    "domain" = "primary_topic.domain.display_name",
    "updated_date",
    "created_date"
  )

# Désimbriquation de la variable authorships
hal_dt <- hal_dt %>% unnest(authorships)

hal_dt <- 
  hal_dt %>% 
  select(
    -c(
      "author_position",
      "institutions",
      "countries",
      "is_corresponding",
      "raw_author_name",
      "raw_affiliation_strings",
      "affiliations"
    )
  )

hal_dt <-
  hal_dt %>% 
  unnest(author, names_sep = "_") 

hal_dt <- 
  hal_dt %>% 
  select(
    -c(
      "author_id",
      "author_orcid"
    )
  )

hal_dt <- 
  hal_dt %>% 
  group_by(id) %>% 
  mutate(author_display_name = paste(author_display_name, collapse = ", ")) 

hal_dt <- hal_dt %>% distinct()

# Export 
hal_dt %>% write_parquet(here::here("hal_doublons", "data", "hal.parquet"))


