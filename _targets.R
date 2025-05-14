library(targets)
library(tarchetypes)
library(clustermq)

## ### Running locally
## # Sets up how multiple targets are run parallel using the clustermq package
## options(clustermq.scheduler = "multiprocess")

### Running on HPC
## Settings for clustermq
options(
  clustermq.scheduler = "slurm",
  clustermq.template = "./cmq.tmpl" # if using your own template
)

## Settings for clustermq template when running clustermq on HPC
tar_option_set(
  resources = tar_resources(
    clustermq = tar_resources_clustermq(template = list(
      job_name = "auto-velocity",
      per_cpu_mem = "20600mb",
      n_tasks = 1,
      per_task_cpus = 36,
      walltime = "20:00:00"
    ))
  )
)

# Loads all R scripts in ./R/ directory.
# Here, all packages are loaded from the ./R/packages.R file
# The calc_forward_vel function is loaded from the ./R/calc_forward_vel.R file
tar_source()

tar_plan(
  tolerance = 0.25,
  max_distance = 75000, #!!!Always check this value!!!
  present_files = list.files(
    "/lustre1/scratch/348/vsc34871/input/BVoMC/preNortheastEU/",
   full.names = T),
  future_files = list.files(
    "/lustre1/scratch/348/vsc34871/input/BVoMC/futNortheastEU/",
   full.names = T),
  tar_target(tile_names,
    paste0(paste0(str_split(
      gsub("ForestMAT_", "", tail(str_split(future_files, "/")[[1]], 1)),
      "_"
    )[[1]][1:2], collapse = "_"), "_"),
    pattern = map(future_files),
  ),
  tar_target(backward_vels,
    calc_backward_vel(
      tile_names,
      tolerance,
      max_distance,
      present_files,
      future_files
    ),
    pattern = map(tile_names),
    format = "file"
  )
)
