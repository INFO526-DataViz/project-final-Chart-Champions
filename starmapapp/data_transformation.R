
if(!require(pacman))
    install.packages("pacman")

pacman::p_load(knitr, formattable, tidyverse, # General packages
               lubridate, lutz, # range data and dates  
               sf, s2, nominatimlite, # Spatial manipulation
               ggfx, ggshadow # Visualization
            )

source("helper_functions.R")


get_buffered_lat_lon_time <- function(place_, year_, month_, day_, hour_, min_) {
    # Input place
    desired_place <- place_    # "Seoul, Korea"
    
    
    # Geocode place with nominatimlite
    desired_place_geo <- geo_lite(desired_place, full_results = TRUE)
    
    desired_place_geo_df <- desired_place_geo |>
        select(address, lat, lon)
    #> # A tibble: 1 × 3
    #>   address                                                                                    lat   lon
    #>   <chr>                                                                                    <dbl> <dbl>
    #> 1 Madrid, Área metropolitana de Madrid y Corredor del Henares, Comunidad de Madrid, España  40.4 -3.70
    
    # And get the coordinates
    desired_loc <- desired_place_geo %>%
        select(lat, lon) %>%
        unlist()
    
    # >>>>>>>> time conversion <<<<<<<<<<<
    
    # Input time
    desired_date <- make_datetime(
        year = year_,  # 2023
        month = month_,  # 12
        day = day_,     # 1 
        hour = hour_,   # 12
        min = min_      # 13
    )
    
    # Get tz
    get_tz <- tz_lookup_coords(desired_loc[1], desired_loc[2], warn = FALSE)
    
    get_tz
    #> [1] "Europe/Madrid"
    
    # Force it to be local time
    desired_date_tz <- force_tz(desired_date, get_tz)
    
    desired_date_tz
    #> [1] "2015-09-22 03:45:00 CEST"
    
    return (list(desired_loc=desired_loc, desired_date_tz=desired_date_tz))
    
}

get_airy_projection_rotation <- function(desired_date_tz, desired_loc) {
    
    
    # Get the rotation and prepare buffer and projection
    
    # Get right degrees
    lon_prj <- get_mst(desired_date_tz, desired_loc[2])
    lat_prj <- desired_loc[1]
    
    # c(lon_prj, lat_prj)
    #>      lon      lat 
    #> 23.15892 40.41670
    
    # Create proj4string w/ Airy projection
    
    target_crs <- paste0("+proj=airy +x_0=0 +y_0=0 +lon_0=", lon_prj, " +lat_0=", lat_prj)
    
    
    # target_crs
    #> [1] "+proj=airy +x_0=0 +y_0=0 +lon_0=23.1589164999314 +lat_0=40.4167047"
    
    # We need to flip celestial objects to get the impression of see from the Earth
    # to the sky, instead of from the sky to the Earth
    # https://stackoverflow.com/a/75064359/7877917
    # Flip matrix for affine transformation
    
    flip_matrix <- matrix(c(-1, 0, 0, 1), 2, 2)
    
    
    # And create an s2 buffer of the visible hemisphere at the given location
    hemisphere_s2 <- s2_buffer_cells(
        as_s2_geography(
            paste0("POINT(", lon_prj, " ", lat_prj, ")")
        ),
        9800000,
        max_cells = 5000
    )
    
    # This one is for plotting
    hemisphere_sf <- hemisphere_s2 %>%
        st_as_sf() %>%
        st_transform(crs = target_crs) %>%
        st_make_valid()
    
    return (list(target_crs = target_crs, hemisphere_s2 = hemisphere_s2, flip_matrix = flip_matrix))
    
}

get_plot_caption <- function(desired_loc, desired_place, desired_date_tz, special_message="") {
    
    lat_lab <- pretty_lonlat(desired_loc[1], type = "lat")
    lon_lab <- pretty_lonlat(desired_loc[2], type = "lon")
    
    pretty_labs <- paste(lat_lab, "/", lon_lab)
    
    # cat(pretty_labs)
    #> 40° 25' 0.14" N / 3° 42' 12.9" W
    
    # Create final caption to put on bottom
    
    pretty_time <- paste(
        # Pretty Day
        scales::label_date(
            format = "%d %b %Y",
            locale = "en"
        )(desired_date_tz),
        # Pretty Hour
        format(desired_date_tz, format = "%H:%M", usetz = TRUE)
    )
    
    # cat(pretty_time)
    #> 22 Sep 2015 03:45 CEST
    
    # Our final caption
    caption <- toupper(paste0(
        "Star Map\n",
        desired_place, "\n",
        pretty_time, "\n",
        pretty_labs
    ))
    
    
    # cat(caption)
    #> STAR MAP
    #> MADRID, SPAIN
    #> 22 SEP 2015 03:45 CEST
    #> 40° 25' 0.14" N / 3° 42' 12.9" W
    
    if (special_message != ""){
        caption <- toupper(paste0(caption, "\n", special_message))
    }
    
    return (caption)
}

