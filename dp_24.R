pacman::p_load(dplyr,purrr,tidyr,ggplot2, here, patchwork, conflicted, knitr,grateful)
conflict_prefer_all("dplyr", quiet = TRUE)
source("read_24.R")

#https://fonts.google.com/specimen/Manrope
# ~/Library/Fonts
theme_nice <- function() {
  theme_minimal(base_family = "Manrope") +
    theme(
      panel.grid.minor = element_blank(),
      plot.title = element_text(family = "Manrope Extrabold", face = "plain", size = rel(1.35)),
      plot.subtitle = element_text(family = "Manrope Medium", face = "plain", size = rel(1.2)),
      axis.title = element_text(family = "Manrope SemiBold", face = "plain", size = rel(1)),
      axis.title.x = element_text(hjust = .5),
      axis.title.y = element_text(hjust = .5),
      axis.text = element_text(family = "Manrope Light", face = "plain", size = rel(0.8)),
      strip.text = element_text(
        family = "Manrope", face = "bold",
        size = rel(.75), hjust = 0
      ),
      strip.background = element_rect(fill = "grey90", color = NA)
    )
}

theme_nice_dist <- function() {
  theme_nice() +
    theme(
      panel.grid = element_blank(),
      panel.spacing.x = unit(10, units = "pt"),
      axis.ticks.x = element_line(linewidth = 0.25),
      axis.text.y = element_blank()
    )
}

theme_set(theme_nice())

# dCat |> filter(Phase==2) |> group_by(condit) |> summarise(n=n_distinct(sbjCode))
# dCat |> filter(finalTrain>.33, Phase==2) |> group_by(condit) |> summarise(n=n_distinct(sbjCode))
# dCat |> filter(finalTrain>.66, Phase==2) |> group_by(condit) |> summarise(n=n_distinct(sbjCode))
# dCat |> filter(finalTrain>.70, Phase==2) |> group_by(condit) |> summarise(n=n_distinct(sbjCode))
dCat |> 
  filter(Phase == 2) |> 
  group_by(condit) |> 
  summarise(
    `All Sbjs.` = n_distinct(sbjCode),
    `>.33` = n_distinct(sbjCode[finalTrain > .35]),
    `>.50` = n_distinct(sbjCode[finalTrain > .50]),
    `>.70` = n_distinct(sbjCode[finalTrain > .70])
  ) |> kable()

trainRanks <- dCat |> group_by(sbjCode,condit) |> 
  select(finalTrain) |> slice(1) |> arrange(-finalTrain)

top17 <- trainRanks |> group_by(condit) |> slice(1:17)
top35 <- trainRanks |> group_by(condit) |> slice(1:35)
top56 <- trainRanks |> group_by(condit) |> slice(1:56)
low <- trainRanks |> filter(!(sbjCode %in% top56$sbjCode)) 


#top17 |> gt::gt()

t17 <- dCat |> filter(sbjCode %in% top17$sbjCode) |>
  group_by(sbjCode, condit, Pattern_Token) |>
  summarize(Corr=mean(Corr)) |>
  ggplot(aes(x=Pattern_Token, y=Corr, fill=condit, group=condit)) +  
  stat_summary(geom="bar",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge()) +
  labs(title="Testing - top 17 Sbjs.", y="Accuracy") 


t35 <- dCat |> filter(sbjCode %in% top35$sbjCode) |>
  group_by(sbjCode, condit, Pattern_Token) |>
  summarize(Corr=mean(Corr)) |>
  ggplot(aes(x=Pattern_Token, y=Corr, fill=condit, group=condit)) +  
  stat_summary(geom="bar",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge()) +
  labs(title="Testing - top 35 Sbjs.", y="Accuracy") 

t56 <- dCat |> filter(sbjCode %in% top56$sbjCode) |>
  group_by(sbjCode, condit, Pattern_Token) |>
  summarize(Corr=mean(Corr)) |>
  ggplot(aes(x=Pattern_Token, y=Corr, fill=condit, group=condit)) +  
  stat_summary(geom="bar",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge()) +
  labs(title="Testing - top 56 Sbjs.", y="Accuracy") 

tLow56 <- dCat |> filter(sbjCode %in% low$sbjCode) |>
  group_by(sbjCode, condit, Pattern_Token) |>
  summarize(Corr=mean(Corr)) |>
  ggplot(aes(x=Pattern_Token, y=Corr, fill=condit, group=condit)) +  
  stat_summary(geom="bar",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge()) + 
  labs(title="Testing - lowest Sbjs (all sbj. NOT in top 56)", y="Accuracy")


