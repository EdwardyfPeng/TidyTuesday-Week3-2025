## load package
library(tidyverse)
library(ggplot2)
library(lubridate)
library(ggridges)
library(ggpubr)
library(patchwork)
library(grid)

## set theme
my_theme <- theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size=14),
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 12, face="bold"),
    axis.subtitle = element_text(size=12),
    legend.position = "bottom"
  )
theme_set(my_theme)

## load data
exped_tidy <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-01-21/exped_tidy.csv')
peaks_tidy <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-01-21/peaks_tidy.csv')

## Data preprocessing
exped_tidy <- exped_tidy %>% 
  filter(TOTMEMBERS > 0) %>%
  mutate(
    SUCCESS = SUCCESS1 | SUCCESS2 | SUCCESS3 | SUCCESS4,
    DAY_OF_YEAR = yday(BCDATE),
    TEAMSIZE = cut(
      TOTMEMBERS,
      breaks = c(0, 5, 10, 15, Inf),
      labels = c("1-5", "6-10", "11-15", "15+"),
      right = TRUE
    )
  )

# for plot 1
top_range <- peaks_tidy %>%
  group_by(HIMAL_FACTOR) %>%
  summarise(mean_height = mean(HEIGHTM, na.rm = TRUE)) %>%
  top_n(5, mean_height)  # filter top 5
filtered_peaks <- peaks_tidy %>%
  filter(HIMAL_FACTOR %in% top_range$HIMAL_FACTOR)
range_counts <- filtered_peaks %>%
  group_by(HIMAL_FACTOR) %>%
  summarise(attempts = n())
mean_height <- mean(filtered_peaks$HEIGHTM, na.rm = TRUE)

# for plot 2
team_o2_success <- exped_tidy %>%
  group_by(TEAMSIZE, O2USED) %>%
  summarise(
    totalexpid = n(),
    successes = sum(SUCCESS == TRUE, na.rm = TRUE),
    successrate = successes / totalexpid,
    .groups = "drop"
  ) 
team_success_overall <- exped_tidy %>%
  group_by(TEAMSIZE) %>%
  summarise(
    totalexpid = n(),
    successes = sum(SUCCESS == TRUE, na.rm = TRUE),
    successrate = successes / totalexpid,
    .groups = "drop"
  )

# for plot 3
peaks_tidy_selected <- peaks_tidy %>%
  select(PEAKID, PKNAME)
exped_tidy <- exped_tidy %>%
  left_join(peaks_tidy_selected, by = "PEAKID") 
top_peaks <- exped_tidy %>%
  count(PKNAME, sort = TRUE) %>%
  top_n(10, n) %>%
  pull(PKNAME) 
exped_top <- exped_tidy %>%
  filter(PKNAME %in% top_peaks) 

## make compound plot
# p1: Which mountain range has the highest average peak height?
p1 <- ggplot(filtered_peaks, 
             aes(x = HEIGHTM, y = reorder(HIMAL_FACTOR, HEIGHTM), fill = OPEN)) +
  geom_density_ridges(alpha = 0.7) +
  scale_fill_brewer(palette = "Set1") +
  geom_text(data = range_counts, 
            aes(x = mean_height + 1500, 
                y = HIMAL_FACTOR, 
                label = paste0(attempts, " attempts in total")), 
            inherit.aes = FALSE, 
            size = 4, nudge_y = 0.3, col = "gray20") +
  labs(
    title = "Which mountain range has the highest average peak height?",
    subtitle = "Distribution of height for top-5 ranges in mean height categorized by open status",
    x = "Peak Height (m)",
    y = "Mountain Range"
  )

# p2: The influence of team size on success rate
p2 <- ggplot() +
  geom_col(
    data = team_o2_success, 
    aes(x = TEAMSIZE, y = successrate, fill = O2USED),
    width = 0.7, col = "black", alpha = 0.7, position = "dodge") +
  geom_line(
    data = team_success_overall,
    aes(x = TEAMSIZE, y = successrate, group=1),
    color = "black", size = 1) +
  geom_point(
    data = team_success_overall, 
    aes(x = TEAMSIZE, y = successrate), 
    color = "black", size = 3) +
  scale_fill_brewer(palette = "Set1") +
  labs(
    title = "Larger Team and Using Oxygen Contributes to Successful Summit",
    subtitle = "Success rate comparison by team size and oxygen use",
    x = "Team Size",
    y = "Success Rate",
    fill = "Oxygen Used"
  ) 

# p3: Season trend of expedition success & failure
p3 <- ggplot(exped_top, aes(x = DAY_OF_YEAR, y = factor(PKNAME), color = SUCCESS)) +
  geom_jitter(alpha = 0.7, size = 2) + 
  scale_color_brewer(palette = "Set1") +
  labs(
    title = "Spatial-temporal features of Summit: \n More successes happened in Spring and Everest",
    subtitle = "Top 10 most popular peaks: Spatial-temporal pattern of expedition success & failure",
    x = "Day of Year",
    y = "Peak Name",
    color = "Success"
  )

compound <- p1/p2/p3 + 
  plot_layout(heights = unit(c(8, 8, 8), c('cm', 'cm', 'cm'))) +
  plot_annotation(
    title = "The History of Himalayan Mountaineering Expeditions",
    subtitle = "In this visualization, we used the dataset from the Himalayan Database from 2020 to 2024. \n First we explored the distribution of height for each mountain range categorized by open status, \n And then we focused on the influence of team size, oxygen use, season on the rate of successful summit.",
    caption = "Author: Edward Peng | #TidyTuesday:2025 Week 3 | Source: The Himalayan Database",
    theme = theme(
      plot.title = element_text(size = 18, face = "bold", hjust = 0.5), 
      plot.subtitle = element_text(size = 14), 
      plot.caption = element_text(size = 12, hjust = 0.5),
      plot.background = element_rect(fill = "beige")
    )
  )

ggsave("combined_plot.png", compound, height = 16, width = 10, dpi = 500)