calc_backward_vel <- function(tile_name,
                             tolerance,
                             max_distance,
                             present_files, # must contain
                             future_files) {
  print(paste("Now calculating:", tile_name))

  ## Load data
  pre <- rast(grep(tile_name, present_files, value = T))
  ## names(pre) <- "pre"
  fut <- rast(grep(tile_name, future_files, value = T))
  ## names(fut) <- "fut"

  ## Round pre and fut to one decimal
  pre_round <- round(pre, 1)
  fut_round <- round(fut, 1)
  fut_values <- freq(fut_round, digits = 1)$value

  ## Set tolerace for matching analogues

  ## apply over all of the fut_values in lis
  analogue_distances <- lapply(fut_values, function(fut_value) {
    ## Filter only values in fut_round that are equal to fut_value
    fut_filt <- terra::mask(fut_round,
      fut_round == fut_value,
      maskvalues = F
    )

    ## Filter present analogues which are within tolerance of fut_value
    pre_filt <- terra::mask(pre_round,
      pre_round >= fut_value - tolerance & pre_round <= fut_value + tolerance,
      maskvalues = F
    )
    # Calculate distance to closest analogue
    pre_distance <- distance(pre_filt)
    names(pre_distance) <- "distance"
    analogue_result <- mask(crop(pre_distance, fut_filt), fut_filt)
    
  })

    ds <- rast(analogue_distances)
    distance <- app(ds, fun = sum, na.rm = T) # Sum all layers of ds rast to make complete map
    names(distance) <- "distance"
  # Save results as rasters.
    backward_vel_file <- paste0("/lustre1/scratch/348/vsc34871/output/BVoMC/PTES/bvomc_75kmSR_", tile_name, ".tif")
    backward_vel <- mask(distance, distance <= max_distance, maskvalues = F) / 75 # Calculate velocity 
    backward_vel <- round(backward_vel,1)
    print(backward_vel)
    writeRaster(backward_vel, backward_vel_file, overwrite = T) # write

    return(backward_vel_file) # Return filename

}
