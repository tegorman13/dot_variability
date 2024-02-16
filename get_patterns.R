pacman::p_load(dplyr,purrr,tidyr,ggplot2, data.table,readr,here, patchwork, conflicted)
conflict_prefer_all("dplyr", quiet = TRUE)

lmc22 <- readRDS(here("data","lmc22.rds"))
mc24 <- readRDS(here("data","mc24.rds"))


mc24_patterns <- mc24 |> 
  ungroup() |>
  rename(Pattern.Type="Pattern_Token") |>
  mutate(Pattern.Type=forcats::fct_relevel(Pattern.Type,"prototype","old","new_low","new_med","new_high")) |>
  select(id,sbjCode,condit,exp,file,Phase,trial,Block,Pattern.Type,Category,Response,Corr,x1:y9) |>
  arrange(sbjCode,condit,Category)
  

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
  select(id,sbjCode,condit,exp,file,Phase,trial,Block,Pattern.Type,Category,Response,Corr,x1:y9) |>
  arrange(sbjCode,condit,Category)


  
mc24_prototypes <- mc24_patterns |> 
  filter(Pattern.Type=="prototype") |>
  select(sbjCode,condit,exp,file,Category,x1:y9)

lmc22_prototypes <- lmc22_patterns |>
  filter(Pattern.Type=="prototype") |>
  select(sbjCode,condit,exp,file,Category,x1:y9)

write.csv(mc24_prototypes,here("Stimulii","mc24_prototypes.csv"), row.names = FALSE)
write.csv(lmc22_prototypes,here("Stimulii","lmc22_prototypes.csv"), row.names = FALSE)



# head(mc24_prototypes)
# # A tibble: 6 × 23
# id      condit exp   file  Category    x1    y1    x2    y2    x3    y3    x4    y4    x5    y5    x6    y6    x7    y7    x8    y8    x9    y9
# <chr>   <fct>  <chr> <chr>    <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int>
#   1 1.low   low    mc24  dot_…        1    14    12     1    13    12    11     6    -3     4    -4    -3    -5     6   -13    -3    -2    10    -3
# 2 1.low   low    mc24  dot_…        2     0     1     8    11     9    15    -1    12     4    -8    -9    15     7    -9     1     7     3    14
# 3 1.low   low    mc24  dot_…        3    -5    -5     4    -8    10   -13     7     3    -4     5     8   -10     8   -14    12   -10   -11     8
# 4 10.med… medium mc24  dot_…        1    11     2    10    14    -9     7    12     7     2    -5    11    -4    10    -2     3    -3    -6    11
# 5 10.med… medium mc24  dot_…        2    -4    -6    -1     5    16     0     3     6    11    -3    -8    -3     8   -11    -4     4    15     6
# 6 10.med… medium mc24  dot_…        3     7    15    10    13     7    -2     5    -9    -5    -6    -5     5    -8    13    -7    15    13    -3


# theme_minimal() + 
#   xlim(-25, 25) + 
#   ylim(-25, 25) + 
#   labs(title = "Dot Patterns for Each Participant and Category", 
#        x = "X Coordinate", 
#        y = "Y Coordinate") + 
#   coord_fixed() + 
#   guides(alpha = FALSE) 

pat_themes <- list(theme_minimal(),xlim(-25, 25),ylim(-25, 25),
                   labs(title = "Dot Patterns for Each Participant and Category",
                        x = "X Coordinate", y = "Y Coordinate"),
                   coord_fixed(),guides(alpha = FALSE))


mc24_prototypes_long <- mc24_prototypes %>%
  gather(key = "coordinate", value = "value", -id, -condit, -exp, -file, -Category) %>%
  separate(coordinate, into = c("axis", "number"), sep = 1) %>%
  spread(key = axis, value = value) %>%
  mutate(number = as.integer(number))