tLow35 <- dCat |> filter(!(sbjCode %in% (trainRanks |> group_by(condit) |> slice(1:35))$sbjCode)) |>
  group_by(sbjCode, condit, Pattern_Token) |>
  summarize(Corr=mean(Corr)) |>
  ggplot(aes(x=Pattern_Token, y=Corr, fill=condit, group=condit)) +  
  stat_summary(geom="bar",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge()) + 
  labs(title="Testing - subjects NOT in top 35", y="Accuracy")

tLow17 <- dCat |> filter(!(sbjCode %in% (trainRanks |> group_by(condit) |> slice(1:17))$sbjCode)) |>
  group_by(sbjCode, condit, Pattern_Token) |>
  summarize(Corr=mean(Corr)) |>
  ggplot(aes(x=Pattern_Token, y=Corr, fill=condit, group=condit)) +  
  stat_summary(geom="bar",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge()) + 
  labs(title="Testing - subjects NOT in top 17", y="Accuracy")



(t17+tLow17) /(t35+tLow35)/(t56+tLow56) + 
  plot_annotation(title="Test Accuracy - matching # of subjects", 
                  caption=" Only the top 17; top 35; top 56; or lowest performing subjects included. Rankings based on final training accuracy")



# (t17+t35) /(t56+tLow) + 
#   plot_annotation(title="Test Accuracy - matching # of subjects", 
#                   caption=" Only the top 17; top 35; top 56; or lowest performing subjects included. Rankings based on final training accuracy")


tAll <- dCat |> filter(Phase==2) |>
  group_by(sbjCode, condit, Pattern_Token) |>
  summarize(Corr=mean(Corr)) |>
  ggplot(aes(x=Pattern_Token, y=Corr, fill=condit, group=condit)) +  
  stat_summary(geom="bar",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge()) +
  labs(title="Testing Performance - All Sbjs.", y="Accuracy") 

t33 <- dCat |> filter(finalTrain>.35, Phase==2) |>
  group_by(sbjCode, condit, Pattern_Token) |>
  summarize(Corr=mean(Corr)) |>
  ggplot(aes(x=Pattern_Token, y=Corr, fill=condit, group=condit)) +  
  stat_summary(geom="bar",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge()) +
  labs(title="Testing Performance - Only greater than 35%", y="Accuracy") 

t66 <- dCat |> filter(finalTrain>.50, Phase==2) |>
  group_by(sbjCode, condit,Pattern_Token) |>
  summarize(Corr=mean(Corr)) |>
  ggplot(aes(x=Pattern_Token, y=Corr, fill=condit, group=condit)) +  
  stat_summary(geom="bar",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge()) +
  labs(title="Testing Performance - Only greater than 50%", y="Accuracy") 

t80 <- dCat |> filter(finalTrain>.70, Phase==2) |>
  group_by(sbjCode, condit,  Pattern_Token) |>
  summarize(Corr=mean(Corr)) |>
  ggplot(aes(x=Pattern_Token, y=Corr, fill=condit, group=condit)) +  
  stat_summary(geom="bar",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge()) +
  labs(title="Testing Performance - Only greater than 70%", y="Accuracy") 

((tAll + t33)/(t66 + t80)) + 
  plot_annotation(title="Test Accuracy - Influence of filtering out weak/non learers", 
                  caption=" % values indicate level of final training performance needed to be included. Note that the training conditions are disproporionately impacted by exclusions.")




tAll <- dCat |> filter(Phase==2) |>
  ggplot(aes(x=condit, y=Corr, fill=Pattern_Token, group=Pattern_Token)) +  
  stat_summary(geom="bar",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge()) +
  labs(title="Testing Performance - All Sbjs.", y="Accuracy") 

t33 <- dCat |> filter(finalTrain>.35, Phase==2) |>
  ggplot(aes(x=condit, y=Corr, fill=Pattern_Token, group=Pattern_Token)) +  
  stat_summary(geom="bar",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge()) +
  labs(title="Testing Performance - Only greater than 35%", y="Accuracy") 

t66 <- dCat |> filter(finalTrain>.50, Phase==2) |>
  ggplot(aes(x=condit, y=Corr, fill=Pattern_Token, group=Pattern_Token)) +  
  stat_summary(geom="bar",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge()) +
  labs(title="Testing Performance - Only greater than 50%", y="Accuracy") 

t80 <- dCat |> filter(finalTrain>.70, Phase==2) |>
  ggplot(aes(x=condit, y=Corr, fill=Pattern_Token, group=Pattern_Token)) +  
  stat_summary(geom="bar",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge()) +
  labs(title="Testing Performance - Only greater than 70%", y="Accuracy") 

((tAll + t33)/(t66 + t80))


