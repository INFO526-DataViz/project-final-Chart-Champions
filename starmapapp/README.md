# GUI using Shiny

This script utilizes the shinypackage and shinyapps.io services to host the constellation maps app.

## 🌠 Constellation Maps

Everyone has had the experience of wanting to know the name of the constellation currently visible in the sky. At least once, we've all heard the myths and stories of how constellations were named when we were young. Also, we might want to explore the sky in places or time zones where we have not experienced before.

So, how can we observe the skies in different places and time zones? That is the main focus of this project. By utilizing geospatial data, celestial information, and a bit of astronomical knowledge, we can traverse space-time and behold the beauty of various constellations. We created a sky map and published an interactive Shiny app, allowing users to input city, time, and accessible color preferences.

## Deployment

🔗 The GUI made with the script in the `starmapapp/` folder has been deployed on this link: ([Shiny App for Celestial Map](https://bag6d9-visalakshi-iyer.shinyapps.io/starmapapp/))

## File Description

-   `starmapapp/`: This folder contains the code for GUI built using Shiny App

    -   `app.R`: This file contains the code for Shiny App UI and Server

    -   `data_transformation.R`: This file contains the code to transform the dataset into relevant simple feature objects

    -   `helper_functions.R`: This file contains the code to convert raw user input into celestial translation. For example converting date-time into MST lat-lon.

    -   `plot_graphs.R`: This file contains the code for plotting functions
