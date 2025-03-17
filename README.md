# TidyTuesday-Week3-2025
Homework 3 of STAT436 for Spring 2024 in UWMadison

## Introduction

![W020181207550411490422](https://github.com/user-attachments/assets/421f0886-929c-4bd5-9bd8-e933f9f3041c)

The data we use were collected and published by a non-profit organization named **The Himalayan Database**, which details climbing statuses, geographic information of each expeditions and peaks in the Nepal Himalaya from 2020 to 2024. 

The data could be viewed by
```
exped_tidy <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-01-21/exped_tidy.csv')
peaks_tidy <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-01-21/peaks_tidy.csv')
```

## Questions of interest:

  • Which mountain range has the highest average peak height and what is the distribution of peak heights for peaks that are open versus those that are not?
  
  • What is the influence of team size, oxygen use and spatial-temporal factors on the rate of successful summit?

## My response

To answer the first question, I made a ridge plot to show the distribution of height for top-5 mountain ranges in mean height, categorized by the open status. **The Kangchen-junga/Simhalila has the highest mean peak height and in general, open peaks seem to have higher mean peak height than those are not open.**

To answer the second question, first I made a dodged bar chart with a line plot to show that larger team size and the use of supplemental oxygen is helpful to summit success. Then
I made a scatter plot to explore the spatial-temporal pattern of success/failure for top-10 popular peaks. **It is shown that more successes happened in Spring, on the peak of Everest and Lhotse. In winter, most successes happened on Ama Dablam and most failures happen on Manaslu.**

A compound plot was created to integrate the graphs above, using the `patchwork` package in `R`.

![combined_plot](https://github.com/user-attachments/assets/5aad1479-a658-46fa-a38d-96f54d08fe47)

## Reference
[1] Sankaran (2025, Jan. 14). STAT 436 (Spring 2025): Ridge Plots. Retrieved from https://krisrs1128.github.io/stat436_s25/website/stat436_s25/posts/2024-12-27-week03-02/

[2] Sankaran (2025, Jan. 14). STAT 436 (Spring 2025): Patchwork. Retrieved from https://krisrs1128.github.io/stat436_s25/website/stat436_s25/posts/2024-12-27-week03-04/

[3] https://stevenponce.netlify.app/data_visualizations/TidyTuesday/2025/tt_2025_03.html
