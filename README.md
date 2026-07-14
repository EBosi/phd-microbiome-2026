# Metabarcoding PhD Course 2026

Repository per il corso PhD di metabarcoding: basi teoriche, uso di Bash, lancio di AmpWrap e analisi biostatistica in R/RStudio degli output.

La repository contiene solo istruzioni, script e la ricetta dell'ambiente conda. L'ambiente installato occupa diversi GB e non deve essere caricato su GitHub.

## Struttura

- `env/metabarcoding-phd.yml`: ambiente conda principale.
- `env/post-create.R`: installazione dei pacchetti R non disponibili via conda.
- `env/check_environment.R`: controllo automatico dell'ambiente.
- `env/package-list.tsv`: elenco dei pacchetti e del loro ruolo nel corso.
- `env/README_installazione.md`: guida completa per Ubuntu e Windows con WSL2.
- `docs/programma_8_ore.md`: traccia didattica del corso.

## Installazione rapida

Su Ubuntu, o su Windows dentro WSL2/Ubuntu:

```bash
git clone https://github.com/EBosi/phd-microbiome-2026.git
cd phd-microbiome-2026

mamba env create -f env/metabarcoding-phd.yml
conda activate metabarcoding-phd

Rscript env/post-create.R
Rscript env/check_environment.R
```

Se `mamba` non e' ancora installato, seguire la guida completa:

```bash
less env/README_installazione.md
```

## AmpWrap

AmpWrap viene installato separatamente dalla sua repository:

```bash
cd "$HOME"
git clone https://github.com/LDoni/AmpWrap.git
cd AmpWrap/ampwrap
conda activate metabarcoding-phd
bash setup.sh
ampwrap short --help
```

## Avvio di RStudio

```bash
conda activate metabarcoding-phd
rstudio
```

Dentro RStudio:

```r
Sys.which("R")
.libPaths()
```

I percorsi devono puntare all'ambiente `metabarcoding-phd`.

## Controllo prima del corso

Eseguire:

```bash
conda activate metabarcoding-phd
Rscript env/check_environment.R
```

Il controllo deve terminare con:

```text
Environment check completed successfully
```

## Requisiti consigliati

- Ubuntu Linux, oppure Windows 11 con WSL2 e Ubuntu.
- Almeno 15 GB liberi su disco.
- Connessione stabile durante la creazione dell'ambiente.
- Installazione fatta prima dell'inizio del corso.
