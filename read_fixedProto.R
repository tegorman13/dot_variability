


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



# I checked the raw data files and the experiment code, and I can confirm that the only difference for the fixed proto .txt files is that
#  there is an extra "index"  variable after the "distortion" variable on column 7. 
#  For the fixed prototype version of the experiment, I first generated a pool of dot patterns 
#  of different levels of distortion from the prototypes, and the training and test patterns for 
#  each subject were obtained by randomly sampling from pool. So the index for the pattern on each trial 
#  serves as a pointer to the pool of patterns and the indexing is unique for each category and distortion level. 
#  The subsequent columns should be the same as in the 2024 data set.



pacman::p_load(dplyr,purrr,tidyr,ggplot2, here, patchwork, conflicted)
conflict_prefer_all("dplyr", quiet = TRUE)


col.names = c("Phase","Block","BlockTrial","Pattern","Category","Pattern.Token","distortion","pool_index","Response","Corr","rt",
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
      Pattern == "5" ~ "new_high",
      Pattern == "6" ~ "special"
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
      pattern == "new_high" & Pattern.Token %in% 1:9 ~ "new_high",
      pattern == "special" ~ "special"
    ),
    condit = recode(condit,
                    "cond1" = "low",
                    "cond2" = "medium",
                    "cond3" = "high",
                    "cond4" = "mixed")
  ) |> 
  relocate(Stage, .after=trial) #|> relocate(Pattern_Token, pattern, .after=Pattern.Token)


dCat$Pattern_Token = factor(dCat$Pattern_Token,levels=c("old","prototype","new_low","new_med","new_high","special")) 
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



dCatTestAvg=dCat |> filter(Phase==2)  |> group_by(sbjCode,condit,Pattern_Token) |> 
  summarise(Corr=mean(Corr),rtMean=mean(rt), n=n(),.groups = 'keep') |> 
  ungroup() |> group_by(condit) |>
  mutate(grpRank=factor(rank(-Corr)),id=factor(sbjCode)) |> 
  as.data.frame() |> arrange(sbjCode,condit,Corr)

dte_h <- dCatTestAvg |> filter(Pattern_Token=="new_high") |> arrange(-Corr) |>
  group_by(condit) |> 
  mutate(q_test_high = ntile(Corr, 4), test_high=Corr)

dte_o <- dCatTestAvg |> filter(Pattern_Token=="old") |> arrange(-Corr) |>
  group_by(condit) |> 
  mutate(q_test_old = ntile(Corr, 4), test_old=Corr)

dCat <- dCat |> left_join(dtf |> select(sbjCode,condit,quartile, finalTrain), by=c("sbjCode","condit"))
dCat <- dCat |> left_join(dte_h |> select(sbjCode,condit,q_test_high, test_high), by=c("sbjCode","condit"))
dCat <- dCat |> left_join(dte_o |> select(sbjCode,condit,q_test_old, test_old), by=c("sbjCode","condit"))



dCat$sbjCode <-factor(dCat$sbjCode,levels=unique(dtf$id))

dCat <- dCat |> mutate(exp="fixed_proto",
                       sbjCode=stringr::str_extract(sbjCode, "\\d+"),
                       id=paste0(sbjCode,".",condit))  |>
  relocate(id,sbjCode,exp,condit,Phase,phase,Stage,trial,
           Block,BlockTrial,Pattern_Token,Pattern,pattern,distortion,
           Category,Response,Corr,rt)




dPattern <- dCat |> filter(Phase==2) |> 
  select(sbjCode,condit,distortion,Pattern_Token,Category,Response,Corr,rt,x1,y1,x2,y2,x3,y3,x4,y4,x5,y5,x6,y6,x7,y7,x8,y8,x9,y9) |> 
  arrange(x1,y1)


#saveRDS(dCat, "data/fixed_proto24.rds")

#write.csv(dPattern, "dPattern_fixed_proto24.csv", row.names=FALSE)

# length(unique(dCat$Pattern.Token))

# dPattern <- dCat |> filter(Phase==2) |> 
#   group_by(Pattern_Token, Pattern.Token) |> 
#   summarise(m=mean(Corr), n=n())

# dPattern <- dCat |> filter(Phase==2) |> 
#   group_by(Pattern_Token, Pattern.Token,x1,y1,x2,y2,x3,y3,x4,y4,x5,y5,x6,y6,x7,y7,x8,y8,x9,y9) |> 
#   dplyr::relocate(Pattern_Token, Pattern.Token, m,n,x1,y1,x2,y2,x3,y3,x4) |>
#   arrange(n)

# dPattern <- dCat |> filter(Phase==2) |> 
#   group_by(x1,y1,x2,y2,x3,y3,x4,y4,x5,y5,x6,y6,x7,y7,x8,y8,x9,y9) |> 
#   summarise(m=mean(Corr), n=n()) |> 
#   dplyr::relocate(m,n,x1,y1,x2,y2,x3,y3,x4) |>
#   arrange(n)


# dPattern <- dCat |> filter(Phase==2) |> 
#   select(sbjCode,condit,Pattern_Token, Pattern.Token,Corr,
#   "x1","y1","x2","y2","x3","y3","x4","y4","x5","y5","x6","y6","x7","y7","x8","y8","x9","y9") 

