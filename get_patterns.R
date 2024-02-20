pacman::p_load(dplyr,purrr,tidyr,ggplot2, data.table,readr,here, patchwork, conflicted)
conflict_prefer_all("dplyr", quiet = TRUE)

lmc22 <- readRDS(here("data","lmc22.rds"))
mc24 <- readRDS(here("data","mc24.rds"))


# item labels won't be completely unique since old items are repeated

mc24_patterns <- mc24 |> 
  ungroup() |>
  rename(Pattern.Type="Pattern_Token") |>
  mutate(Pattern.Type=forcats::fct_relevel(Pattern.Type,"prototype","old","new_low","new_med","new_high"),
         item_label = paste(sbjCode,condit,Category,trial,sep="_")) |>
  select(id,sbjCode,item_label,condit,exp,file,Phase,trial,Block,Pattern.Type,Category,Response,Corr,x1:y9) |>
  arrange(sbjCode,condit) 
  
lmc22_patterns <- lmc22 |> 
  ungroup() |> 
  mutate(Pattern.Type = as.character(Pattern.Type)) |> # Convert to character first
  mutate(Pattern.Type = factor(case_match(Pattern.Type,
                                          "Trained.Med" ~ "old",
                                          "Prototype" ~ "prototype",
                                          "New.Low" ~ "new_low",
                                          "New.Med" ~ "new_med",
                                          "New.High" ~ "new_high",
                                          .default = Pattern.Type), # Include a default case
                               levels = c("prototype", "old", "new_low", "new_med", "new_high"))) |>
  mutate(item_label = paste(sbjCode,condit,Category,trial,sep="_")) |>
  select(id,sbjCode,item_label,condit,exp,file,Phase,trial,Block,Pattern.Type,Category,Response,Corr,x1:y9) |>
  arrange(sbjCode,condit)


  
mc24_prototypes <- mc24_patterns |> 
  filter(Pattern.Type=="prototype") |>
  select(sbjCode,id,condit,exp,item_label,file,Category,x1:y9) |>
  arrange(sbjCode,condit,Category)

lmc22_prototypes <- lmc22_patterns |>
  filter(Pattern.Type=="prototype") |>
  select(sbjCode,id,condit,exp,item_label,file,Category,x1:y9) |>
  arrange(sbjCode,condit,Category)


write.csv(mc24_prototypes,here("Stimulii","mc24_prototypes.csv"), row.names = FALSE)
write.csv(lmc22_prototypes,here("Stimulii","lmc22_prototypes.csv"), row.names = FALSE)

write.csv(mc24_patterns,here("Stimulii","mc24_patterns.csv"), row.names = FALSE)
write.csv(lmc22_patterns,here("Stimulii","lmc22_patterns.csv"), row.names = FALSE)





# head(mc24_prototypes)
# # A tibble: 6 × 23
# sbjCode      condit exp   file  Category    x1    y1    x2    y2    x3    y3    x4    y4    x5    y5    x6    y6    x7    y7    x8    y8    x9    y9
# <chr>   <fct>  <chr> <chr>    <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int>
#   1 1.low   low    mc24  dot_…        1    14    12     1    13    12    11     6    -3     4    -4    -3    -5     6   -13    -3    -2    10    -3
# 2 1.low   low    mc24  dot_…        2     0     1     8    11     9    15    -1    12     4    -8    -9    15     7    -9     1     7     3    14
# 3 1.low   low    mc24  dot_…        3    -5    -5     4    -8    10   -13     7     3    -4     5     8   -10     8   -14    12   -10   -11     8
# 4 10.med… medium mc24  dot_…        1    11     2    10    14    -9     7    12     7     2    -5    11    -4    10    -2     3    -3    -6    11
# 5 10.med… medium mc24  dot_…        2    -4    -6    -1     5    16     0     3     6    11    -3    -8    -3     8   -11    -4     4    15     6
# 6 10.med… medium mc24  dot_…        3     7    15    10    13     7    -2     5    -9    -5    -6    -5     5    -8    13    -7    15    13    -3




 
 