tx1 <- theme(axis.title.x=element_blank(), axis.text.x=element_blank())
tx2 <- theme(axis.title.x=element_blank(), axis.text.x=element_blank(),legend.position = "none" )
yt <- round(seq(0,1,length.out=7), 2)
eg <- list(geom_hline(yintercept = c(.33, .66),linetype="dashed", alpha=.5),scale_y_continuous(breaks=yt))


dq1 <- dCat |> filter(Phase==2) |> 
  group_by(sbjCode, condit, quartile, Pattern_Token) |>
  summarize(Corr=mean(Corr)) |>
  ggplot(aes(x=Pattern_Token, y=Corr, fill=condit)) +
  stat_summary(geom="bar",fun="mean", position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge(), width=.9) +
  eg + labs(x="Pattern Token", y="Proportion Correct", title="Testing Accuracy Overall Averages", 
            fill="Training Condition") 
  
dq2 <-dCat |> filter(Phase == 2) |> 
  group_by(sbjCode, condit, quartile, Pattern_Token) |>
  summarize(Corr=mean(Corr)) |>
  ggplot(aes(x = Pattern_Token, y = Corr, fill = condit)) +
  stat_summary(geom = "bar", fun = "mean", position = position_dodge()) +
  stat_summary(geom = "errorbar", fun.data = mean_se, position = position_dodge(width = 0.9), width = 0.25) +
  facet_wrap(~quartile) +
  labs(x = "Pattern Token", y = "Proportion Correct", title = "Testing Accuracy by End-Training Quartile", 
       subtitle="Quartiles are based on the final training performance of each subject", 
       fill="Training Condition") 
  
dq1/dq2


tx1 <- theme(axis.title.x=element_blank(), axis.text.x=element_blank())
tx2 <- theme(axis.title.x=element_blank(), axis.text.x=element_blank(),legend.position = "none" )
yt <- round(seq(0,1,length.out=7), 2)
eg <- list(geom_hline(yintercept = c(.33, .66),linetype="dashed", alpha=.5),scale_y_continuous(breaks=yt))


dq1 <- dCat |> filter(Phase==2) |> 
  group_by(sbjCode, condit, quartile, Pattern_Token) |>
  summarize(Corr=mean(Corr)) |>
  ggplot(aes(x=condit, y=Corr, fill=Pattern_Token)) +
  stat_summary(geom="bar",fun="mean", position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge(), width=.9) +
  eg + labs(x="Training Condition", y="Proportion Correct", title="Testing Accuracy Overall Averages") 
  
dq2 <-dCat |> filter(Phase == 2) |> 
  group_by(sbjCode, condit, quartile, Pattern_Token) |>
  summarize(Corr=mean(Corr)) |>
  ggplot(aes(x = condit, y = Corr, fill = Pattern_Token)) +
  stat_summary(geom = "bar", fun = "mean", position = position_dodge()) +
  stat_summary(geom = "errorbar", fun.data = mean_se, position = position_dodge(width = 0.9), width = 0.25) +
  facet_wrap(~quartile) +
  labs(x = "Training Condition", y = "Proportion Correct", title = "Testing Accuracy by End-Training Quartile", 
       subtitle="Quartiles are based on the final training performance of each subject") 
  
dq1/dq2
  
  

dCat |> filter(Phase == 2) |> 
  group_by(sbjCode, condit, quartile, Pattern_Token) |>
  summarize(Corr=mean(Corr)) |>
  ggplot(aes(x = condit, y = Corr, fill = Pattern_Token)) +
  geom_boxplot(position=position_dodge()) +
  geom_jitter(position = position_jitterdodge(jitter.width = 0.25, dodge.width = 0.9), alpha = .2) +
  labs(x = "Training Condition", y = "Proportion Correct", title = "Testing Accuracy - All")


dCat |> filter(Phase == 2) |> 
  group_by(sbjCode, condit, quartile, Pattern_Token) |>
  summarize(Corr=mean(Corr)) |>
  ggplot(aes(x = condit, y = Corr, fill = Pattern_Token)) +
  geom_boxplot(position=position_dodge()) +
  geom_jitter(position = position_jitterdodge(jitter.width = 0.25, dodge.width = 0.9), alpha = .2) +
  facet_wrap(~quartile)
  labs(x = "Training Condition", y = "Proportion Correct", title = "Testing Accuracy - All")

tx1 <- theme(axis.title.x=element_blank(), axis.text.x=element_blank())
tx2 <- theme(axis.title.x=element_blank(), axis.text.x=element_blank(),legend.position = "none" )
rtfun <- "median"
yt <- round(seq(0,1500,length.out=7), 2)
eg <- list(scale_y_continuous(breaks=yt))


