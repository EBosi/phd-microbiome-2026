#!/usr/bin/env Rscript

required_packages <- c(
  "phyloseq",
  "dada2",
  "biomformat",
  "Biostrings",
  "DECIPHER",
  "metagenomeSeq",
  "vegan",
  "ape",
  "ggplot2",
  "dplyr",
  "tidyr",
  "readr",
  "tibble",
  "stringr",
  "forcats",
  "maps",
  "formattable",
  "ggrepel",
  "ggside",
  "ggpubr",
  "gridBase",
  "plyr",
  "reshape2",
  "patchwork",
  "cowplot",
  "pheatmap",
  "viridis",
  "RColorBrewer",
  "knitr",
  "rmarkdown",
  "MiscMetabar",
  "ranacapa"
)

required_cli <- c(
  "R",
  "Rscript",
  "snakemake",
  "fastqc",
  "multiqc",
  "cutadapt",
  "seqkit",
  "quarto"
)

optional_cli <- c("rstudio", "ampwrap")

status <- 0

message("Checking metabarcoding-phd environment")
message("R: ", R.version.string)
message("Executable R: ", Sys.which("R"))
message("Executable Rscript: ", Sys.which("Rscript"))
message("Library paths:")
message(paste("  -", .libPaths(), collapse = "\n"))

missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  message("Missing required R packages: ", paste(missing_packages, collapse = ", "))
  status <- 1
} else {
  message("All required R packages are available")
}

available_packages <- setdiff(required_packages, missing_packages)
if (length(available_packages) > 0) {
  versions <- vapply(
    available_packages,
    function(pkg) as.character(utils::packageVersion(pkg)),
    character(1)
  )
  message("R package versions:")
  for (pkg in names(versions)) {
    message("  - ", pkg, ": ", versions[[pkg]])
  }
}

missing_cli <- required_cli[Sys.which(required_cli) == ""]
if (length(missing_cli) > 0) {
  message("Missing required command-line tools: ", paste(missing_cli, collapse = ", "))
  status <- 1
} else {
  message("All required command-line tools are available")
}

message("Optional command-line tools:")
for (tool in optional_cli) {
  found <- Sys.which(tool)
  if (found == "") {
    message("  - ", tool, ": not found")
  } else {
    message("  - ", tool, ": ", found)
  }
}

phyloseq_path <- file.path("R_RStudio", "phyloseq.rds")
if (file.exists(phyloseq_path)) {
  message("Checking course data: ", phyloseq_path)
  obj <- tryCatch(readRDS(phyloseq_path), error = identity)
  if (inherits(obj, "error")) {
    message("Failed to read ", phyloseq_path, ": ", conditionMessage(obj))
    status <- 1
  } else if (!inherits(obj, "phyloseq")) {
    message("File exists but is not a phyloseq object: ", paste(class(obj), collapse = ", "))
    status <- 1
  } else {
    message("phyloseq.rds OK")
    message("  samples: ", phyloseq::nsamples(obj))
    message("  taxa: ", phyloseq::ntaxa(obj))
  }
} else {
  message("Course data not found at ", phyloseq_path, "; skipping data check")
}

if (status == 0) {
  message("Environment check completed successfully")
} else {
  message("Environment check failed")
}

quit(status = status)
