# SEA4BLUE — analisi guidata
# Eseguire una sezione alla volta con Ctrl+Enter.
# Durante la lezione NON usare source("analysis_guided.R").

# 0. Pacchetti ------------------------------------------------------------

library(phyloseq)
library(vegan)
library(ggplot2)
library(dplyr)
library(maps)
library(ggrepel)

zone_colors <- c(ANW = "#4280fc", ANC = "#ffb452", ANE = "#f7170a")


# 1. Importazione e struttura ---------------------------------------------

getwd()
list.files()

ps <- readRDS("phyloseq.rds")
ps

head(t(otu_table(ps))[, 1:6])
head(as.data.frame(tax_table(ps)))
as.data.frame(sample_data(ps))

# DOMANDE
# Quanti campioni e quante ASV sono presenti?
# Quali righe rappresentano il controllo positivo e quello negativo?


# 2. Profondità di sequenziamento -----------------------------------------

depth_df <- data.frame(
  Sample = sample_names(ps),
  Reads = sample_sums(ps),
  Type = ifelse(is.na(sample_data(ps)$Zone), "Control", "Environmental")
)

ggplot(depth_df, aes(x = reorder(Sample, Reads), y = Reads, fill = Type)) +
  geom_col() +
  coord_flip() +
  labs(x = NULL, y = "Reads", title = "Library size") +
  theme_bw()

# Il controllo negativo ha una profondità confrontabile con i campioni?


# 2b. Transetto di campionamento ------------------------------------------

samdf <- data.frame(sample_data(subset_samples(ps, !is.na(Zone))))
samdf <- samdf[order(samdf$NavigationDay), ]
world <- map_data("world")

ggplot() +
  geom_polygon(
    data = world,
    aes(x = long, y = lat, group = group),
    fill = "grey92", color = "grey65"
  ) +
  geom_path(data = samdf, aes(Longitude, Latitude), color = "grey25") +
  geom_point(data = samdf, aes(Longitude, Latitude, color = Zone), size = 3) +
  coord_quickmap(xlim = c(-85, -5), ylim = c(20, 45)) +
  scale_color_manual(values = zone_colors) +
  labs(x = "Longitudine", y = "Latitudine", title = "Transetto SEA4BLUE") +
  theme_minimal()

# Le zone sono gruppi indipendenti dalla geografia o parti dello stesso
# gradiente? Ricordiamolo quando interpreteremo PERMANOVA e RDA.


# 3. Curva di rarefazione -------------------------------------------------

ps_bio <- subset_samples(ps, !is.na(Zone))
otu_bio <- as(otu_table(ps_bio), "matrix")
if (taxa_are_rows(ps_bio)) otu_bio <- t(otu_bio)

set.seed(42)
rarecurve(
  otu_bio,
  step = 1000,
  sample = min(rowSums(otu_bio)),
  label = FALSE,
  xlab = "Reads campionate",
  ylab = "ASV osservate"
)

# Le curve raggiungono un plateau?
# Qual è il costo di rarefare tutti i campioni alla profondità minima?


# 4. Filtraggio -----------------------------------------------------------

# 4a. Rimuoviamo sequenze mitocondriali e cloroplastiche.
ps_clean <- subset_taxa(
  ps,
  (is.na(Family) | Family != "Mitochondria") &
    (is.na(Order) | Order != "Chloroplast")
)
c(before = ntaxa(ps), after_organelle = ntaxa(ps_clean))

# 4b. Rimuoviamo le ASV con un solo conteggio nell'intero dataset.
ps_clean <- prune_taxa(taxa_sums(ps_clean) > 1, ps_clean)
ntaxa(ps_clean)

# 4c. I controlli sono stati ispezionati; ora li separiamo dal confronto
# ecologico tra zone e togliamo eventuali taxa rimasti a zero.
ps_clean <- subset_samples(ps_clean, !is.na(Zone))
ps_clean <- prune_taxa(taxa_sums(ps_clean) > 0, ps_clean)
ps_clean

stopifnot(nsamples(ps_clean) == 15)
stopifnot(all(sample_sums(ps_clean) > 0))