htq <- dCat |> filter(condit=="high", Phase==2) |>
  ggplot(aes(x=Pattern_Token, y=rt, fill=Pattern_Token)) +  
  stat_summary(geom="bar",fun=rtfun)+
  facet_wrap(~quartile) + eg+
  labs(title="High Training -  Test RT", y="Reaction Time") +tx2

ltq <- dCat |> filter(condit=="low", Phase==2) |>
  ggplot(aes(x=Pattern_Token, y=rt, fill=Pattern_Token)) +  
  stat_summary(geom="bar",fun=rtfun)+
  facet_wrap(~quartile) + eg+
  labs(title="Low Training -  Test RT", y="Reaction Time") +tx1

mtq <- dCat |> filter(condit=="medium", Phase==2) |>
  ggplot(aes(x=Pattern_Token, y=rt, fill=Pattern_Token)) +  
  stat_summary(geom="bar",fun=rtfun)+
  facet_wrap(~quartile) + eg+
  labs(title="Medium Training -  Test RT", y="Reaction Time") +tx2


mxtq <- dCat |> filter(condit=="mixed", Phase==2) |>
  ggplot(aes(x=Pattern_Token, y=rt, fill=Pattern_Token)) +  
  stat_summary(geom="bar",fun=rtfun)+
  facet_wrap(~quartile) + eg+
  labs(title="Mixed Training -  Test RT", y="Reaction Time")  + tx1
  


(htq+ltq)/(mtq+mxtq) + plot_annotation(
  title = 'Testing Reaction Times by Quartile',
  subtitle = 'Quartiles set by Final TRAINING block',
  caption = 'bars reflect median reaction times. Quartiles are set by ACCURACY in the final training block. Bar colors are pattern type.'
)




tAll <- dCat |> filter(Phase==2) |>
  ggplot(aes(x=condit, y=rt, fill=Pattern_Token, group=Pattern_Token)) +  
  stat_summary(geom="bar",fun=rtfun, position=position_dodge())+
  labs(title="High Distortion Testing - All Sbjs.", y="Reaction Time", x="Training Condition") + theme(legend.position = "top")

t33 <- dCat |> filter(finalTrain>.35, Phase==2) |>
  ggplot(aes(x=condit, y=rt, fill=Pattern_Token, group=Pattern_Token)) +  
  stat_summary(geom="bar",fun=rtfun, position=position_dodge())+
  labs(title="High Distortion Testing - Only greater than 35%", y="Reaction Time", x="Training Condition")  + theme(legend.position = "none")

t66 <- dCat |> filter(finalTrain>.50, Phase==2) |>
  ggplot(aes(x=condit, y=rt, fill=Pattern_Token, group=Pattern_Token)) +  
  stat_summary(geom="bar",fun=rtfun, position=position_dodge())+
  labs(title="High Distortion Testing - Only greater than 50%", y="Reaction Times", x="Training Condition") + theme(legend.position = "none")

t80 <- dCat |> filter(finalTrain>.70, Phase==2) |>
  ggplot(aes(x=condit, y=rt, fill=Pattern_Token, group=Pattern_Token)) +  
  stat_summary(geom="bar",fun=rtfun, position=position_dodge())+
  labs(title="High Distortion Testing- Only greater than 70%", y="Reaction Times", x="Training Condition") + theme(legend.position = "none")
((tAll + t33)/(t66 + t80)) + plot_annotation(
  title = 'Testing Reaction Times by Training Accuracy',
  subtitle = 'Filtering to retain subjects who achieved different performace levels during training',
  caption = 'bars reflect median reaction times. Quartiles are set by ACCURACY in the final training block. Bar colors are pattern type.'
)



yt <- round(seq(0,1,length.out=7), 2)
eg <- list(geom_hline(yintercept = c(.33, .66),linetype="dashed", alpha=.5),scale_y_continuous(breaks=yt))
tlt <- theme(legend.position = "top")

nbins=5

test_learn1 <- dCat |> filter(Phase==2) |>
  group_by(sbjCode,condit) |>
  mutate(BlockTest=cut(trial,breaks=seq(1,max(trial), length.out=nbins+1),include.lowest=TRUE,labels=FALSE)) |>
  # group_by(sbjCode,condit, BlockTest, Pattern_Token) |>
  # summarise(Corr=mean(Corr)) |>
  ggplot(aes(x=BlockTest, y=Corr, col=Pattern_Token, group=Pattern_Token)) +  
  stat_summary(geom="line",fun=mean, position=position_dodge()) +
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge(), width=.1) +
  geom_smooth()+
  facet_wrap(~condit)+
  labs(title="Average Learning Curves", y="Accuracy") + eg + tlt

