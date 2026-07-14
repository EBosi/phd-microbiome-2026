#!/usr/bin/env Rscript

options(repos = c(CRAN = "https://cloud.r-project.org"))
cran_dependencies <- c("Depends", "Imports", "LinkingTo")

message("Post-create setup for metabarcoding-phd")
message("R: ", R.version.string)
message("Library paths:")
message(paste("  -", .libPaths(), collapse = "\n"))

install_cran_if_missing <- function(pkg) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    message(pkg, " already installed")
    return(TRUE)
  }

  message("Installing ", pkg, " from CRAN")
  tryCatch(
    {
      install.packages(pkg, dependencies = cran_dependencies)
      requireNamespace(pkg, quietly = TRUE)
    },
    error = function(e) {
      message("Failed to install ", pkg, " from CRAN: ", conditionMessage(e))
      FALSE
    }
  )
}

install_github_if_missing <- function(pkg, repo) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    message(pkg, " already installed")
    return(TRUE)
  }

  if (!requireNamespace("remotes", quietly = TRUE)) {
    message("Installing remotes from CRAN")
    install.packages("remotes", dependencies = cran_dependencies)
  }

  message("Installing ", pkg, " from GitHub repo ", repo)
  tryCatch(
    {
      remotes::install_github(
        repo,
        upgrade = "never",
        dependencies = cran_dependencies,
        build_vignettes = FALSE
      )
      requireNamespace(pkg, quietly = TRUE)
    },
    error = function(e) {
      message("Failed to install ", pkg, " from GitHub: ", conditionMessage(e))
      FALSE
    }
  )
}

results <- c(
  MiscMetabar = install_cran_if_missing("MiscMetabar"),
  ranacapa = install_github_if_missing("ranacapa", "gauravsk/ranacapa")
)

failed <- names(results)[!results]

if (length(failed) > 0) {
  message("Post-create setup failed. Missing packages: ", paste(failed, collapse = ", "))
  quit(status = 1)
}

message("Post-create setup completed successfully")
