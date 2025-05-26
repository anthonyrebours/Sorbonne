# Description
  

# Version: 2025-05-26
  
# Packages
library(tidyverse)
library(openalexR)

# Paramètres
  # Variables requête OpenAlex
oa_var <- 
  c(
    "id",
    "publication_year",
    "cited_by_count",
    "type",
    "primary_topic",
    "primary_location",
    "open_access",
    "grants",
    "sustainable_development_goals"
  )
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
  # Requête OpenAlex
su_query <- 
  list(
    entity = "works",
    authorships.institutions.lineage = su_chu,
    type = c("!paratext", "!peer-review", "!erratum"),
    publication_year = "2018-2024",
    options = list(select = oa_var),
    output = "list", 
    verbose = TRUE
  )
  # Export des données
export <- here::here("data", "su_publi.csv")
# ============================================================================

# Import des données
su_publi <- do.call(oa_fetch, su_query)
su_publi <- as.data.frame(do.call(rbind, su_publi))

# Retrait d'éventuels doublons
su_publi <- su_publi %>% distinct(id, .keep_all = TRUE)

# Formatage des données
su_publi <-
  su_publi %>%
  mutate(
    id = as.character(id),
    publication_year = as.integer(publication_year),
    cited_by_count = as.integer(cited_by_count),
    type = as.character(type)
  )

# Extraction des variables pertinentes à partir des listes
  # Liste primary_topic
su_publi <- su_publi %>% unnest_wider(primary_topic, names_sep = "_")
su_publi <- su_publi %>% unnest_wider(primary_topic_field, names_sep = "_")
su_publi <- su_publi %>% unnest_wider(primary_topic_subfield, names_sep = "_")
su_publi <- su_publi %>% unnest_wider(primary_topic_domain, names_sep = "_")
  # Liste primary_location
su <- su %>% unnest_wider(primary_location, names_sep = "_")
su <- su %>% unnest_wider(primary_location_source, names_sep = "_")
  # Liste open_access
su <- su %>% unnest_wider(open_access)
  # Liste grants
su_publi <- 
  # Liste sustainable_development_goals


# Export des données
su %>% rio::export(su_out)

