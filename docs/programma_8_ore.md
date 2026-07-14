# Programma corso metabarcoding PhD - 8 ore

## Obiettivi

Alla fine del corso i partecipanti dovrebbero essere in grado di:

- descrivere il razionale del metabarcoding e i principali passaggi sperimentali;
- orientarsi tra primer, marker, controlli, sequenziamento e limiti interpretativi;
- usare comandi Bash di base per esplorare file e cartelle di un workflow;
- lanciare AmpWrap e interpretare gli output principali;
- importare gli output in R/RStudio;
- eseguire analisi descrittive e biostatistiche di base su dati metabarcoding.

## Modulo 1 - Teoria del metabarcoding e del sequenziamento, 2 ore

- DNA metabarcoding: concetto, domande biologiche, casi d'uso.
- Marker e primer: 16S, 18S, ITS, COI e scelta del target.
- Disegno sperimentale: repliche, controlli negativi, mock community, contaminazioni.
- Sequenziamento: letture paired-end, qualita', profondita', errori, chimere.
- ASV/OTU, database tassonomici e limiti dell'assegnazione tassonomica.

## Modulo 2 - Bash essenziale per usare AmpWrap, 1 ora

- Terminale, directory di lavoro e percorsi.
- Comandi minimi: `pwd`, `ls`, `cd`, `mkdir`, `cp`, `mv`, `less`, `head`, `tail`.
- File FASTQ compressi e controllo rapido.
- Organizzazione di input, output e log.
- Attivazione dell'ambiente conda.

## Modulo 3 - AmpWrap: lancio workflow e lettura output, 2 ore

- Struttura di AmpWrap e requisiti di input.
- Configurazione minima di un run.
- Lancio del workflow durante il corso.
- Lettura progressiva di log, output intermedi e report.
- Output principali: quality control, trimming, denoising/clustering, tabelle, tassonomia.

## Modulo 4 - Introduzione a R/RStudio, 1 ora

- Avvio di RStudio dall'ambiente conda.
- Progetto, script, console e working directory.
- Importazione di tabelle AmpWrap.
- Oggetti base in R: data frame, fattori, tabelle di metadata.
- Primo controllo di campioni, taxa e metadata.

## Modulo 5 - Analisi biostatistica degli output, 2 ore

- Costruzione o importazione di oggetti `phyloseq`.
- Filtri, normalizzazione e trasformazioni.
- Alpha diversity e confronti tra gruppi.
- Beta diversity, distanze ecologiche e ordinamenti.
- PERMANOVA e interpretazione dei risultati.
- Grafici riproducibili con `ggplot2` e pacchetti collegati.

## Preparazione richiesta agli studenti

Prima del corso:

```bash
git clone https://github.com/EBosi/phd-microbiome-2026.git
cd phd-microbiome-2026
mamba env create -f env/metabarcoding-phd.yml
conda activate metabarcoding-phd
Rscript env/post-create.R
Rscript env/check_environment.R
```

Il giorno del corso portare il terminale gia' configurato e RStudio funzionante.
