# Requête pour récupérer auteurs des publications de Sorbonne université 
  

# Les données récupérées auprès d'OpenAlex peuvent être volumineuses aussi
# pour limiter les problèmes d'envoie de données on récupère les données liées 
# aux auteurs dans une seconde requête. Un second problème consiste dans le fait
# qu'OpenAlex limite le nombre de coauteurs par article lors de requêtes avec 
# plus d'un article. On procède donc en deux temps : dans un premier temps on
# récupère tous les articles avec 100 coauteurs ou moins via une requête 
# "normale" puis dans un second temps on utilise une boucle "for" pour requêter
# un par un les articles avec plus de 100 auteurs


# Version: 2025-06-02
  
# Packages
pacman::p_load(
  tidyverse,
  openalexR, 
  openalexPro,
  duckdb
)

# Paramètres
  # Variables requête OpenAlex
oa_var <- c("id", "authorships")
  # Sorbonne Université et institutions connexes
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
  
# Export des données
  # Chemin du fichier 
export <- here::here("data", "coauth_100.csv")

# ============================================================================

# Requête OpenAlex pour 100 auteurs ou moins
query_1 <- 
  oa_query(
    entity = "works",
    authorships.institutions.lineage = su_chu,
    authors_count = c("<100", "100"),
    type = c("!paratext", "!peer-review", "!erratum"),
    publication_year = "2018-2024",
    options = list(select = c("id", "authorships"))
  ) %>% 
  openalexPro::pro_request(verbose = TRUE) %>% 
  source_to_parquet(corpus = "corpus")

# Requête OpenAlex pour plus de 100 auteurs
  # Liste des articles avec plus de 100 auteurs
arts <- 
  oa_fetch(
    entity = "works",
    authorships.institutions.lineage = su_chu,
    authors_count = ">100",
    type = c("!paratext", "!peer-review", "!erratum"),
    publication_year = "2018-2024",
    options = list(select = "id")
  )
arts <- arts$id
  # Fonction pour requêter OpenAlex
query_2 <-
  function(arts_id){
    arts_data <- oa_fetch(
      id = arts_id,
      options = list(select = c("id", "authorships")),
      output = "list"
    )
    return(arts_data)
  }
  # Boucle "for" pour requêter OpenAlex
all_arts <- list()
for (id in arts) {
  arts_data <- query_2(id)
  all_arts[[id]] <- arts_data
  Sys.sleep(1)
}
  # Conversion des listes en dataframe
df_all_parts <- as.data.frame(do.call(bind_rows, all_arts))
  # Extraction des noms et identifiants des institutions
instit_names <- 
  df_all_parts %>%
  hoist(authorships, "authorships_institutions") %>% 
  select(authorships_institutions)
instit_names <- instit_names %>% unnest(authorships_institutions)
instit_names <- 
  instit_names %>%
  hoist(authorships_institutions, "id", "display_name") %>% 
  select(-authorships_institutions)
instit_names <- instit_names %>% distinct(id, .keep_all = TRUE)
  # Extractions d'autres variables utiles
df_all_parts <- df_all_parts %>% unnest_wider("authorships", names_sep = "_")
df_all_parts <- 
  df_all_parts %>% 
  select(-c(
    authorships_countries,
    authorships_is_corresponding,
    authorships_raw_author_name,
    authorships_author_position, 
    authorships_raw_affiliation_strings
  ))
df_all_parts <- df_all_parts %>% unnest_wider(authorships_author , names_sep = "_")
df_all_parts <- df_all_parts %>% select(-authorships_author_id)
df_all_parts <- df_all_parts %>% unnest_longer(authorships_affiliations, keep_empty = TRUE)
df_all_parts <- df_all_parts %>% unnest_wider(authorships_affiliations, names_sep = "_")
df_all_parts <- df_all_parts %>% unnest_longer(authorships_affiliations_institution_ids, keep_empty = TRUE)
  # Association des identifiants institutions avec leur noms 
df_all_parts <- 
  df_all_parts %>% 
  left_join(
    instit_names, 
    by = c("authorships_affiliations_institutions_ids" = "id")
  )


