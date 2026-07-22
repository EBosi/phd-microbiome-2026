# Helper functions for the SEA4BLUE biostatistics lesson.
# Source this file after extracting Sea4Blue.zip into your working directory.

zone_colors <- c(ANW = "#4280fc", ANC = "#ffb452", ANE = "#f7170a")

prepare_biostatistics_ps <- function(ps) {
  ps_clean <- subset_taxa(
    ps,
    (is.na(Family) | Family != "Mitochondria") &
      (is.na(Order) | Order != "Chloroplast")
  )
  ps_clean <- prune_taxa(taxa_sums(ps_clean) > 1, ps_clean)
  ps_clean <- subset_samples(
    ps_clean,
    !is.na(Zone) & SampleName != "Positive" & SampleName != "Negative"
  )

  data.metagenomeSeq <- phyloseq_to_metagenomeSeq(ps_clean)
  p <- cumNormStat(data.metagenomeSeq)
  data.cumnorm <- cumNorm(data.metagenomeSeq, p = p)
  data.CSS <- MRcounts(data.cumnorm, norm = TRUE, log = TRUE)

  ps_css <- ps_clean
  otu_table(ps_css) <- otu_table(data.CSS, taxa_are_rows = TRUE)
  sample_names(ps_css) <- sample_data(ps_css)$SampleName

  ps_css_round <- ps_css
  otu_table(ps_css_round) <- round(otu_table(ps_css), digits = 0)

  list(
    ps_clean = ps_clean,
    ps_css = ps_css,
    ps_css_round = ps_css_round
  )
}

calculate_rarefaction_curves <- function(psdata, measures, depths) {
  estimate_rarified_richness <- function(psdata, measures, depth) {
    if (max(sample_sums(psdata)) < depth) return(NULL)
    psdata <- prune_samples(sample_sums(psdata) >= depth, psdata)
    rarified_psdata <- rarefy_even_depth(psdata, depth, verbose = FALSE)
    alpha_diversity <- estimate_richness(rarified_psdata, measures = measures)
    reshape2::melt(
      as.matrix(alpha_diversity),
      varnames = c("Sample", "Measure"),
      value.name = "Alpha_diversity"
    )
  }

  names(depths) <- depths
  rarefaction_curve_data <- plyr::ldply(
    depths,
    estimate_rarified_richness,
    psdata = psdata,
    measures = measures,
    .id = "Depth"
  )
  rarefaction_curve_data$Depth <- as.numeric(
    levels(rarefaction_curve_data$Depth)
  )[rarefaction_curve_data$Depth]
  rarefaction_curve_data
}

prepare_composition_data <- function(ps_css, top_n = 20) {
  physeq_perc <- transform_sample_counts(ps_css, function(x) 100 * x / sum(x))
  glom <- tax_glom(physeq_perc, taxrank = "Genus", NArm = FALSE)
  data_glom <- psmelt(glom)
  data_glom$Zone <- factor(as.character(data_glom$Zone), levels = c("ANW", "ANC", "ANE"))

  topGenera <- data_glom |>
    dplyr::filter(!is.na(Genus)) |>
    dplyr::group_by(Genus) |>
    dplyr::summarise(total = sum(Abundance), .groups = "drop") |>
    dplyr::slice_max(total, n = top_n) |>
    dplyr::pull(Genus)

  color <- grDevices::colors()[grep("gr(a|e)y", grDevices::colors(), invert = TRUE)]

  list(
    physeq_perc = physeq_perc,
    glom = glom,
    data_glom = data_glom,
    topGenera = topGenera,
    color = color
  )
}

prepare_rda_data <- function(ps_css_round, alpha) {
  ps_rda <- ps_css_round
  sample_data(ps_rda)$Richness <- alpha$Observed[
    match(sample_names(ps_rda), alpha$Sample)
  ]

  RDA <- ordinate(ps_rda, "RDA", formula = ~ Richness + Longitude)

  arrowmat <- vegan::scores(RDA, display = "bp")
  arrowdf <- data.frame(labels = rownames(arrowmat), arrowmat)

  list(
    ps_rda = ps_rda,
    RDA = RDA,
    arrowdf = arrowdf
  )
}
