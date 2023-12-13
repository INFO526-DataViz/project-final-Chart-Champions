# project-final

Final project repo for INFO 526 - Fall 2023.

# 🌠 Constellation Maps

This project was developed by the Chart Champions For INFO 526 - Data Analysis & Visualization at the University of Arizona, taught by Dr. Greg Chism. The team is comprised of the following team members.

Megan Hokama: Third-year Ph.D. student in Educational Psychology at University of Arizona.

Sai Madhuri Kandula: First-year graduate student pursuing Data Science at University of Arizona.

Visalakshi Prakash Iyer: First-year graduate student pursuing Data Science at University of Arizona.

Kiwoon Hong : First-year graduate student pursuing Data Science at University of Arizona.

Tejashwini Kasa: First-year graduate student pursuing Data Science at University of Arizona.

## Deployment

🔗 The GUI made with the script in the `starmapapp/` folder has been deployed on this link: ([Shiny App for Celestial Map](https://bag6d9-visalakshi-iyer.shinyapps.io/starmapapp/))

## Repo Organization

-   `.github`: This directory contain files related to GitHub, such as workflows, issue templates, or other configurations.

-   `_extra`: Contains code, notes and other files used during experimentation. Contents of this folder is not a part of the final output.

-   `_freeze`: The folder created to store files generated during project render.

-   `data/`: This folder contains data files or datasets that are used in the project.

    -   `README.md` : A readme file that describes the datasets in more detail.

-   `images`: This folder contains image files that are used in the project, such as illustrations, diagrams, or other visual assets.

-   `analysis/`: This folder contains the analysis scripts used to generate output for the project outline.

    -   README.md: describes the steps to run and generate the results using scripts

    -   functions_celestial_objects.qmd: Helper functions to generate celestial map for any given location and given time

    -   imgs/: A folder containing the sample output of the plot generated from the code

-   `starmapapp/`: This folder contains the code for GUI built using Shiny App

    -   `app.R`: This file contains the code for Shiny App UI and Server

    -   `data_transformation.R`: This file contains the code to transform the dataset into relevant simple feature objects

    -   `helper_functions.R`: This file contains the code to convert raw user input into celestial translation. For example converting date-time into MST lat-lon.

    -   `plot_graphs.R`: This file contains the code for plotting functions

-   `.gitignore`: This file specifies which files or directories should be ignored by version control.

-   `README.md`: This file usually contains documentation or information about the project. It's often the first thing someone reads when they visit the project repository.

-   `_quarto.yml`: This is a configuration file.

-   `about.qmd` : This quarto document contains the information about team members.

-   `index.qmd` : This quarto document contains the approach and analysis and results of the project.

-   `presentation.qmd` : It contains the slides for the presentation.

-   `proposal.qmd` : This quarto documents has the proposal of the project.

-   `project-final.Rproj` : This is an RStudio project file, which helps organize R-related files and settings for the project.

#### Disclosure:

Derived from the original data viz course by Mine Çetinkaya-Rundel \@ Duke University
