# Installazione ambiente metabarcoding PhD

Queste istruzioni creano un ambiente unico per:

- usare Bash su file FASTQ;
- eseguire AmpWrap;
- aprire R/RStudio;
- analizzare output metabarcoding con `phyloseq` e pacchetti R per biostatistica.

La piattaforma supportata e' Ubuntu. Su Windows usare WSL2 con Ubuntu.

## 1. Windows: installare WSL2 con Ubuntu

Aprire PowerShell come amministratore:

```powershell
wsl --install -d Ubuntu
```

Riavviare Windows se richiesto, aprire Ubuntu dal menu Start e creare utente/password Linux.

Per usare RStudio Desktop dentro WSL serve WSLg. Su Windows 11 e' incluso nelle installazioni WSL recenti.

Verifica dentro Ubuntu:

```bash
wsl.exe --version
echo $DISPLAY
```

Se `$DISPLAY` e' vuoto, RStudio Desktop grafico potrebbe non avviarsi da WSL.

## 2. Installare strumenti di base Ubuntu

Dentro Ubuntu:

```bash
sudo apt update
sudo apt install -y git wget bzip2 ca-certificates
```

## 3. Installare Miniforge

Dentro Ubuntu:

```bash
cd "$HOME"
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash Miniforge3-Linux-x86_64.sh
source "$HOME/.bashrc"
conda config --set channel_priority strict
```

Chiudere e riaprire il terminale Ubuntu se il comando `conda` non viene trovato.

Se il comando `mamba` non e' disponibile dopo l'installazione:

```bash
conda install -n base -c conda-forge mamba
```

## 4. Scaricare il materiale del corso

```bash
cd "$HOME"
git clone https://github.com/EBosi/phd-microbiome-2026.git
cd phd-microbiome-2026
```

Se la repository non e' ancora pubblica, usare l'URL fornito dal docente.

## 5. Creare l'ambiente

```bash
mamba env create -f env/metabarcoding-phd.yml
conda activate metabarcoding-phd
```

La creazione dell'ambiente puo' richiedere diversi minuti.

## 6. Installare i pacchetti R extra

Alcuni pacchetti R non sono disponibili come pacchetti conda. Installarli dentro l'ambiente attivo:

```bash
conda activate metabarcoding-phd
Rscript env/post-create.R
```

## 7. Installare AmpWrap

```bash
cd "$HOME"
git clone https://github.com/LDoni/AmpWrap.git
cd AmpWrap/ampwrap
conda activate metabarcoding-phd
bash setup.sh
ampwrap short --help
```

AmpWrap scarica o usa database esterni tramite la propria cache. I database non sono inclusi nell'ambiente conda.

## 8. Controllare l'ambiente

Tornare nella cartella del corso:

```bash
cd "$HOME/phd-microbiome-2026"
conda activate metabarcoding-phd
Rscript env/check_environment.R
```

Il controllo deve terminare con:

```text
Environment check completed successfully
```

## 9. Aprire RStudio

Dentro Ubuntu:

```bash
conda activate metabarcoding-phd
rstudio
```

In RStudio controllare che R provenga dall'ambiente conda:

```r
Sys.which("R")
.libPaths()
```

Il percorso dovrebbe contenere `metabarcoding-phd`.

## Problemi comuni

### `conda: command not found`

Chiudere e riaprire Ubuntu, poi:

```bash
source "$HOME/.bashrc"
```

### RStudio non si apre in WSL

Controllare:

```bash
echo $DISPLAY
wsl.exe --version
```

Se `$DISPLAY` e' vuoto, usare il terminale R con:

```bash
conda activate metabarcoding-phd
R
```

### Un pacchetto R risulta mancante

```bash
conda activate metabarcoding-phd
Rscript env/post-create.R
Rscript env/check_environment.R
```

### AmpWrap non viene trovato

```bash
conda activate metabarcoding-phd
which ampwrap
cd "$HOME/AmpWrap/ampwrap"
bash setup.sh
```

### Diagnostica da inviare al docente

```bash
conda info
conda list
which R
which Rscript
which rstudio
which ampwrap
Rscript env/check_environment.R
```