# performance seems stable across testing
test_learn2 <- dCat |> filter(Phase==2) |>
  group_by(sbjCode,condit) |>
  mutate(BlockTest=cut(trial,breaks=seq(1,max(trial), length.out=nbins+1),include.lowest=TRUE,labels=FALSE)) |>
  # group_by(sbjCode,condit, BlockTest, Pattern_Token, quartile) |>
  # summarise(Corr=mean(Corr)) |>
  ggplot(aes(x=BlockTest, y=Corr, col=Pattern_Token, group=Pattern_Token)) +  
  stat_summary(geom="line",fun=mean, position=position_dodge()) +
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge(), width=.1) +
  geom_smooth(alpha=.6)+
  facet_wrap(quartile~condit)+
  labs(title="Average Learning Curves", y="Accuracy") + eg + tlt

test_learn1 / test_learn2 + # make upper half of plot half as wide as lower half
  plot_layout(widths = c(1, 1), heights = c(1, 2)) +
  plot_annotation(
    title = 'Learning during testing',
    subtitle = 'Average accuracy across subjects',
    caption = 'lines reflect mean accuracy. Shaded areas reflect 95% confidence intervals. Dashed lines reflect chance performance. Colors reflect pattern type.'
  )




tx1 <- theme(axis.title.x=element_blank(), axis.text.x=element_blank())
tx2 <- theme(axis.title.x=element_blank(), axis.text.x=element_blank(),legend.position = "none" )
yt <- round(seq(0,1,length.out=7), 2)
xt <- seq(1,10,1)
eg <- list(geom_hline(yintercept = c(.33, .66),linetype="dashed", alpha=.5),
           scale_y_continuous(breaks=yt),
           scale_x_continuous(breaks=xt))
tlt <- theme(legend.position = "top")
tln <- theme(legend.position = "none")

lavg <- dCat |> filter(Phase==1) |>
  ggplot(aes(x=Block, y=Corr, col=condit, group=condit)) +  
  stat_summary(geom="line",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge(), width=.1) +
  geom_smooth()+
  labs(title="Average Learning Curves", y="Accuracy") + eg + tlt


lavgDist <- dCat |> filter(Phase==1) |>
  group_by(sbjCode,condit, Block) |>
  summarise(Corr=mean(Corr)) |>
  ggplot(aes(x=Block, y=Corr, col=condit, group=condit)) +  
   ggdist::stat_pointinterval(alpha=.5, position=position_dodge()) +
  #geom_smooth() +
  labs(title="Average Learning Curves", y="Accuracy") + eg +tlt

lqt <- dCat |> filter(Phase==1) |>
  ggplot(aes(x=Block, y=Corr, col=condit, group=condit)) +  
  stat_summary(geom="line",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge(), width=.1) +
  facet_wrap(~quartile) +
  labs(title="Learning Curves - End Training Quartiles",
       subtitle=stringr::str_wrap("Quartiles are based on accuracy in the final training block (within condition)",65),
       y="Accuracy") + 
  eg + tln

lqte <- dCat |> filter(Phase==1) |>
  ggplot(aes(x=Block, y=Corr, col=condit, group=condit)) +  
  stat_summary(geom="line",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge(), width=.1) +
  facet_wrap(~q_test_high) +
  labs(title="Learning Curves - Test High Distortion Quartiles", 
       subtitle=stringr::str_wrap("Quartiles are based on accuracy on the new high distortion TEST items (within condition)",60),
       y="Accuracy") + 
  eg+ tln


lte_g50h <- dCat |> filter(Phase==1, test_high>.50) |>
  ggplot(aes(x=Block, y=Corr, col=condit, group=condit)) +  
  stat_summary(geom="line",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge(), width=.1) +
  labs(title="Learning Curves - Test High Distortion > 50%", 
       subtitle=stringr::str_wrap("only sbjs. who would go on to have GREATER than 50% on new high distortion patterns",55),
       y="Accuracy") + 
  eg+ tlt


lte_l50h <- dCat |> filter(Phase==1, test_high<.50) |>
  ggplot(aes(x=Block, y=Corr, col=condit, group=condit)) +  
  stat_summary(geom="line",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge(), width=.1) +
  labs(title="Learning Curves - Test High Distortion < 50%", 
       subtitle=stringr::str_wrap("only sbjs. who would go on to have LESS than 50% on new high distortion patterns",55),
       y="Accuracy") + 
  eg+ tln


