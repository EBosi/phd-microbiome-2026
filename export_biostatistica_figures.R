library(phyloseq)
library(vegan)
library(ggplot2)
library(dplyr)
library(maps)
library(ggrepel)
library(ggside)
library(metagenomeSeq)
library(plyr)
library(reshape2)
library(grid)

repo_root <- normalizePath(getwd())
input_dir <- file.path(repo_root, "materials", "Sea4Blue")
fig_dir <- file.path(repo_root, "figures", "biostatistica")
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

zone_colors <- c(ANW = "#4280fc", ANC = "#ffb452", ANE = "#f7170a")

ps <- readRDS(file.path(input_dir, "phyloseq.rds"))

# 1. Sequencing depth
depth_df <- data.frame(
  Sample = sample_names(ps),
  Reads = sample_sums(ps),
  Zone = sample_data(ps)$Zone,
  SampleName = sample_data(ps)$SampleName
)

ggsave(
  file.path(fig_dir, "01-depth.png"),
  ggplot(depth_df, aes(x = reorder(SampleName, Reads), y = Reads, fill = Zone)) +
    geom_col(width = 0.8) +
    coord_flip() +
    scale_fill_manual(values = zone_colors, na.translate = FALSE) +
    labs(x = NULL, y = "Reads", title = "Library size") +
    theme_bw(),
  width = 8,
  height = 5,
  dpi = 150
)

# 2. Transect map
samdf <- data.frame(sample_data(subset_samples(ps, !is.na(Zone))))
samdf <- samdf[order(samdf$NavigationDay), ]
world <- map_data("world")

ggsave(
  file.path(fig_dir, "02-transect.png"),
  ggplot() +
    geom_polygon(
      data = world,
      aes(x = long, y = lat, group = group),
      fill = "grey90",
      color = "grey60"
    ) +
    geom_path(
      data = samdf,
      aes(x = Longitude, y = Latitude, group = 1),
      color = "black",
      linewidth = 1
    ) +
    geom_point(
      data = samdf,
      aes(x = Longitude, y = Latitude, color = Zone),
      size = 3
    ) +
    coord_quickmap(xlim = c(-85, -5), ylim = c(20, 45)) +
    scale_color_manual(values = zone_colors) +
    labs(x = "Longitude", y = "Latitude", color = "Zone", title = "SEA4BLUE transect") +
    theme_minimal(),
  width = 8,
  height = 5,
  dpi = 150
)

# 3. Rarefaction curves
set.seed(42)
ps_rarefaction <- subset_samples(ps, !is.na(Zone))

calculate_rarefaction_curves <- function(psdata, measures, depths) {
  estimate_rarified_richness <- function(psdata, measures, depth) {
    if (max(sample_sums(psdata)) < depth) return(NULL)
    psdata <- prune_samples(sample_sums(psdata) >= depth, psdata)
    rarified_psdata <- rarefy_even_depth(psdata, depth, verbose = FALSE)
    alpha_diversity <- estimate_richness(rarified_psdata, measures = measures)
    melt(
      as.matrix(alpha_diversity),
      varnames = c("Sample", "Measure"),
      value.name = "Alpha_diversity"
    )
  }

  names(depths) <- depths
  rarefaction_curve_data <- ldply(
    depths,
    estimate_rarified_richness,
    psdata = psdata,
    measures = measures,
    .id = "Depth"
  )
  rarefaction_curve_data$Depth <- as.numeric(levels(rarefaction_curve_data$Depth))[rarefaction_curve_data$Depth]
  rarefaction_curve_data
}

rarefaction_curve_data <- calculate_rarefaction_curves(
  ps_rarefaction,
  c("Observed"),
  rep(c(1, 10, 100, 1000, 1:100 * 10000), each = 10)
)
rarefaction_curve_data_summary <- ddply(
  rarefaction_curve_data,
  c("Depth", "Sample", "Measure"),
  summarise,
  Alpha_diversity_mean = mean(Alpha_diversity),
  Alpha_diversity_sd = sd(Alpha_diversity)
)
rarefaction_curve_data_summary_verbose <- merge(
  rarefaction_curve_data_summary,
  data.frame(sample_data(ps_rarefaction)),
  by.x = "Sample",
  by.y = "row.names"
)

ggsave(
  file.path(fig_dir, "03-rarefaction.png"),
  ggplot(
    data = rarefaction_curve_data_summary_verbose,
    aes(x = Depth, y = Alpha_diversity_mean, group = Sample, color = Zone)
  ) +
    geom_line(linewidth = 1) +
    geom_point(size = 2.5) +
    geom_label_repel(
      data = rarefaction_curve_data_summary_verbose |>
        dplyr::group_by(Sample) |>
        dplyr::filter(Alpha_diversity_mean == max(Alpha_diversity_mean)),
      aes(label = SampleName),
      color = "black",
      show.legend = FALSE
    ) +
    scale_color_manual(values = zone_colors) +
    labs(x = "Depth", y = "Observed ASVs", title = "Rarefaction Curves") +
    theme_bw(),
  width = 10,
  height = 6,
  dpi = 150
)

# 4. Alpha diversity after CSS normalization
phyloseq_obj <- ps
phyloseq_obj <- phyloseq_obj |>
  subset_taxa((is.na(Family) | Family != "Mitochondria") & (is.na(Order) | Order != "Chloroplast"))
phyloseq_obj <- prune_taxa(taxa_sums(phyloseq_obj) > 1, phyloseq_obj)
phyloseq_obj <- subset_samples(phyloseq_obj, !is.na(Zone) & SampleName != "Positive" & SampleName != "Negative")

