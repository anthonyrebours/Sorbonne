# Import des publications (sans autheurs) de SU dans OpenAlex
  

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
su_out <- here::here("data", "su_publi.csv")
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
  # Liste sustainable_development_goals
su_publi <- su_publi %>% unnest_wider(sustainable_development_goals, names_sep = "_")
su_publi <- su_publi %>% unnest_wider(sustainable_development_goals_1, names_sep = "_")
su_publi <- su_publi %>% unnest_wider(sustainable_development_goals_2, names_sep = "_")
su_publi <- su_publi %>% unnest_wider(sustainable_development_goals_3, names_sep = "_")
su_publi <- su_publi %>% unnest_wider(sustainable_development_goals_4, names_sep = "_")
su_publi <- su_publi %>% unnest_wider(sustainable_development_goals_5, names_sep = "_")
  # Liste primary_topic
su_publi <- su_publi %>% unnest_wider(primary_topic, names_sep = "_")
su_publi <- su_publi %>% unnest_wider(primary_topic_field, names_sep = "_")
su_publi <- su_publi %>% unnest_wider(primary_topic_subfield, names_sep = "_")
su_publi <- su_publi %>% unnest_wider(primary_topic_domain, names_sep = "_")
  # Liste primary_location
su_publi <- su_publi %>% hoist(primary_location, "source")
su_publi <- su_publi %>% hoist(source, "display_name", "is_core", "type")
  # Liste open_access
su_publi <- su_publi %>% hoist(open_access, "is_oa", "oa_status")

# Sélection des données pertinentes
su_publi <- 
  su_publi %>% 
  select(
    id, 
    publication_year,
    cited_by_count,
    type,
    "topics" = primary_topic_display_name,
    "subfield" = primary_topic_subfield_display_name,
    "field" = primary_topic_field_display_name,
    "domain" = primary_topic_domain_display_name,
    "source" = display_name,
    "source_type" = type,
    "source_is_core" = is_core,
    is_oa,
    oa_status,
    "sdg_1_score" = sustainable_development_goals_1_score,
    "sdg_1_display_name" = sustainable_development_goals_1_display_name,
    "sdg_2_score" = sustainable_development_goals_2_score,
    "sdg_2_display_name" = sustainable_development_goals_2_display_name,
    "sdg_3_score" = sustainable_development_goals_3_score,
    "sdg_3_display_name" = sustainable_development_goals_3_display_name,
    "sdg_4_score" = sustainable_development_goals_4_score,
    "sdg_4_display_name" = sustainable_development_goals_4_display_name,
    "sdg_5_score" = sustainable_development_goals_5_score,
    "sdg_5_display_name" = sustainable_development_goals_5_display_name
  )

# Export des données
su_publi %>% rio::export(su_out)

