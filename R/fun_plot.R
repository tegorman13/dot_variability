
theme_blank <- theme(
  panel.grid = element_blank(),
  axis.text = element_blank(),
  axis.title = element_blank(),
  axis.ticks = element_blank()
)

plot_dotsAll <- function(df) {
  plots <- list()

  for (i in 1:nrow(df)) {
    p1 <- df[i, ] %>%
      mutate(pattern_1 = purrr::map(pattern_1, jsonlite::fromJSON)) %>%
      unnest(pattern_1) %>%
      ggplot(aes(x = x, y = y)) +
      geom_point() +
      coord_cartesian(xlim = c(-25, 25), ylim = c(-25, 25)) +
      theme_minimal() +
      labs(title = df$item_label_1[i]) + theme_blank

    p2 <- df[i, ] %>%
      mutate(pattern_2 = purrr::map(pattern_2, jsonlite::fromJSON)) %>%
      unnest(pattern_2) %>%
      ggplot(aes(x = x, y = y)) +
      geom_point() +
      coord_cartesian(xlim = c(-25, 25), ylim = c(-25, 25)) +
      theme_minimal() +
      labs(title = df$item_label_2[i]) + theme_blank

    plots <- append(plots, list(p1, p2))
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
    ggplot(aes(x = x, y = y)) +
    geom_point() +
    coord_cartesian(xlim = c(-25, 25), ylim = c(-25, 25)) +
    theme_minimal()
}

plot_dots2 <- function(df) {
  p1 <- df %>%
    mutate(pattern_1 = purrr::map(pattern_1, jsonlite::fromJSON)) %>%
    unnest(pattern_1) %>%
    ggplot(aes(x = x, y = y)) +
    geom_point() +
   # coord_fixed(ratio = 1) +
    coord_cartesian(xlim = c(-25, 25), ylim = c(-25, 25)) +
    theme_minimal() +
    labs(title = df$item_label_1[1])

  p2 <- df %>%
    mutate(pattern_2 = purrr::map(pattern_2, jsonlite::fromJSON)) %>%
    unnest(pattern_2) %>%
    ggplot(aes(x = x, y = y)) +
    geom_point() +
    #coord_fixed(ratio = 1) +
    coord_cartesian(xlim = c(-25, 25), ylim = c(-25, 25)) +
    theme_minimal() +
    labs(title = df$item_label_2[1])

  p1 + p2
}