# lte_g50o <- dCat |> filter(Phase==1, test_low>.42) |>
#   ggplot(aes(x=Block, y=Corr, col=condit, group=condit)) +  
#   stat_summary(geom="line",fun=mean, position=position_dodge())+
#   stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge(), width=.1) +
#   labs(title="Learning Curves - Test High Distortion > 50%", 
#        subtitle=stringr::str_wrap("only sbjs. who would go on to have GREATER than 50% on new high distortion patterns",55),
#        y="Accuracy") + 
#   eg+ tlt
# 
# 
# lte_l50o <- dCat |> filter(Phase==1, test_low<.50) |>
#   ggplot(aes(x=Block, y=Corr, col=condit, group=condit)) +  
#   stat_summary(geom="line",fun=mean, position=position_dodge())+
#   stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge(), width=.1) +
#   labs(title="Learning Curves - Test High Distortion < 50%", 
#        subtitle=stringr::str_wrap("only sbjs. who would go on to have LESS than 50% on new high distortion patterns",55),
#        y="Accuracy") + 
#   eg+ tln

#((lavg +lavgDist)/(lqt + lqte) / (lte_g50 + lte_l50) / (lte_g70 + lte_l40)) 
#((lavg +lavgDist)/(lte_g50h + lte_l50h) / (lte_g50o + lte_l50o)) 
((lavg +lavgDist)/(lte_g50h + lte_l50h)) 



yt1 <- round(seq(500,4000,length.out=7), 2)
eg2 <- list(scale_y_continuous(breaks=yt, limits=c(min(yt1),max(yt1))))
eg1 <- list(scale_y_continuous(breaks=yt, n.breaks=7))
            
lavg <- dCat |> filter(Phase==1) |>
  group_by(sbjCode,condit, Block) |>
  summarise(rt=median(rt)) |>
  ggplot(aes(x=Block, y=rt, col=condit, group=condit)) +  
  stat_summary(geom="line",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge(), width=.1) +
  geom_smooth()+
  labs(title="Average Learning Curves", y="Accuracy")  +tlt 


lavgDist <- dCat |> filter(Phase==1) |>
  group_by(sbjCode,condit, Block) |>
  summarise(rt=median(rt)) |>
  ggplot(aes(x=Block, y=rt, col=condit, group=condit)) +  
   ggdist::stat_pointinterval(alpha=.5, position=position_dodge()) +
  #geom_smooth() +
  labs(title="Average Learning Curves", y="Accuracy")  +tlt

lte_g50h <- dCat |> filter(Phase==1, test_high>.50) |>
  group_by(sbjCode,condit, Block) |>
  summarise(rt=median(rt)) |>
  ggplot(aes(x=Block, y=rt, col=condit, group=condit)) +  
  stat_summary(geom="line",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge(), width=.1) +
  labs(title="Learning Curves - Test High Distortion > 50%", 
       subtitle=stringr::str_wrap("only sbjs. who would go on to have GREATER than 50% on new high distortion patterns",55),
       y="Accuracy") + 
   tlt


lte_l50h <- dCat |> filter(Phase==1, test_high<.50) |>
   group_by(sbjCode,condit, Block) |>
  summarise(rt=median(rt)) |>
  ggplot(aes(x=Block, y=rt, col=condit, group=condit)) +  
  stat_summary(geom="line",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge(), width=.1) +
  labs(title="Learning Curves - Test High Distortion < 50%", 
       subtitle=stringr::str_wrap("only sbjs. who would go on to have LESS than 50% on new high distortion patterns",55),
       y="Accuracy") + 
   tln

((lavg +lavgDist)/(lte_g50h + lte_l50h)) 


dCat |> filter(condit=="high", Phase==1) |>
  ggplot(aes(x=Block, y=Corr)) +  
  stat_summary(shape=0,geom="point",fun="mean")+
  stat_summary(geom="line",fun="mean",col="red")+
  facet_wrap(~sbjCode)+ylim(c(0,1))+
  geom_hline(yintercept = .33,linetype="dashed")+
  ggtitle("High Training - Learning Curves")+
  xlab("Training Block")+ylab("Proportion Correct")+scale_x_continuous(breaks=seq(1,10))


dCat |> filter(condit=="low", Phase==1) |>
  ggplot(aes(x=Block, y=Corr)) +  
  stat_summary(shape=0,geom="point",fun="mean")+
  stat_summary(geom="line",fun="mean",col="red")+
  facet_wrap(~sbjCode)+ylim(c(0,1))+
  geom_hline(yintercept = .33,linetype="dashed")+
  ggtitle("Low Training - Learning Curves")+
  xlab("Training Block")+ylab("Proportion Correct")+scale_x_continuous(breaks=seq(1,10))


dCat |> filter(condit=="medium", Phase==1) |>
  ggplot(aes(x=Block, y=Corr)) +  
  stat_summary(shape=0,geom="point",fun="mean")+
  stat_summary(geom="line",fun="mean",col="red")+
  facet_wrap(~sbjCode)+ylim(c(0,1))+
  geom_hline(yintercept = .33,linetype="dashed")+
  ggtitle("Medium Training - Learning Curves")+
  xlab("Training Block")+ylab("Proportion Correct")+scale_x_continuous(breaks=seq(1,10))


