
if(!require(pacman))
    install.packages("pacman")

pacman::p_load(knitr, formattable, tidyverse, # General packages
               lubridate, lutz, # range data and dates  
               sf, s2, nominatimlite, # Spatial manipulation
               ggfx, ggshadow # Visualization
            )

source("data_transformation.R")

get_graticules_viz <- function(target_crs, hemisphere_s2) {
    grat <- st_graticule(
        ndiscr = 5000,
        lat = seq(-90, 90, 10),
        lon = seq(-180, 180, 30)
    )
    
    grat_flat <- ggplot(grat) +
        geom_sf() +
        coord_sf(expand = FALSE)
    
    
    # Cut to buffer, we dont flip this one (it is not an object of the space)
    grat_end <- sf_spherical_cut(
        x = grat,
        the_buff = hemisphere_s2,
        # Change the crs
        the_crs = target_crs
    )
    
    
    grat_sf <- ggplot(grat_end) +
        geom_sf() +
        coord_sf(expand = FALSE)
    
    return (list(grat_flat=grat_flat, grat_sf=grat_sf, grat_end = grat_end))
}


get_starts_viz <- function(target_crs, hemisphere_s2, flip_matrix) {
    
    stars <- load_celestial("stars.6.min.geojson")
    
    stars_flat <- ggplot(stars) +
        # We use relative brightness (br) as aes
        geom_sf(aes(size = br, alpha = br), shape = 16) +
        scale_size_continuous(range = c(0.5, 6)) +
        scale_alpha_continuous(range = c(0.1, 0.8)) +
        coord_sf(expand = FALSE)
    
    
    # Cut to buffer
    
    stars_end <- sf_spherical_cut(stars,
                                  the_buff = hemisphere_s2,
                                  # Change the crs
                                  the_crs = target_crs,
                                  flip = flip_matrix
    )
    
    stars_sf <- ggplot(stars_end) +
        # We use relative brightness (br) as aes
        geom_sf(aes(size = br, alpha = br), shape = 16) +
        scale_size_continuous(range = c(0.5, 6)) +
        scale_alpha_continuous(range = c(0.1, 0.8))
    
    return (list(stars_flat = stars_flat, stars_sf = stars_sf, stars_end = stars_end))
    
}


get_milkyway_viz <- function(target_crs, hemisphere_s2, flip_matrix) {
    
    mw <- load_celestial("mw.min.geojson")
    
    # Add colors to MW to use on fill
    cols <- colorRampPalette(c("white", "yellow"))(5)
    mw$fill <- factor(cols, levels = cols)
    
    mw_flat <- ggplot(mw) +
        geom_sf(aes(fill = fill)) +
        scale_fill_identity()
    
    
    # Cut to buffer
    mw_end <- sf_spherical_cut(mw,
                               the_buff = hemisphere_s2,
                               # Change the crs
                               the_crs = target_crs,
                               flip = flip_matrix
    )
    
    
    mw_sf <- ggplot(mw_end) +
        geom_sf(aes(fill = fill)) +
        scale_fill_identity()
    
    return (list(mw_flat = mw_flat, mw_sf = mw_sf, mw_end = mw_end))
    
}

get_constellation_viz <- function(target_crs, hemisphere_s2, flip_matrix) {
    const <- load_celestial("constellations.lines.min.geojson")
    
    const_flat <- ggplot(const) +
        geom_sf() +
        coord_sf(expand = FALSE)
    
    
    # Cut to buffer
    
    const_end <- sf_spherical_cut(const,
                                  the_buff = hemisphere_s2,
                                  # Change the crs
                                  the_crs = target_crs,
                                  flip = flip_matrix
    )
    
    
    const_sf <- ggplot(const_end) +
        geom_sf() +
        coord_sf(expand = FALSE)
    
    return (list(const_flat = const_flat, const_sf = const_sf, const_end = const_end))
}