mc24_prototypes_long |>
  filter(id %in% c("1.low","10.medium","112.high")) |>
  ggplot(aes(x = x, y = y)) +
  geom_point() + # Add dots
  facet_grid(id ~ Category) + # Create a grid of plots, with subjects by rows and categories by columns
  pat_themes


 pat_long <- mc24_patterns |> 
   filter(Phase==2) |> 
   select(id, condit, Category, Pattern.Type, x1:y9) |>
   group_by(id, condit, Category, Pattern.Type) |> 
   slice_head(n=1) |> 
   gather(key = "coordinate", value = "value", -id, -condit, -Category,-Pattern.Type) %>%
   separate(coordinate, into = c("axis", "number"), sep = 1) %>%
   spread(key = axis, value = value) %>%
   mutate(number = as.integer(number))
 
 pat_long |> 
   filter(Category==1, id %in%  c("1.low","10.medium","112.high"),
          Pattern.Type!="old") |>
   ggplot(aes(x = x, y = y)) +
   geom_point() + # Add dots
   facet_grid(id ~ Pattern.Type) + # Create a grid of plots, with subjects by rows and categories by columns
   pat_themes
   
 pat_long |> 
   filter(id %in%  c("1.low","10.medium"),
          Pattern.Type!="old") |>
   ggplot(aes(x = x, y = y)) +
   geom_point() + # Add dots
   #ggh4x::facet_nested_wrap(id~Category~Pattern.Type) + 
   ggh4x::facet_grid2(id ~ Category ~ Pattern.Type) +
   pat_themes
 
 
 pat_long |> 
   filter(id %in%  c("1.low","10.medium","112.high")) |>
   ggplot(aes(x = x, y = y)) +
   geom_point(aes(col=Pattern.Type)) + 
   facet_grid(id ~ Category) +
   pat_themes
 
   

 pat_long |> 
   filter(id %in%  c("1.low","10.medium","112.high"),
          Pattern.Type!="old") |>
   ggplot(aes(x = x, y = y)) +
   geom_point(aes(color = Pattern.Type, alpha = Pattern.Type)) + 
   scale_color_manual(values = c("prototype" = "black",  # Black for prototype
                                 "old" = "#E69F00",      # Orange for old
                                 "new_low" = "#56B4E9",  # Blue for new_low
                                 "new_med" = "#009E73",  # Green for new_med
                                 "new_high" = "red")) +# Yellow for new_high   scale_alpha_manual(values = c("prototype" = 1, "old" = 0.5, "new_low" = 0.5, "new_med" = 0.5, "new_high" = 0.5)) +
   scale_alpha_manual(values = c("prototype" = 1, "old" = 0.2, "new_low" = 0.2, "new_med" = 0.2, "new_high" = 0.2)) +
    facet_grid(id ~ Category) + pat_themes

 
 
 pat_long <- mc24_patterns |> 
   filter(id %in%  c("1.low","10.medium","112.high")) |>
   filter(Phase==2) |> 
   select(id, condit,trial, Category, Pattern.Type, x1:y9) |>
   group_by(id, condit, Category, Pattern.Type) |> 
   slice_head(n=10) |> 
   gather(key = "coordinate", value = "value", -id, -condit,-trial, -Category,-Pattern.Type) %>%
   separate(coordinate, into = c("axis", "number"), sep = 1) %>%
   spread(key = axis, value = value) %>%
   mutate(number = as.integer(number))
 
 
 pat_long |> 
   filter(id %in%  c("1.low","10.medium","112.high"),Pattern.Type!="old") |>
   ggplot(aes(x = x, y = y)) +
   geom_point(aes(color = Pattern.Type, alpha = Pattern.Type)) + 
   scale_color_manual(values = c("prototype" = "black",  # Black for prototype
                                 "old" = "#E69F00",      # Orange for old
                                 "new_low" = "#56B4E9",  # Blue for new_low
                                 "new_med" = "#009E73",  # Green for new_med
                                 "new_high" = "red")) +# Yellow for new_high   scale_alpha_manual(values = c("prototype" = 1, "old" = 0.5, "new_low" = 0.5, "new_med" = 0.5, "new_high" = 0.5)) +
   scale_alpha_manual(values = c("prototype" = 1, "old" = 0.2, "new_low" = 0.4, "new_med" = 0.3, "new_high" = 0.2)) +
   facet_grid(id ~ Category) + pat_themes
 
 
 pat_long |> 
   filter(id %in%  c("1.low","10.medium","112.high"),Pattern.Type!="old") |>
   ggplot(aes(x = x, y = y)) +
   geom_point(aes(color = as.factor(Category)),alpha=.9) + 
   facet_grid(id ~ Pattern.Type) + pat_themes
 
 
 
 
 pat_long_train <- mc24_patterns |> 
   ungroup() |>
   group_by(condit,Category) |> slice_head(n=4) |>
   filter(Phase==1) |> 
   select(id, condit,trial, Category, Pattern.Type, x1:y9) |>
   group_by(id, condit, Category, Pattern.Type) |> 
   gather(key = "coordinate", value = "value", -id, -condit,-trial, -Category,-Pattern.Type) %>%
   separate(coordinate, into = c("axis", "number"), sep = 1) %>%
   spread(key = axis, value = value) %>%
   mutate(number = as.integer(number))
 
 pat_long_train |> 
   ggplot(aes(x = x, y = y)) +
   geom_point(aes(color = as.factor(Category)),alpha=.9) + 
   facet_wrap(~id) + pat_themes
 
 