# 5. Diversità alfa -------------------------------------------------------

alpha <- estimate_richness(ps_clean, measures = c("Observed", "Shannon"))
alpha$Sample <- rownames(alpha)

metadata <- data.frame(sample_data(ps_clean))
metadata$Sample <- rownames(metadata)
alpha <- left_join(alpha, metadata, by = "Sample")

head(alpha)

ggplot(alpha, aes(x = Longitude, y = Observed, color = Zone)) +
  geom_point(size = 3) +
  geom_smooth(method = "lm", se = TRUE, color = "grey30") +
  scale_color_manual(values = zone_colors) +
  labs(x = "Longitudine", y = "ASV osservate", title = "Richness lungo il transetto") +
  theme_bw()

sample_data(ps_clean)$Richness <- alpha[
  match(sample_names(ps_clean), alpha$Sample),
  "Observed"
]

# Stiamo osservando un'associazione o dimostrando causalità?


# 6. Abbondanze relative e PCoA Bray-Curtis -------------------------------

ps_rel <- transform_sample_counts(ps_clean, function(x) x / sum(x))
sample_sums(ps_rel)
stopifnot(all(abs(sample_sums(ps_rel) - 1) < 1e-8))

pcoa_bray <- ordinate(ps_rel, method = "PCoA", distance = "bray")

plot_ordination(ps_rel, pcoa_bray, color = "Zone") +
  geom_point(size = 3) +
  geom_text_repel(aes(label = SampleName), show.legend = FALSE) +
  scale_color_manual(values = zone_colors) +
  labs(title = "PCoA — Bray-Curtis") +
  theme_bw()

# La separazione sembra discreta tra zone o graduale lungo il transetto?


# 7. PERMANOVA e dispersione ---------------------------------------------

otu_rel <- as(otu_table(ps_rel), "matrix")
if (taxa_are_rows(ps_rel)) otu_rel <- t(otu_rel)

meta_rel <- data.frame(sample_data(ps_rel))
meta_rel <- meta_rel[rownames(otu_rel), , drop = FALSE]
stopifnot(identical(rownames(otu_rel), rownames(meta_rel)))

bray <- vegdist(otu_rel, method = "bray")

set.seed(42)
adonis2(bray ~ Zone, data = meta_rel, permutations = 999)

dispersion <- betadisper(bray, group = meta_rel$Zone)
anova(dispersion)

set.seed(42)
permutest(dispersion, permutations = 999)

# Una PERMANOVA significativa dimostra che la zona è la causa del pattern?


# 8. Composizione tassonomica --------------------------------------------

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

ggplot(genus_plot, aes(x = Sample, y = Abundance, fill = Genus_plot)) +
  geom_col(width = 0.85) +
  facet_grid(~ Zone, scales = "free_x", space = "free_x") +
  scale_y_continuous(labels = function(x) paste0(round(100 * x), "%")) +
  labs(x = NULL, y = "Abbondanza relativa", fill = "Genere") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

# Quali pattern della PCoA possono essere collegati a questo grafico?


# 9. RDA con longitudine --------------------------------------------------

otu_hellinger <- decostand(otu_rel, method = "hellinger")
rda_model <- rda(otu_hellinger ~ Longitude, data = meta_rel)
rda_model

set.seed(42)
anova(rda_model, permutations = 999)
RsquareAdj(rda_model)

site_scores <- as.data.frame(
  scores(rda_model, display = "sites", choices = 1:2)
)
site_scores$Sample <- rownames(site_scores)
site_scores <- left_join(
  site_scores,
  cbind(Sample = rownames(meta_rel), meta_rel),
  by = "Sample"
)

ggplot(site_scores, aes(x = RDA1, y = PC1, color = Zone, label = SampleName)) +
  geom_hline(yintercept = 0, color = "grey85") +
  geom_vline(xintercept = 0, color = "grey85") +
  geom_point(size = 3) +
  geom_text_repel(show.legend = FALSE) +
  scale_color_manual(values = zone_colors) +
  labs(title = "RDA vincolata dalla longitudine") +
  theme_bw()


# 10. Riproducibilità -----------------------------------------------------

sessionInfo()
