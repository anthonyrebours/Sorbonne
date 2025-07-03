

# Packages
pacman::p_load(
  openalexPro,
  tidyverse
)


# Import
auth <- 
  read_corpus(
    here::here("data", "auth_100", "part-0.parquet"), 
    return_data = TRUE
  )

  # Désimbriquation de la variable authorships
auth <- auth %>% unnest(authorships)

  # Extraction des noms de structures de recherche
instit <- auth %>% select(institutions)
instit <- instit %>% unnest(institutions)
instit <- instit %>% select(id, display_name)
instit <- instit %>% distinct(id, .keep_all = TRUE)

  # Extraction des affiliations par auteurs
auth <- auth %>% select(id, author, affiliations)
auth <- auth %>% unnest_wider(author, names_sep = "_")
auth <- auth %>% select(-author_id)
auth <- auth %>% unnest_longer(affiliations, keep_empty = TRUE)
auth <- auth %>% unnest_wider(affiliations, names_sep = TRUE)
auth <- auth %>% unnest_longer(affiliations_institution_ids, keep_empty = TRUE)

# Export
auth %>% rio::export(here::here("data", "auth_100.csv"))