dCat |> filter(condit=="mixed", Phase==1) |>
  ggplot(aes(x=Block, y=Corr)) +  
  stat_summary(shape=0,geom="point",fun="mean")+
  stat_summary(geom="line",fun="mean",col="red")+
  facet_wrap(~sbjCode)+ylim(c(0,1))+
  geom_hline(yintercept = .33,linetype="dashed")+
  ggtitle("Mixed Training - Learning Curves")+
  xlab("Training Block")+ylab("Proportion Correct")+scale_x_continuous(breaks=seq(1,10))


tx <- theme(axis.text.x=element_blank() )

dht <- dCat |> filter(condit=="high", Phase==2) |>
  ggplot(aes(x=Pattern_Token, y=Corr, fill=Pattern_Token)) +  
  stat_summary(geom="bar",fun="mean")+
  facet_wrap(~sbjCode, ncol=8)+
  ylim(c(0,1))+
  geom_hline(yintercept = .33,linetype="dashed", alpha=.5)+
  ggtitle("High Distortion Training - Testing")+
  xlab("Pattern Type")+ylab("Proportion Correct") +
  theme(legend.position = "top") + tx

dlt <- dCat |> filter(condit=="low", Phase==2) |>
  ggplot(aes(x=Pattern_Token, y=Corr, fill=Pattern_Token)) +  
  stat_summary(geom="bar",fun="mean")+
  facet_wrap(~sbjCode, ncol=8)+
  ylim(c(0,1))+
  geom_hline(yintercept = .33,linetype="dashed", alpha=.5)+
  ggtitle("Low Distortion Training - Testing")+
  xlab("Pattern Type")+ylab("Proportion Correct")+
  tx +theme(legend.position = "none")

dmt <- dCat |> filter(condit=="medium", Phase==2) |>
  ggplot(aes(x=Pattern_Token, y=Corr, fill=Pattern_Token)) +  
  stat_summary(geom="bar",fun="mean")+
  facet_wrap(~sbjCode, ncol=8)+
  ylim(c(0,1))+
  geom_hline(yintercept = .33,linetype="dashed", alpha=.5)+
  ggtitle("Medium Distortion Training - Testing")+
  xlab("Pattern Type")+ylab("Proportion Correct") +
  theme(legend.position = "none")+
  tx +theme(legend.position = "none")

dmxt <- dCat |> filter(condit=="mixed", Phase==2) |>
  ggplot(aes(x=Pattern_Token, y=Corr, fill=Pattern_Token)) +  
  stat_summary(geom="bar",fun="mean")+
  facet_wrap(~sbjCode, ncol=8)+
  ylim(c(0,1))+
  geom_hline(yintercept = .33,linetype="dashed", alpha=.5)+
  ggtitle("Mixed Distortion Training - Testing")+
  xlab("Pattern Type")+ylab("Proportion Correct")+
  tx +theme(legend.position = "none")

(dht + dlt)/(dmt+dmxt)


library(gghalves)


dCat |> filter(Phase==2) |> 
  group_by(sbjCode, Pattern_Token,condit) |>
  summarise(propCor=mean(Corr),.groups = 'keep') |>
  ggplot(aes(x=Pattern_Token, y=propCor, fill=Pattern_Token, group=Pattern_Token)) +  
  geom_half_violin(color=NA)+ # remove border color
  geom_half_boxplot(position=position_nudge(x=-0.05),side="r",outlier.shape = NA,center=TRUE,
                    errorbar.draw = FALSE,width=.25)+
  geom_half_point(transformation = position_jitter(width = 0.05, height = 0.05),size=.3,aes(color=Pattern_Token))+
  labs(title="High Testing", y="Accuracy") +
  facet_wrap(~condit)



dCat |> filter(Phase==2) |> 
  group_by(sbjCode, Pattern_Token,condit) |>
  summarise(rt=median(rt),.groups = 'keep') |>
  ggplot(aes(x=Pattern_Token, y=rt, fill=Pattern_Token, group=Pattern_Token)) +  
  geom_half_violin(color=NA)+ # remove border color
  geom_half_boxplot(position=position_nudge(x=-0.05),side="r",outlier.shape = NA,center=TRUE,
                    errorbar.draw = FALSE,width=.25)+
  geom_half_point(transformation = position_jitter(width = 0.05, height = 0.05),size=.3,aes(color=Pattern_Token))+
  labs(title="High Testing", y="Accuracy") +
  facet_wrap(~condit)





