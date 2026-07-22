library(phyloseq)
library(vegan)
library(ggplot2)
library(dplyr)
library(maps)
library(ggrepel)

repo_root <- normalizePath(getwd())
input_dir <- file.path(repo_root, "materials", "Sea4Blue")
fig_dir <- file.path(repo_root, "figures", "biostatistica")
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

zone_colors <- c(ANW = "#4280fc", ANC = "#ffb452", ANE = "#f7170a")

ps <- readRDS(file.path(input_dir, "phyloseq.rds"))

depth_df <- data.frame(
  Sample = sample_names(ps),
  Reads = sample_sums(ps),
  Type = ifelse(is.na(sample_data(ps)$Zone), "Control", "Environmental")
)

ggsave(
  file.path(fig_dir, "01-depth.png"),
  ggplot(depth_df, aes(x = reorder(Sample, Reads), y = Reads, fill = Type)) +
    geom_col() +
    coord_flip() +
    labs(x = NULL, y = "Reads", title = "Library size") +
    theme_bw(),
  width = 8,
  height = 5,
  dpi = 150
)

samdf <- data.frame(sample_data(subset_samples(ps, !is.na(Zone))))
samdf <- samdf[order(samdf$NavigationDay), ]
world <- map_data("world")

ggsave(
  file.path(fig_dir, "02-transect.png"),
  ggplot() +
    geom_polygon(
      data = world,
      aes(x = long, y = lat, group = group),
      fill = "grey92", color = "grey65"
    ) +
    geom_path(data = samdf, aes(Longitude, Latitude), color = "grey25", linewidth = 0.8) +
    geom_point(data = samdf, aes(Longitude, Latitude, color = Zone), size = 3) +
    coord_quickmap(xlim = c(-85, -5), ylim = c(20, 45)) +
    scale_color_manual(values = zone_colors) +
    labs(x = "Longitudine", y = "Latitudine", title = "SEA4BLUE transect") +
    theme_minimal(),
  width = 8,
  height = 5,
  dpi = 150
)

ps_bio <- subset_samples(ps, !is.na(Zone))
otu_bio <- as(otu_table(ps_bio), "matrix")
if (taxa_are_rows(ps_bio)) otu_bio <- t(otu_bio)

png(file.path(fig_dir, "03-rarefaction.png"), width = 1600, height = 1100, res = 150)
set.seed(42)
rarecurve(
  otu_bio,
  step = 1000,
  sample = min(rowSums(otu_bio)),
  label = FALSE,
  xlab = "Reads campionate",
  ylab = "ASV osservate"
)
dev.off()

ps_clean <- subset_taxa(
  ps,
  (is.na(Family) | Family != "Mitochondria") &
    (is.na(Order) | Order != "Chloroplast")
)
ps_clean <- prune_taxa(taxa_sums(ps_clean) > 1, ps_clean)
ps_clean <- subset_samples(ps_clean, !is.na(Zone))
ps_clean <- prune_taxa(taxa_sums(ps_clean) > 0, ps_clean)

alpha <- estimate_richness(ps_clean, measures = c("Observed", "Shannon"))
alpha$Sample <- rownames(alpha)
metadata <- data.frame(sample_data(ps_clean))
metadata$Sample <- rownames(metadata)
alpha <- left_join(alpha, metadata, by = "Sample")

ggsave(
  file.path(fig_dir, "05-alpha-richness.png"),
  ggplot(alpha, aes(x = Longitude, y = Observed, color = Zone)) +
    geom_point(size = 3) +
    geom_smooth(method = "lm", se = TRUE, color = "grey30") +
    scale_color_manual(values = zone_colors) +
    labs(x = "Longitudine", y = "ASV osservate", title = "Richness lungo il transetto") +
    theme_bw(),
  width = 8,
  height = 5,
  dpi = 150
)

ps_rel <- transform_sample_counts(ps_clean, function(x) x / sum(x))
pcoa_bray <- ordinate(ps_rel, method = "PCoA", distance = "bray")

ggsave(
  file.path(fig_dir, "06-pcoa-bray.png"),
  plot_ordination(ps_rel, pcoa_bray, color = "Zone") +
    geom_point(size = 3) +
    geom_text_repel(aes(label = SampleName), show.legend = FALSE) +
    scale_color_manual(values = zone_colors) +
    labs(title = "PCoA - Bray-Curtis") +
    theme_bw(),
  width = 8,
  height = 5,
  dpi = 150
)

ps_genus <- tax_glom(ps_rel, taxrank = "Genus", NArm = FALSE)
genus_df <- psmelt(ps_genus)

top_genera <- genus_df |>
  filter(!is.na(Genus)) |>
  group_by(Genus) |>
  summarise(total = sum(Abundance), .groups = "drop") |>
  slice_max(total, n = 12) |>
  pull(Genus)

genus_plot <- genus_df |>
  mutate(
    Genus_plot = ifelse(
      is.na(Genus) | !Genus %in% top_genera,
      "Other",
      as.character(Genus)
    )
  ) |>
  group_by(Sample, Zone, Genus_plot) |>
  summarise(Abundance = sum(Abundance), .groups = "drop")

ggsave(
  file.path(fig_dir, "08-composition.png"),
  ggplot(genus_plot, aes(x = Sample, y = Abundance, fill = Genus_plot)) +
    geom_col(width = 0.85) +
    facet_grid(~ Zone, scales = "free_x", space = "free_x") +
    scale_y_continuous(labels = function(x) paste0(round(100 * x), "%")) +
    labs(x = NULL, y = "Abbondanza relativa", fill = "Genere") +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)),
  width = 12,
  height = 6,
  dpi = 150
)

otu_rel <- as(otu_table(ps_rel), "matrix")
if (taxa_are_rows(ps_rel)) otu_rel <- t(otu_rel)
meta_rel <- data.frame(sample_data(ps_rel))
meta_rel <- meta_rel[rownames(otu_rel), , drop = FALSE]
otu_hellinger <- decostand(otu_rel, method = "hellinger")
rda_model <- rda(otu_hellinger ~ Longitude, data = meta_rel)

site_scores <- as.data.frame(scores(rda_model, display = "sites", choices = 1:2))
site_scores$Sample <- rownames(site_scores)
site_scores <- left_join(
  site_scores,
  cbind(Sample = rownames(meta_rel), meta_rel),
  by = "Sample"
)

ggsave(
  file.path(fig_dir, "09-rda.png"),
  ggplot(site_scores, aes(x = RDA1, y = PC1, color = Zone, label = SampleName)) +
    geom_hline(yintercept = 0, color = "grey85") +
    geom_vline(xintercept = 0, color = "grey85") +
    geom_point(size = 3) +
    geom_text_repel(show.legend = FALSE) +
    scale_color_manual(values = zone_colors) +
    labs(title = "RDA vincolata dalla longitudine") +
    theme_bw(),
  width = 8,
  height = 5,
  dpi = 150
)