plot_celestial_map <- function(grat_end, const_end, mw_end, stars_end, target_crs, hemisphere_s2, caption, glowint, bg_fill_col) {
    
    # Prepare MULTILINESTRING
    const_end_lines <- const_end %>%
        st_cast("MULTILINESTRING") %>%
        st_coordinates() %>%
        as.data.frame()
    
    # This one is for plotting
    hemisphere_sf <- hemisphere_s2 %>%
        st_as_sf() %>%
        st_transform(crs = target_crs) %>%
        st_make_valid()
    
    
    celestial_map_plot <- ggplot() +
        # Graticules
        geom_sf(data = grat_end, color = "grey60", linewidth = 0.25, alpha = 0.3) +
        # A blurry Milky Way
        with_blur(
            geom_sf(
                data = mw_end, aes(fill = fill), alpha = 0.1, color = NA,
                show.legend = FALSE
            ),
            sigma = 8
        ) +
        scale_fill_identity() +
        # Glowing stars
        geom_glowpoint(
            data = stars_end, aes(
                alpha = br, size =
                    br, geometry = geometry
            ),
            color = "white", show.legend = FALSE, stat = "sf_coordinates"
        ) +
        scale_size_continuous(range = c(0.05, 0.75)) +
        scale_alpha_continuous(range = c(0.1, 0.5)) +
        # Glowing constellations
        geom_glowpath(
            data = const_end_lines, aes(X, Y, group = interaction(L1, L2)),
            color = "white", size = 0.5, alpha = 0.8, shadowsize = 0.7, shadowalpha = glowint,
            shadowcolor = "white", linejoin = "round", lineend = "round"
        ) +
        # Border of the sphere
        geom_sf(data = hemisphere_sf, fill = NA, color = "white", linewidth = 1.25) +
        # Caption
        labs(caption = caption) +
        # And end with theming
        theme_void() +
        theme(
            text = element_text(colour = "white"),
            panel.border = element_blank(),
            plot.background = element_rect(fill = bg_fill_col, color = "#191d29"),
            plot.margin = margin(20, 20, 20, 20),
            plot.caption = element_text(
                hjust = 0.5, face = "bold",
                size = rel(1),
                lineheight = rel(1.2),
                margin = margin(t = 40, b = 20)
            )
        )
    
    return (celestial_map_plot)
}

get_custom_celestial_map <- function(desired_place, year_, month_, day_, hour_, min_, special_message="",
                                     bg_fill_col = "#191d29", glowint=0.04) {

    lat_lon_time <- get_buffered_lat_lon_time(place_=desired_place, 
                                              year_=year_, month_=month_, 
                                              day_=day_, hour_=hour_, min_=min_)

    crs_s2_flip <- get_airy_projection_rotation(lat_lon_time$desired_date_tz, lat_lon_time$desired_loc)

    plot_caption <- get_plot_caption(lat_lon_time$desired_loc, desired_place, lat_lon_time$desired_date_tz, special_message)


    graticules <- get_graticules_viz(crs_s2_flip$target_crs, crs_s2_flip$hemisphere_s2)
    milkyway <- get_milkyway_viz(crs_s2_flip$target_crs, crs_s2_flip$hemisphere_s2, crs_s2_flip$flip_matrix)
    constellation <- get_constellation_viz(crs_s2_flip$target_crs,
                                           crs_s2_flip$hemisphere_s2, crs_s2_flip$flip_matrix)
    stars <- get_starts_viz(crs_s2_flip$target_crs, crs_s2_flip$hemisphere_s2, crs_s2_flip$flip_matrix)

    
    plot_celestial_map(grat_end = graticules$grat_end, 
                       const_end = constellation$const_end, 
                       mw_end = milkyway$mw_end, 
                       stars_end = stars$stars_end,
                       target_crs = crs_s2_flip$target_crs,
                       hemisphere_s2 = crs_s2_flip$hemisphere_s2, 
                       caption = plot_caption,
                       bg_fill_col = bg_fill_col,
                       glowint = glowint)
    
}

get_default_celestial_map <- function() {
    
    date__ <- lubridate::today()
    time__ <- lubridate::now()
    desired_place__ <- "Seoul, Korea"
    
    get_custom_celestial_map(desired_place = desired_place__, year_ = year(date__), month_=month(date__), 
                             day_=day(date__), hour_=hour(time__), min_ = minute(time__))
}
