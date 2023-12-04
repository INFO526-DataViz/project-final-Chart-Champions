# Analysis Outline

## How to Run

`functions_celestial_objects.qmd`

-   Render this file to get the output of the celestial map visualization.

-   You can change the location by passing a value to *`desired_place`* variable in the first cell if the **Testing section**. You can also pass a custom date and time in the same cell.

-   After changing parameters, run all cells under **Testing section** to regenerate the map.

## File Description

`functions_celestial_objects.qmd`

-   Helper functions to generate celestial map for any given location and given time

## Outcome

A beautified celestial map for a given location that can be deployed for custom map generation

![sample_celestial_map_output](imgs/sample_celestial_map_output){fig-alt="sample celestial map output" fig-align="center" width="75%"}

## Goal (Next Steps)

1.  Create a GUI using the scripts, function and additional parameters for customization using Shiny.

2.  Deploy the Shiny App.