data.metagenomeSeq <- phyloseq_to_metagenomeSeq(phyloseq_obj)
p <- cumNormStat(data.metagenomeSeq)
data.cumnorm <- cumNorm(data.metagenomeSeq, p = p)
data.CSS <- MRcounts(data.cumnorm, norm = TRUE, log = TRUE)

phyloseq_obj_css <- phyloseq_obj
otu_table(phyloseq_obj_css) <- otu_table(data.CSS, taxa_are_rows = TRUE)
sample_names(phyloseq_obj_css) <- sample_data(phyloseq_obj_css)$SampleName

phyloseq_obj_css_round <- phyloseq_obj_css
otu_table(phyloseq_obj_css_round) <- round(otu_table(phyloseq_obj_css), digits = 0)

p1 <- plot_richness(
  phyloseq_obj_css_round,
  x = "Longitude",
  color = "Zone",
  measures = c("Observed")
)
newSTorder <- c("ANW", "ANC", "ANE")
p1$data$Zone <- factor(as.character(p1$data$Zone), levels = newSTorder)

png(file.path(fig_dir, "05-alpha-richness.png"), width = 1600, height = 1000, res = 150)
print(
  ggplot(p1$data, aes(Longitude, value)) +
    theme_bw() +
    theme(plot.title = element_text(hjust = 0.5), ggside.panel.scale.y = 0.4) +
    geom_point(aes(colour = Zone), alpha = 0.45) +
    scale_color_manual(values = c("#4280fc", "#ffb452", "#f7170a", "#000000")) +
    geom_ysideboxplot(aes(x = Zone, y = value, colour = Zone), orientation = "x") +
    scale_ysidex_discrete() +
    geom_smooth(aes(colour = variable), linewidth = 1.5) +
    ylab("Richness")
)
dev.off()

sample_data(phyloseq_obj_css)$Richness <- p1$data$value

# 5. Beta diversity / PCoA
otu.ord <- ordinate(phyloseq_obj_css, "PCoA", distance = "bray")

ggsave(
  file.path(fig_dir, "06-pcoa-bray.png"),
  plot_ordination(phyloseq_obj_css, otu.ord, color = "Zone", axes = c(1, 2)) +
    scale_color_manual(values = c("#4280fc", "#ffb452", "#f7170a")) +
    geom_point(size = 3) +
    geom_text_repel(aes(label = SampleName), max.overlaps = Inf, show.legend = FALSE) +
    labs(title = "Beta Diversity based on Bray-Curtis") +
    theme_bw(),
  width = 10,
  height = 6,
  dpi = 150
)

# 6. Community composition
physeq_perc <- transform_sample_counts(phyloseq_obj_css, function(x) 100 * x / sum(x))
glom <- tax_glom(physeq_perc, taxrank = "Genus")
data_glom <- psmelt(glom)
data_glom$Zone <- factor(as.character(data_glom$Zone), levels = c("ANW", "ANC", "ANE"))

color <- grDevices::colors()[grep("gr(a|e)y", grDevices::colors(), invert = TRUE)]

ggsave(
  file.path(fig_dir, "08-composition-all.png"),
  ggplot(data = data_glom, aes(x = Sample, y = Abundance, fill = Genus)) +
    facet_grid(~Zone, scales = "free") +
    geom_bar(stat = "identity", position = "fill", width = 0.7) +
    scale_fill_manual(values = sample(color, length(unique(data_glom$Genus)))) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1), legend.position = "none") +
    labs(x = NULL, y = "Relative abundance", title = "All genera"),
  width = 12,
  height = 6,
  dpi = 150
)

genus.sum <- tapply(taxa_sums(glom), tax_table(glom)[, "Genus"], sum, na.rm = TRUE)
topGenera <- names(sort(genus.sum, TRUE))[1:20]

ggsave(
  file.path(fig_dir, "08-composition-top.png"),
  ggplot(data = data_glom, aes(x = Sample, y = Abundance, fill = Genus)) +
    facet_grid(~Zone, scales = "free") +
    geom_bar(stat = "identity", position = "fill", width = 0.7) +
    scale_fill_manual(values = sample(color, length(unique(data_glom$Genus))), breaks = topGenera) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
    labs(x = NULL, y = "Relative abundance", title = "Top genera"),
  width = 12,
  height = 6,
  dpi = 150
)

# 7. RDA
RDA <- ordinate(phyloseq_obj_css ~ Richness + Longitude, "RDA")
p2 <- plot_ordination(phyloseq_obj_css, RDA, color = "Zone") +
  theme_bw() +
  geom_text_repel(aes(label = SampleName, color = Zone), max.overlaps = Inf, show.legend = FALSE) +
  geom_point(size = 4) +
  scale_color_manual(values = c("#4280fc", "#ffb452", "#f7170a"))

arrowmat <- vegan::scores(RDA, display = "bp")
arrowdf <- data.frame(labels = rownames(arrowmat), arrowmat)
arrowhead <- arrow(length = unit(0.05, "npc"))

ggsave(
  file.path(fig_dir, "09-rda.png"),
  p2 +
    geom_segment(
      inherit.aes = FALSE,
      aes(xend = RDA1, yend = RDA2, x = 0, y = 0),
      data = arrowdf,
      color = "black",
      arrow = arrowhead,
      linewidth = 1
    ) +
    geom_text(
      inherit.aes = FALSE,
      aes(x = 1.7 * RDA1, y = 1.7 * RDA2, label = labels),
      data = arrowdf,
      size = 4
    ),
  width = 10,
  height = 6,
  dpi = 150
)
