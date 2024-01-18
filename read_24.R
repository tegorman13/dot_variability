pacman::p_load(dplyr,purrr,tidyr,ggplot2, here, patchwork, conflicted)
conflict_prefer_all("dplyr", quiet = TRUE)



# 1. Phase type (1 Training, 2 Test)
# 2. Block number (1-10 Training, 1 Test)
# 3. Trial number (1-270 Training, 271-354 Test)*
# 4. Pattern type (1 = old*, 2 = prototype, 3 = new low, 4 = new medium, 5 = new high)
# 5. Category number (1-3)
# 6. Pattern token* (1-90 old, 1 prototype, 1-3 new low, 1-6 new med, 1-9 new high)
# 7. distortion level (1 = low, 2 = med, 3 = high)
# 8. Category response (1-3)
# 9. Correct/Incorrect (0 = Incorrect, 1 = Correct)
# 10. Reaction time (in milliseconds)
# 11-28. Coordinates of nine dots* (-25 through 24)
# *Pattern type: All training patterns (including old patterns in the test phase) are coded as 1 regardless of the distortion levels
# *Pattern token: index of unique tokens for each category of each type of pattern. 
# *Coordinates of nine dots: every two columns represent the x and y coordinates of a dot on a 50 x 50 grid
# 
# The conditions are indicated in the file names: 
#   file names with "cond1", "cond2", "cond3" and "cond4" contain data from the low, medium, high and mixed-distortion training conditions respectively. 


#rm(list=ls())

col.names = c("Phase","Block","BlockTrial","Pattern","Category","Pattern.Token","distortion","Response","Corr","rt",
              "x1","y1","x2","y2","x3","y3","x4","y4","x5","y5","x6","y6","x7","y7","x8","y8","x9","y9", "name", "condit", "sbjCode")

loadPattern="dot_*"
pathString=paste("data/",sep="")
mFiles <- list.files(path="data/",pattern = loadPattern, recursive = FALSE) # should be 89 in exp 2
mFiles
nFiles=length(mFiles)
# read in each of the txt files in mFiles - into a single tibble

d <- purrr::map2_dfr(mFiles, mFiles, ~ read.table(paste0(pathString, .x, sep = "")) %>%
    mutate(
      name = .y,
      condit = stringr::str_extract(.y, "cond\\d+"),
      subject_id = stringr::str_extract(.y, "sub\\d+")
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
    Pattern_Token = case_when(
      pattern == "old" & Pattern.Token %in% 1:90 ~ "old",
      pattern == "prototype" & Pattern.Token == 0 ~ "prototype",
      pattern == "new_low" & Pattern.Token %in% 1:3 ~ "new_low",
      pattern == "new_med" & Pattern.Token %in% 1:6 ~ "new_med",
      pattern == "new_high" & Pattern.Token %in% 1:9 ~ "new_high"
    ),
    condit = recode(condit,
                    "cond1" = "low",
                    "cond2" = "medium",
                    "cond3" = "high",
                    "cond4" = "mixed")
  ) |> 
  relocate(Stage, .after=trial) |> relocate(Pattern_Token, pattern, .after=Pattern.Token)

dCat$Pattern_Token = factor(dCat$Pattern_Token,levels=c("old","prototype","new_low","new_med","new_high")) 
dCat$condit = factor(dCat$condit,levels=c("low","medium","mixed","high") )


dCatTrainAvg=dCat |> filter(Phase==1)  |> group_by(sbjCode,condit,Block) |> 
  summarise(nCorr=sum(Corr),propCor=nCorr/27,rtMean=mean(rt), n=n(),.groups = 'keep') |> 
  ungroup() |> group_by(condit) |>
  mutate(grpRank=factor(rank(-propCor)),id=factor(sbjCode)) |> 
   as.data.frame() |> arrange(sbjCode,condit,Block)

dtf <- dCatTrainAvg |> filter(Block==10) |> arrange(-propCor) |>
  group_by(condit) |> # bin into quartile by propCor
  mutate(quartile = ntile(propCor, 4), finalTrain=propCor) 

dCatTrainAvg$id <-factor(dCatTrainAvg$id,levels=unique(dCatTrainAvg$sbjCode))


dCat <- dCat |> left_join(dtf |> select(sbjCode,condit,quartile, finalTrain), by=c("sbjCode","condit"))
dCat$sbjCode <-factor(dCat$sbjCode,levels=unique(dtf$id))




# d1 <- dCat |> filter(sbjCode=="sub1")
# da <- d |> group_by(sbjCode, condit) |> summarise(n = n()) %>% dplyr::arrange(n)
# sub12 has 708 trials - rest have 354. 
# the two sub12 instances are in different condits
