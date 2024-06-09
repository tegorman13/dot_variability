pacman::p_load(dplyr,purrr,tidyr,ggplot2,here,patchwork, conflicted, stringr, jsonlite,ggh4x)
options(digits=2, scipen=999, dplyr.summarise.inform=FALSE)
#walk(c("fun_plot"), ~ source(here::here(paste0("R/", .x, ".R"))))

pairCounts <- readRDS(here("data/pairCounts.rds")) |> arrange(mean_resp)


pair_plot <- function(Pair,item_labels=FALSE){
  df <- d |> filter(pair_label==Pair) |> slice_head(n=1) 
  dim1=35
  x_limits <- c(-dim1, dim1)  # Set fixed x-axis limits
  y_limits <- c(-dim1, dim1)  # Set fixed y-axis limits

    pat1 <- df %>%
          mutate(pattern_1 = purrr::map(pattern_1, jsonlite::fromJSON)) %>%
          unnest(pattern_1) %>%
          mutate(y=-y, pat=item_label_1) |> select(pair_label,x,y,pat)

    pat2 <- df %>%
          mutate(pattern_2 = purrr::map(pattern_2, jsonlite::fromJSON)) %>%
          unnest(pattern_2) %>%
          mutate(y=-y, pat=item_label_2) |> select(pair_label,x,y,pat)

    pat <- rbind(pat1,pat2)
    pat |> 
    ggplot(aes(x = x, y = y #,fill=pat,col=pat
              )) +
          geom_point(alpha=2,size=.8) +
          coord_cartesian(xlim = x_limits, ylim =y_limits) +
          theme_minimal() +
          facet_wrap(~pat,ncol=2,scales = "fixed") + #axes="all"
          #theme_blank +
          theme_void() + 
          theme(strip.text = element_text(size = 7,hjust=.5),
                #panel.spacing.x=unit(-8.5, "lines"), 
                #strip.background = element_rect(colour = "black", linewidth = 2),
              strip.text.x  = if(item_labels) element_text() else element_blank(), # remove pattern labels
                panel.border = element_blank(),  # Remove borders around facets
                legend.position = "none",
                plot.background = element_rect(fill = "white"),
                panel.background = element_rect(fill = "white"),
        #axis.line.y = element_line(colour = "black", linewidth = .1)
        ) +
      xlim(x_limits[1], x_limits[2]) +  # Set x-axis limits explicitly
    ylim(y_limits[1], y_limits[2])    # Set y-axis limits explicitly
}

# Function to save the plot for each pair
save_pair <- function(Pair) {
  p <- pat_table_plot(Pair)
  ggsave(filename = paste0(here("Stimulii/pair_images/"),Pair, ".png"), plot = p,width = 4, height = 3, dpi = 200)
}


p5 <- pairCounts |> filter(n>=29) 

p5 |> slice_head() |> pull(pair_label) |>  pair_plot(item_labels=FALSE)

p5 |> 
  #slice_head() |> 
  pull(pair_label) |> walk(plot_pair)


# 3 least similar
p5 |> slice_tail(n=3) |> arrange(desc(mean_resp)) |> pull(pair_label) |> map(pair_plot, item_label=TRUE)

# 3 most similar

p5 |> slice_tail(n=3) |> arrange(mean_resp) |> pull(pair_label) |> map(pair_plot, item_label=TRUE)


p5 |> slice_head(n=3)
