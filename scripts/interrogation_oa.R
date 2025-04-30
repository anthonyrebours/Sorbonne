# Interrogation de la base de données OpenAlex via openalexR

# Source:
# Priem, J., Piwowar, H., & Orr, R. (2022) 
# OpenAlex: A fully-open index of scholarly works, authors, venues, 
# institutions, and concepts. 
# ArXiv. https://arxiv.org/abs/2205.01833

# Auteur: Cellule scientométrie, Anthony Rebours
# Version: 2025-04-30
  
# Packages
library(tidyverse)
library(openalexR)

# Paramètres

  # Fichier de sauvegarde 
fichier_export <- here::here("data", "open_alex", "sorbonne_oa.rds")

  # Liste des institutions liées à Sorbonne Université
su <- 
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

  # Publication de Sorbonne Université
su_publi <- 
  list(
    entity = "works",
    authorships.institutions.lineage = su,
    verbose = TRUE
  )

  # Publications annuelles de Sorbonne Université
su_years <- 
  list(
    entity = "works",
    authorships.institutions.lineage = su,
    group_by = "publication_year",
    verbose = TRUE
  )

  # Nombre d'auteurs par publications de Sorbonne Université 
su_auth <- 
  list(
    entity = "works", 
    authorships.institutions.lineage = su,
    group_by = "authors_count"
  )

# ============================================================================

# Connaitre le nombre de publications totale de Sorbonne Université 
do.call(oa_fetch, c(su_publi, list(count_only = TRUE)))

# Connaitre le nombre de publications annuelles de Sorbonne Université
data_su_years <- do.call(oa_fetch, su_years)

  # Manipulation des données
data_su_years <-
  data_su_years %>% 
  rename(
    "Années" = "key",
    "Publications" = "count"
  )

data_su_years <- 
  data_su_years %>% 
  mutate(Années = as.integer(Années))

# Distribution de publications de Sorbonne Université en fontion du nombre d'auteurs
data_su_auth <- do.call(oa_fetch, su_auth)

  # Manipulation des données
data_su_auth <- 
  data_su_auth %>% 
  rename(
    "Auteurs" = "key",
    "Publications" = "count"
  )

data_su_auth <- 
  data_su_auth %>% 
  mutate(Auteurs = as.integer(Auteurs))



