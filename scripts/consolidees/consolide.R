# Données consolidées
  

# Version: 2025-06-04
  
# Packages
library(data.table)
library(tidyverse)

# Paramètres
  # Import données sous format data.table
auth_100 <- fread(here::here("data", "auth_100.csv"))
coauth_100 <- fread(here::here("data", "coauth_100.csv"))
publi <- fread(here::here("data", "su_publi.csv"))

  # Harmonisation des noms de variables
coauth_100 <- 
  coauth_100 %>% 
  rename(
    author_display_name = authorships_author_display_name,
    author_orcid = authorships_author_orcid,
    affiliations_raw_affiliation_string = authorships_affiliations_raw_affiliation_string,
    affiliations_institution_ids = authorships_affiliations_institution_ids
  )

# ============================================================================

# Assemblage complet des données auteurs 
auth_full <- bind_rows(auth_100, coauth_100)

# Assemblage des données auteurs et publications
su_full <- left_join(publi, auth_full, by = "id")

