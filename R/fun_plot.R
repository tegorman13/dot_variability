
theme_blank <- theme(
  panel.grid = element_blank(),
  axis.text = element_blank(),
  axis.title = element_blank(),
  axis.ticks = element_blank()
)






plot_dotsAll <- function(df) {
  plots <- list()

  for (i in 1:nrow(df)) {
    pair_info <- pairCounts |> filter(pair_label==df[i,]$pair_label) |>
      mutate(across(where(is.numeric), ~round(., 2))) 
    title= paste0("Mean Rating: ",pair_info$mean_resp, ";   SD: ",pair_info$sd, ";   N Ratings: ",pair_info$n)



    pat1 <- df[i,] %>%
          mutate(pattern_1 = purrr::map(pattern_1, jsonlite::fromJSON)) %>%
          unnest(pattern_1) %>%
          mutate(y=-y, pat=item_label_1) 

    pat2 <- df[i,] %>%
          mutate(pattern_2 = purrr::map(pattern_2, jsonlite::fromJSON)) %>%
          unnest(pattern_2) %>%
          mutate(y=-y, pat=item_label_2) 

    pat <- rbind(pat1,pat2)

    p1 <- pat |> 
    ggplot(aes(x = x, y = y)) +
          geom_point() +
          coord_cartesian(xlim = c(-25, 25), ylim = c(-25, 25)) +
          theme_minimal() +
          facet_wrap(~pat,ncol=2) + theme_blank +
          labs(title=title) +
          theme(plot.title = element_text(size = 12,hjust=.5), 
                strip.text = element_text(size = 7,hjust=.5),
                panel.spacing.x=unit(-9, "lines"))

  plots <- append(plots, list(p1 ))
  }

  patchwork::wrap_plots(plots,ncol=1)

}



plot_dotsAll_old2 <- function(df) {
  plots <- list()

  for (i in 1:nrow(df)) {

      pair_info <- pairCounts |> filter(pair_label==df[i,]$pair_label)
      title= paste0("Mean Similarity Rating: ",pair_info$mean_resp, " SD of Similarity Rating: ",pair_info$sd)

    p1 <- df[i, ] %>%
      mutate(pattern_1 = purrr::map(pattern_1, jsonlite::fromJSON)) %>%
      unnest(pattern_1) %>%
       mutate(y=-y) |>
      ggplot(aes(x = x, y = y)) +
      geom_point() +
      coord_cartesian(xlim = c(-25, 25), ylim = c(-25, 25)) +
      theme_minimal() +
      labs(title=title, subtitle = df$item_label_1[i]) + theme_blank + 
      theme(plot.title = element_text(size = 15,hjust=.9,vjust=2))

    p2 <- df[i, ] %>%
      mutate(pattern_2 = purrr::map(pattern_2, jsonlite::fromJSON)) %>%
      unnest(pattern_2) %>%
       mutate(y=-y) |>
      ggplot(aes(x = x, y = y)) +
      geom_point() +
      coord_cartesian(xlim = c(-25, 25), ylim = c(-25, 25)) +
      theme_minimal() +
      labs(subtitle = df$item_label_2[i]) + theme_blank + 
       theme(plot.subtitle = element_text(size = 8))

    # design_layout <- "
    # #3##
    # 1122
    # "
    # p1 + p2 + grid::textGrob(title) + plot_layout(design = design_layout)

    plots <- append(plots, list(p1, p2 ))
  }
  patchwork::wrap_plots(plots,ncol=2) 
}








plot_dotsAll_orig <- function(df) {
  # Transform the dataframe to a long format for plotting
  df_long <- df %>%
    pivot_longer(cols = starts_with("x") | starts_with("y"),
                 names_pattern = "([xy])(\\d)",
                 names_to = c(".value", "dot")) %>%
    group_by(id) %>%
    mutate(dot = as.numeric(dot)) %>%
     mutate(y=-y) |>
    arrange(dot)
  
  plots <- list()
  
  # Iterate over each unique ID to generate plots
  unique_ids <- unique(df_long$id)
  for (id in unique_ids) {
    # Filter the dataframe for the current ID
    df_filtered <- filter(df_long, id == !!id)
    
    # Plot
    p <- ggplot(df_filtered, aes(x = x, y = y)) +
      geom_point() +
      coord_cartesian(xlim = c(-25, 25), ylim = c(-25, 25)) +
      theme_minimal() +
      labs(title = id) + 
      theme(
        panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank()
      )
    
    plots <- append(plots, list(p))
  }
  
  # Use patchwork to arrange all plots in a grid
  return(wrap_plots(plots, ncol = 2))
}







plot_dots <- function(df) {
  df %>%
    mutate(pattern_1 = purrr::map(pattern_1, jsonlite::fromJSON)) %>%
    unnest(pattern_1) %>%
     mutate(y=-y) |>
    ggplot(aes(x = x, y = y)) +
    geom_point() +
    coord_cartesian(xlim = c(-25, 25), ylim = c(-25, 25)) +
    theme_minimal()
}

plot_dots2 <- function(df) {
  p1 <- df %>%
    mutate(pattern_1 = purrr::map(pattern_1, jsonlite::fromJSON)) %>%
    unnest(pattern_1) %>%
     mutate(y=-y) |>
    ggplot(aes(x = x, y = y)) +
    geom_point() +
   # coord_fixed(ratio = 1) +
    coord_cartesian(xlim = c(-25, 25), ylim = c(-25, 25)) +
    theme_minimal() +
    labs(title = df$item_label_1[1])

  p2 <- df %>%
    mutate(pattern_2 = purrr::map(pattern_2, jsonlite::fromJSON)) %>%
    unnest(pattern_2) %>%
     mutate(y=-y) |>
    ggplot(aes(x = x, y = y)) +
    geom_point() +
    #coord_fixed(ratio = 1) +
    coord_cartesian(xlim = c(-25, 25), ylim = c(-25, 25)) +
    theme_minimal() +
    labs(title = df$item_label_2[1])

  p1 + p2
}



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