dCat |> filter(finalTrain<=.70, Phase==2) |>
  ggplot(aes(x=Pattern_Token, y=Corr, fill=condit, group=condit)) +  
  stat_summary(geom="bar",fun=mean, position=position_dodge())+
  stat_summary(geom="errorbar", fun.data=mean_se, position=position_dodge()) +
  labs(title="High Testing", y="Accuracy") 


d %>% filter(Phase==2) %>% ggplot(aes(x=distortion,y=Corr,col=condit))+
  stat_summary(shape=0,geom="point",fun="mean")+
  stat_summary(geom="line",fun="mean",col="red")+
  #facet_wrap(~id)+ylim(c(0,1))+
  geom_hline(yintercept = .33,linetype="dashed")+
  ggtitle("Hu & Nosofsky Experiment 2 - Learning. Rep Subjects - Average Accuracy Per Block.")+
  xlab("Training Block")+ylab("Proportion Correct")+
  scale_x_continuous(breaks=seq(1,15))



tx1 <- theme(axis.title.x=element_blank(), axis.text.x=element_blank())
tx2 <- theme(axis.title.x=element_blank(), axis.text.x=element_blank(),legend.position = "none" )
yt <- round(seq(0,1,length.out=7), 2)
eg <- list(geom_hline(yintercept = c(.33, .66),linetype="dashed", alpha=.5),scale_y_continuous(breaks=yt))


htq <- dCat |> filter(condit=="high", Phase==2) |>
  ggplot(aes(x=Pattern_Token, y=Corr, fill=Pattern_Token)) +  
  stat_summary(geom="bar",fun="mean")+
  stat_summary(geom="errorbar", fun.data=mean_se, width=.1) +
  eg +
  facet_wrap(~quartile) + 
  labs(title="High Training Sbjs.", y="Proportion Correct") +tx2

ltq <- dCat |> filter(condit=="low", Phase==2) |>
  ggplot(aes(x=Pattern_Token, y=Corr, fill=Pattern_Token)) +  
  stat_summary(geom="bar",fun="mean")+
  stat_summary(geom="errorbar", fun.data=mean_se, width=.1) +
  eg +
  facet_wrap(~quartile) + 
  labs(title="Low Training Sbjs.", y="Proportion Correct") +tx1

mtq <- dCat |> filter(condit=="medium", Phase==2) |>
  ggplot(aes(x=Pattern_Token, y=Corr, fill=Pattern_Token)) +  
  stat_summary(geom="bar",fun="mean")+
  stat_summary(geom="errorbar", fun.data=mean_se, width=.1) +
  eg +
  facet_wrap(~quartile) + 
  labs(title="Med Training Sbjs.", y="Proportion Correct") +tx2


mxtq <- dCat |> filter(condit=="mixed", Phase==2) |>
  ggplot(aes(x=Pattern_Token, y=Corr, fill=Pattern_Token)) +  
  stat_summary(geom="bar",fun="mean")+
  stat_summary(geom="errorbar", fun.data=mean_se, width=.1) +
  eg +
  facet_wrap(~quartile) + 
  labs(title="Mixed Training Sbjs.", y="Proportion Correct")  + tx1
  


(htq+ltq)/(mtq+mxtq) + plot_annotation(
  title = 'Testing Accuracy by Quartile',
  subtitle = 'Quartiles set by Final TRAINING block',
  caption = 'bars reflect mean accuracy, error bars reflect standard error. Quartiles are set by ACCURACY in the final training block. Bar colors are pattern type.'
)


# pkgs <- grateful::cite_packages(output = "table", pkgs="Session",out.dir = "assets", cite.tidyverse=TRUE)
# knitr::kable(pkgs)
# 
# grateful::cite_packages(output = "paragraph",pkgs="Session",
#                         out.dir = "assets", cite.tidyverse=TRUE)
# 
# 
# pkgs <- grateful::cite_packages(output = "table",pkgs="Session",
#                         out.dir = "assets", cite.tidyverse=TRUE)
# knitr::kable(pkgs)
# #
# #
# pkgs <- cite_packages(cite.tidyverse = TRUE,
#                       output = "table",
#                       bib.file = "grateful-refs.bib",
#                       include.RStudio = TRUE,
#                       omit=c("colorout","viridis"),
#                       out.dir = getwd())
# formattable::formattable(pkgs,
#             table.attr = 'class=\"table table-striped\" style="font-size: 14px; font-family: Lato; width: 80%"')

options(renv.config.dependencies.limit = Inf)
pkgs <- suppressWarnings(scan_packages(pkgs="Session",cite.tidyverse = TRUE))
 
knitr::kable(pkgs)
usedthese::used_here()
#SystemInfo()
