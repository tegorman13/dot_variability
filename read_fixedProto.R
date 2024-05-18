


# 1. Phase type (1 Training, 2 Test)
# 2. Block number (1-10 Training, 1 Test)
# 3. Trial number (1-270 Training, 271-354 Test)*
# 4. Pattern type (1 = old*, 2 = prototype, 3 = new low, 4 = new medium, 5 = new high)
# 5. Category number (1-3)
# 6. Pattern token* 1- 9??
# 7. distortion level (1 = low, 2 = med, 3 = high)
# 8. ??
# 9. Category response (1-3)
# 10. Correct/Incorrect (0 = Incorrect, 1 = Correct)
# 10. Reaction time (in milliseconds)
# 11-28. Coordinates of nine dots* (-25 through 24)







pacman::p_load(dplyr,purrr,tidyr,ggplot2, here, patchwork, conflicted)
conflict_prefer_all("dplyr", quiet = TRUE)


col.names = c("Phase","Block","BlockTrial","Pattern_Type","Category","unknown","distortion","Pattern_Token","Response","Corr","rt",
              "x1","y1","x2","y2","x3","y3","x4","y4","x5","y5","x6","y6","x7","y7","x8","y8","x9","y9", "file", "condit", "sbjCode")

loadPattern="dot_.*\\.txt$"
pathString=paste0("data/cat_dl_fixed_proto/",sep="")
mFiles <- list.files(path=pathString,pattern = loadPattern, recursive = FALSE) # should be 89 in exp 2
nFiles=length(mFiles)
# read in each of the txt files in mFiles - into a single tibble


#mFiles <- mFiles[1]

d <- purrr::map2_dfr(mFiles, mFiles, ~ read.table(paste0(pathString, .x, sep = "")) %>%
    mutate(
      file = .y,
      condit = stringr::str_extract(.y, "cond\\d+"),
      sbjCode = stringr::str_extract(.y, "sub\\d+")
    )) %>%
    purrr::set_names(col.names) |> 
  group_by(sbjCode, condit) |>
  mutate(trial = row_number()) |> 
  relocate("sbjCode", "condit", "trial") 



dCat <- d |> 
  mutate(
    phase = case_when(
      Phase == "1" ~ "Training",
      Phase == "2" ~ "Test"
    ), 
    Stage = case_when(
      trial %in% 1:90 ~ "Start",
      trial %in% 91:180 ~ "Middle",
      trial %in% 181:270 ~ "End",
      trial %in% 271:354 ~ "Test"
    ),
    pattern = case_when(
      Pattern == "1" ~ "old",
      Pattern == "2" ~ "prototype",
      Pattern == "3" ~ "new_low",
      Pattern == "4" ~ "new_med",
      Pattern == "5" ~ "new_high"
    ),
    distortion = recode(distortion,
                        `0` = "prototype",
                        `1` = "low",
                        `2` = "med",
                        `3` = "high"),
    # Pattern_Token = case_when(
    #   pattern == "old" & Pattern.Token %in% 1:90 ~ "old",
    #   pattern == "prototype" & Pattern.Token == 0 ~ "prototype",
    #   pattern == "new_low" & Pattern.Token %in% 1:3 ~ "new_low",
    #   pattern == "new_med" & Pattern.Token %in% 1:6 ~ "new_med",
    #   pattern == "new_high" & Pattern.Token %in% 1:9 ~ "new_high"
    # ),
    condit = recode(condit,
                    "cond1" = "low",
                    "cond2" = "medium",
                    "cond3" = "high",
                    "cond4" = "mixed")
  ) |> 
  relocate(Stage, .after=trial) #|> relocate(Pattern_Token, pattern, .after=Pattern.Token)


dCat$Pattern_Token = factor(dCat$Pattern_Token,levels=c("old","prototype","new_low","new_med","new_high")) 
dCat$condit = factor(dCat$condit,levels=c("low","medium","mixed","high") )
