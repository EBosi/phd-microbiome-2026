# Metabarcoding PhD Course 2026

[Italiano](#italiano) | [English](#english)

This repository contains the software environment and teaching material for the **Metabarcoding PhD Course 2026**. The course introduces basic use of the Linux command line, processing of amplicon-sequencing data with [AmpWrap](https://github.com/LDoni/AmpWrap), and downstream analysis in R/RStudio.

**Course website:** <https://ebosi.github.io/phd-microbiome-2026/>

**SEA4BLUE biostatistics material:** [download `Sea4Blue.zip`](https://ebosi.github.io/phd-microbiome-2026/downloads/Sea4Blue.zip)

The website is published from the `gh-pages` branch. If GitHub Pages is not yet enabled in the repository settings, set the source to `Deploy from a branch` and choose `gh-pages`.

> [!IMPORTANT]
> Complete the installation **before the course**. Creating the software environment downloads many packages and can require substantial time, disk space, and a stable internet connection.

---

# Italiano

## Indice

1. [Che cosa verrà installato](#che-cosa-verrà-installato)
2. [Requisiti](#requisiti)
3. [Prima di iniziare: come usare queste istruzioni](#prima-di-iniziare-come-usare-queste-istruzioni)
4. [Percorso A — Ubuntu installato direttamente sul computer](#percorso-a--ubuntu-installato-direttamente-sul-computer)
5. [Percorso B — Windows con WSL2 e Ubuntu](#percorso-b--windows-con-wsl2-e-ubuntu)
6. [Installazione comune su Ubuntu o WSL2](#installazione-comune-su-ubuntu-o-wsl2)
7. [Installazione di AmpWrap](#installazione-di-ampwrap)
8. [Controllo finale](#controllo-finale)
9. [Test di AmpWrap con dati di esempio](#test-di-ampwrap-con-dati-di-esempio)
10. [Avvio di RStudio](#avvio-di-rstudio)
11. [Uso quotidiano dopo l'installazione](#uso-quotidiano-dopo-linstallazione)
12. [Uso dei propri file FASTQ](#uso-dei-propri-file-fastq)
13. [Aggiornamento dell'installazione](#aggiornamento-dellinstallazione)
14. [Problemi comuni](#problemi-comuni)
15. [Diagnostica da inviare al docente](#diagnostica-da-inviare-al-docente)

## Che cosa verrà installato

La procedura crea un unico ambiente Conda chiamato `metabarcoding-phd`, contenente:

- R e RStudio;
- DADA2, phyloseq, vegan e altri pacchetti R per l'analisi del microbioma;
- Snakemake;
- FastQC, MultiQC, Cutadapt, SeqKit e altri strumenti da riga di comando;
- software per dati Illumina e Nanopore;
- AmpWrap, installato separatamente ma collegato allo stesso ambiente.

La repository contiene soltanto istruzioni, script, materiale didattico e la ricetta dell'ambiente. I programmi installati e i database possono occupare molti gigabyte e **non devono essere copiati dentro la repository GitHub**.

### Struttura principale della repository

```text
phd-microbiome-2026/
├── README.md
├── _quarto.yml
├── index.qmd
├── bash.qmd
├── ampwrap.qmd
├── intro-r.qmd
├── biostatistica.qmd
├── downloads/
│   └── Sea4Blue.zip
├── materials/
│   └── Sea4Blue/
├── docs/
│   └── programma_8_ore.md
└── env/
    ├── metabarcoding-phd.yml
    ├── post-create.R
    ├── check_environment.R
    ├── package-list.tsv
    └── README_installazione.md
```

## Requisiti

### Sistema operativo supportato

Scegliere uno dei seguenti percorsi:

- **Ubuntu Linux** installato direttamente sul computer; oppure
- **Windows 10/11 con WSL2 e Ubuntu**.

Le istruzioni sono pensate per computer Intel/AMD a 64 bit, identificati in Linux come `x86_64`. Computer Windows con processore ARM, per esempio alcuni modelli Snapdragon, non sono coperti da questa guida.

### Risorse consigliate

- almeno **8 GB di RAM**; 16 GB sono preferibili;
- almeno **15 GB liberi** per l'ambiente, preferibilmente 25–30 GB considerando database e risultati;
- connessione internet stabile;
- permessi di amministratore sul computer;
- tempo sufficiente per completare e verificare l'installazione prima del corso.

Per controllare lo spazio disponibile in Ubuntu:

```bash
# Mostra lo spazio disponibile nel filesystem che contiene la home dell'utente
df -h "$HOME"
```

## Prima di iniziare: come usare queste istruzioni

### Il terminale

Un **terminale** è una finestra nella quale si scrivono comandi testuali. In queste istruzioni si useranno:

- il terminale di **Ubuntu**, su un computer Linux;
- **PowerShell** e successivamente il terminale **Ubuntu**, su Windows.

I blocchi indicati come `powershell` devono essere eseguiti in PowerShell. I blocchi indicati come `bash` devono essere eseguiti nel terminale Ubuntu.

> [!WARNING]
> Non eseguire i comandi PowerShell nel terminale Ubuntu e non eseguire i comandi Bash in PowerShell.

### Come copiare i comandi

Copiare un blocco alla volta, incollarlo nel terminale e premere **Invio**. Non copiare eventuali simboli mostrati dal terminale prima del cursore, come `$`, `>` o il nome dell'utente.

### Password in Ubuntu

Quando un comando inizia con `sudo`, Ubuntu può chiedere la password dell'utente Linux:

```text
[sudo] password for nomeutente:
```

Durante la digitazione **non appare nulla sullo schermo**, nemmeno asterischi. È normale. Digitare la password e premere **Invio**.

In WSL questa è la password creata al primo avvio di Ubuntu. Non è necessariamente la password o il PIN di Windows.

### Interrompere un comando

Per interrompere un comando in esecuzione premere:

```text
Ctrl + C
```

Non chiudere il terminale durante la creazione dell'ambiente, a meno che il processo sia chiaramente bloccato o abbia prodotto un errore.

---

## Percorso A — Ubuntu installato direttamente sul computer

Aprire l'applicazione **Terminale**. È possibile trovarla nel menu delle applicazioni cercando “Terminale” o “Terminal”.

Controllare versione e architettura:

```bash
# Informazioni sulla versione di Ubuntu
cat /etc/os-release

# L'output atteso per un normale PC Intel/AMD è: x86_64
uname -m
```

Se `uname -m` restituisce `x86_64`, proseguire con la sezione [Installazione comune su Ubuntu o WSL2](#installazione-comune-su-ubuntu-o-wsl2).

---

## Percorso B — Windows con WSL2 e Ubuntu

WSL, Windows Subsystem for Linux, permette di eseguire Ubuntu all'interno di Windows. Tutti i programmi del corso verranno installati **dentro Ubuntu**, non direttamente in Windows.

Documentazione ufficiale Microsoft: <https://learn.microsoft.com/windows/wsl/install>

### B1. Installare WSL2 e Ubuntu

1. Aprire il menu Start.
2. Cercare **PowerShell**.
3. Fare clic con il tasto destro su **Windows PowerShell** o **Terminale**.
4. Scegliere **Esegui come amministratore**.
5. Accettare la richiesta di autorizzazione di Windows.

Eseguire:

```powershell
wsl --install -d Ubuntu
```

Riavviare Windows se richiesto.

> [!NOTE]
> Se il comando informa che WSL è già installato, non è un errore. Proseguire con il controllo della versione.

### B2. Primo avvio di Ubuntu

Aprire **Ubuntu** dal menu Start. Al primo avvio verranno richiesti:

1. un nome utente Linux, per esempio `mario`;
2. una password Linux;
3. la conferma della password.

Il nome utente dovrebbe essere semplice, senza spazi e preferibilmente senza lettere accentate. La password non viene mostrata durante la digitazione.

Conservare la password: servirà per i comandi `sudo`.

### B3. Controllare che Ubuntu usi WSL2

Aprire PowerShell, senza necessità di privilegi di amministratore, ed eseguire:

```powershell
wsl -l -v
```

Un risultato corretto è simile a:

```text
  NAME      STATE           VERSION
* Ubuntu    Running         2
```

Se la colonna `VERSION` mostra `1`, convertire Ubuntu a WSL2:

```powershell
wsl --set-version Ubuntu 2
```

Se la distribuzione ha un nome diverso, per esempio `Ubuntu-24.04`, usare esattamente quel nome:

```powershell
wsl --set-version Ubuntu-24.04 2
```

### B4. Aggiornare WSL

Da PowerShell:

```powershell
wsl --update
wsl --shutdown
```

Riaprire Ubuntu dal menu Start.

### B5. Controllare Ubuntu e WSLg

Nel terminale Ubuntu:

```bash
cat /etc/os-release
uname -m
printf 'DISPLAY=%s\n' "$DISPLAY"
printf 'WAYLAND_DISPLAY=%s\n' "$WAYLAND_DISPLAY"
```

L'architettura attesa è `x86_64`. Le variabili `DISPLAY` o `WAYLAND_DISPLAY` normalmente non sono vuote su una configurazione recente con WSLg; WSLg permette di aprire applicazioni grafiche Linux come RStudio.

### B6. Dove conservare i file

Per ottenere prestazioni migliori, repository, ambiente e dati di lavoro devono essere conservati nel filesystem Linux, per esempio:

```text
/home/nomeutente/
```

Evitare di eseguire AmpWrap direttamente in cartelle Windows come:

```text
/mnt/c/Users/NomeUtente/Desktop/
```

I file Windows rimangono comunque accessibili da Ubuntu sotto `/mnt/c/`.

Per aprire la cartella Linux corrente in Esplora file di Windows:

```bash
explorer.exe .
```

Proseguire ora con la procedura comune.

---

## Installazione comune su Ubuntu o WSL2

Da questo punto in poi i comandi sono uguali per Ubuntu nativo e Ubuntu in WSL2. Eseguirli nel **terminale Ubuntu**.

### 1. Aggiornare Ubuntu e installare gli strumenti di base

```bash
sudo apt update
sudo apt install -y \
    git \
    wget \
    curl \
    bzip2 \
    ca-certificates \
    build-essential
```

Controllare che Git sia disponibile:

```bash
git --version
```

### 2. Controllare se Conda è già installato

```bash
command -v conda
```

- Se non appare nulla, installare Miniforge seguendo il punto successivo.
- Se appare un percorso Linux, per esempio `/home/mario/miniforge3/bin/conda`, passare al punto 4.
- In WSL, se appare un percorso sotto `/mnt/c/`, non usare quella installazione: è una versione Windows di Conda. Installare Miniforge dentro Ubuntu.

### 3. Installare Miniforge

Miniforge fornisce Conda e Mamba. Mamba viene usato perché risolve e installa gli ambienti più rapidamente.

Questi comandi installano Miniforge nella cartella personale dell'utente senza modificare il resto del sistema:

```bash
cd "$HOME"

curl -L \
    "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh" \
    -o Miniforge3-Linux-x86_64.sh

bash Miniforge3-Linux-x86_64.sh -b -p "$HOME/miniforge3"

"$HOME/miniforge3/bin/conda" init bash
source "$HOME/.bashrc"

conda config --set channel_priority strict
conda config --set auto_activate_base false

rm -f "$HOME/Miniforge3-Linux-x86_64.sh"
```

Controllare l'installazione:

```bash
conda --version
mamba --version
```

Entrambi i comandi devono stampare un numero di versione.

Se viene mostrato `conda: command not found`, chiudere completamente il terminale Ubuntu, riaprirlo e riprovare.

### 4. Scaricare la repository del corso

```bash
cd "$HOME"
git clone https://github.com/EBosi/phd-microbiome-2026.git
cd "$HOME/phd-microbiome-2026"
```

Controllare la posizione e i file:

```bash
pwd
ls
```

L'output di `pwd` dovrebbe terminare con:

```text
/phd-microbiome-2026
```

Dovrebbero essere visibili almeno `README.md`, `docs` ed `env`.

#### Se la cartella esiste già

Non eseguire nuovamente `git clone`. Usare:

```bash
cd "$HOME/phd-microbiome-2026"
git pull --ff-only
```

### 5. Creare l'ambiente Conda del corso

Assicurarsi di essere nella repository:

```bash
cd "$HOME/phd-microbiome-2026"
```

Creare l'ambiente:

```bash
mamba env create -f env/metabarcoding-phd.yml
```

Il comando scarica e installa numerosi programmi. Durante questa fase è normale vedere molte righe di testo.

Al termine, attivare l'ambiente:

```bash
conda activate metabarcoding-phd
```

Quando l'ambiente è attivo, all'inizio della riga del terminale dovrebbe apparire:

```text
(metabarcoding-phd)
```

Controllare che Python e R provengano dall'ambiente:

```bash
echo "$CONDA_PREFIX"
which python
which R
which Rscript
python --version
R --version
```

I percorsi dovrebbero contenere `envs/metabarcoding-phd`.

#### Se l'ambiente esiste già

Aggiornarlo invece di ricrearlo:

```bash
cd "$HOME/phd-microbiome-2026"
mamba env update -n metabarcoding-phd -f env/metabarcoding-phd.yml --prune
conda activate metabarcoding-phd
```

### 6. Installare i pacchetti R aggiuntivi

Alcuni pacchetti R vengono installati dopo la creazione dell'ambiente:

```bash
cd "$HOME/phd-microbiome-2026"
conda activate metabarcoding-phd
Rscript env/post-create.R
```

Il risultato corretto termina con:

```text
Post-create setup completed successfully
```

Se il comando fallisce per un problema di rete, verificare la connessione e rieseguirlo. Lo script non reinstalla i pacchetti già presenti.

---

## Installazione di AmpWrap

AmpWrap viene scaricato dalla propria repository GitHub, ma viene installato nello stesso ambiente `metabarcoding-phd`. Non creare un secondo ambiente Conda chiamato `ampwrap`, perché duplicherebbe gran parte dei programmi.

### 1. Scaricare AmpWrap

```bash
cd "$HOME"
git clone https://github.com/LDoni/AmpWrap.git
```

Se la cartella `AmpWrap` esiste già:

```bash
cd "$HOME/AmpWrap"
git pull --ff-only
```

### 2. Installare i launcher di AmpWrap nell'ambiente

```bash
conda activate metabarcoding-phd
cd "$HOME/AmpWrap/ampwrap"
bash setup.sh
hash -r
```

Controllare:

```bash
which ampwrap
ampwrap --help
ampwrap short --help
```

`which ampwrap` dovrebbe restituire un percorso contenente:

```text
envs/metabarcoding-phd/bin/ampwrap
```

> [!IMPORTANT]
> Eseguire `bash setup.sh` soltanto dopo avere attivato `metabarcoding-phd`. Lo script installa i launcher nell'ambiente Conda attivo.

---

## Controllo finale

Tornare nella repository del corso ed eseguire lo script automatico di controllo:

```bash
cd "$HOME/phd-microbiome-2026"
conda activate metabarcoding-phd
Rscript env/check_environment.R
```

L'ultima parte dell'output deve contenere:

```text
Environment check completed successfully
```

Lo script controlla:

- la disponibilità dei principali pacchetti R;
- i programmi da riga di comando;
- i percorsi di R e Rscript;
- RStudio e AmpWrap, quando disponibili;
- eventuali dati del corso presenti nella repository.

Se compare `Environment check failed`, leggere le righe immediatamente precedenti: indicano quali componenti mancano.

---

## Test di AmpWrap con dati di esempio

Questo test scarica piccoli file FASTQ e avvia una pipeline AmpWrap completa. Richiede una connessione internet e può scaricare un database tassonomico nella cache di AmpWrap.

Creare una cartella dedicata al test:

```bash
mkdir -p "$HOME/ampwrap-runs/toy-short"
cd "$HOME/ampwrap-runs/toy-short"
conda activate metabarcoding-phd
```

Avviare il test:

```bash
bash "$HOME/AmpWrap/test/test_short.sh" 2>&1 | tee ampwrap-test-short.log
```

Al termine, controllare le cartelle create:

```bash
pwd
find . -maxdepth 3 -type f | head -50
```

Controllare la cache dei database:

```bash
ampwrap db list
```

Per conservare il risultato del test, non cancellare la cartella `~/ampwrap-runs/toy-short`.

---

## Avvio di RStudio

### Ubuntu nativo

Nel terminale:

```bash
conda activate metabarcoding-phd
rstudio
```

### Windows con WSL2

Aprire Ubuntu dal menu Start e usare gli stessi comandi:

```bash
conda activate metabarcoding-phd
rstudio
```

Una configurazione recente di WSL2 usa WSLg per aprire la finestra grafica di RStudio.

Dentro la console di RStudio eseguire:

```r
Sys.which(c("R", "Rscript"))
.libPaths()
```

I percorsi devono contenere `metabarcoding-phd`.

Per chiudere RStudio usare **File → Quit Session** oppure chiudere la finestra.

---

## Uso quotidiano dopo l'installazione

Non è necessario ripetere tutta l'installazione ogni volta.

### Aprire l'ambiente

1. Aprire il terminale Ubuntu.
2. Attivare l'ambiente:

```bash
conda activate metabarcoding-phd
```

3. Spostarsi nella cartella di lavoro desiderata con `cd`.

### Uscire dall'ambiente

```bash
conda deactivate
```

### Comandi Linux essenziali

```bash
pwd                 # mostra la cartella corrente
ls                  # elenca file e cartelle
ls -lh              # elenco con dimensioni leggibili
cd nome_cartella     # entra in una cartella
cd ..               # torna alla cartella superiore
cd "$HOME"          # torna alla propria home
mkdir nuova_cartella # crea una cartella
cp origine destinazione
mv origine destinazione
```

Prima di usare `rm`, controllare sempre con `pwd` e `ls` di trovarsi nella cartella corretta. I file eliminati con `rm` normalmente non passano dal cestino.

---

## Uso dei propri file FASTQ

### Copiare dati da Windows a WSL

In WSL, il disco `C:` di Windows è disponibile sotto `/mnt/c`.

Esempio:

```bash
mkdir -p "$HOME/projects/mia-analisi/input"

cp /mnt/c/Users/NOME_UTENTE_WINDOWS/Desktop/fastq/*.fastq.gz \
   "$HOME/projects/mia-analisi/input/"
```

Sostituire `NOME_UTENTE_WINDOWS` e il percorso con quelli reali.

Controllare i file copiati:

```bash
ls -lh "$HOME/projects/mia-analisi/input"
```

### Nomi dei file paired-end supportati

AmpWrap riconosce, tra gli altri, questi formati:

```text
sample_R1.fastq.gz
sample_R2.fastq.gz
```

oppure:

```text
sample_S1_L001_R1_001.fastq.gz
sample_S1_L001_R2_001.fastq.gz
```

Ogni file `R1` deve avere il corrispondente file `R2` con lo stesso nome del campione.

### Esempio di comando AmpWrap per letture Illumina

```bash
cd "$HOME/projects/mia-analisi"
conda activate metabarcoding-phd

ampwrap short \
    -i input \
    -a SEQUENZA_PRIMER_FORWARD \
    -A SEQUENZA_PRIMER_REVERSE \
    -l LUNGHEZZA_ATTESA_AMPLICON \
    -o output \
    -c 8
```

Sostituire:

- `SEQUENZA_PRIMER_FORWARD` con la sequenza del primer forward;
- `SEQUENZA_PRIMER_REVERSE` con la sequenza del primer reverse;
- `LUNGHEZZA_ATTESA_AMPLICON` con la lunghezza attesa dell'amplicone;
- `8` con un numero di CPU appropriato per il computer.

Non usare sequenze di primer o lunghezze prese da un esempio senza verificare che corrispondano al proprio esperimento.

Per vedere tutte le opzioni:

```bash
ampwrap short --help
```

---

## Aggiornamento dell'installazione

Eseguire gli aggiornamenti solo quando richiesto dal docente o prima di un nuovo corso/esercizio.

### Aggiornare la repository del corso

```bash
cd "$HOME/phd-microbiome-2026"
git pull --ff-only
```

### Aggiornare l'ambiente Conda

```bash
cd "$HOME/phd-microbiome-2026"
mamba env update -n metabarcoding-phd -f env/metabarcoding-phd.yml --prune
conda activate metabarcoding-phd
Rscript env/post-create.R
```

### Aggiornare AmpWrap

```bash
cd "$HOME/AmpWrap"
git pull --ff-only

conda activate metabarcoding-phd
cd "$HOME/AmpWrap/ampwrap"
bash setup.sh
hash -r
ampwrap --help
```

### Ricontrollare tutto

```bash
cd "$HOME/phd-microbiome-2026"
conda activate metabarcoding-phd
Rscript env/check_environment.R
```

---

## Problemi comuni

### `sudo` non mostra la password

È il comportamento normale di Linux. Digitare comunque la password e premere Invio.

### Password Ubuntu dimenticata in WSL

Da PowerShell controllare il nome della distribuzione:

```powershell
wsl -l -v
```

Avviarla come utente `root`:

```powershell
wsl -d Ubuntu -u root
```

Nel terminale root, trovare il nome utente:

```bash
ls /home
```

Reimpostare la password, sostituendo `nomeutente`:

```bash
passwd nomeutente
exit
```

### `conda: command not found`

Chiudere e riaprire il terminale Ubuntu. Se necessario:

```bash
source "$HOME/.bashrc"
```

Controllare:

```bash
command -v conda
```

Se Miniforge è installato in `~/miniforge3`, inizializzare nuovamente Conda:

```bash
"$HOME/miniforge3/bin/conda" init bash
source "$HOME/.bashrc"
```

### `mamba: command not found`

Con le versioni recenti di Miniforge, Mamba dovrebbe essere incluso. Controllare:

```bash
conda activate base
conda install -n base -c conda-forge mamba
conda deactivate
```

### `EnvironmentNameNotFound: metabarcoding-phd`

L'ambiente non è stato creato oppure la creazione non è terminata correttamente:

```bash
conda env list
cd "$HOME/phd-microbiome-2026"
mamba env create -f env/metabarcoding-phd.yml
```

### La creazione dell'ambiente si è interrotta

Verificare spazio e connessione:

```bash
df -h "$HOME"
```

Rimuovere un eventuale ambiente incompleto e ricrearlo:

```bash
conda env remove -n metabarcoding-phd
cd "$HOME/phd-microbiome-2026"
mamba env create -f env/metabarcoding-phd.yml
```

Usare la rimozione soltanto se l'ambiente è chiaramente incompleto o non funzionante.

### Un pacchetto R è mancante

```bash
cd "$HOME/phd-microbiome-2026"
conda activate metabarcoding-phd
Rscript env/post-create.R
Rscript env/check_environment.R
```

### `ampwrap: command not found`

```bash
conda activate metabarcoding-phd
cd "$HOME/AmpWrap/ampwrap"
bash setup.sh
hash -r
which ampwrap
```

### `git clone` dice che la cartella esiste già

Non clonare una seconda copia. Aggiornare quella esistente:

```bash
cd "$HOME/phd-microbiome-2026"
git pull --ff-only
```

Per AmpWrap:

```bash
cd "$HOME/AmpWrap"
git pull --ff-only
```

### `git pull` non procede a causa di modifiche locali

Git evita di cancellare file modificati. Mettere temporaneamente al sicuro le modifiche:

```bash
cd "$HOME/AmpWrap"
git status --short
git stash push -m "Modifiche locali prima dell'aggiornamento"
git pull --ff-only
```

Visualizzare le modifiche conservate:

```bash
git stash list
git stash show -p stash@{0}
```

Non usare immediatamente `git stash pop` se i file sono cambiati anche nella nuova versione: potrebbe creare conflitti. Chiedere assistenza al docente se le modifiche erano intenzionali.

### RStudio non si apre in WSL2

Nel terminale Ubuntu:

```bash
printf 'DISPLAY=%s\n' "$DISPLAY"
printf 'WAYLAND_DISPLAY=%s\n' "$WAYLAND_DISPLAY"
```

Poi, da PowerShell:

```powershell
wsl --update
wsl --shutdown
```

Riaprire Ubuntu e riprovare:

```bash
conda activate metabarcoding-phd
rstudio
```

Se RStudio grafico non è disponibile, R può comunque essere avviato nel terminale:

```bash
conda activate metabarcoding-phd
R
```

Per uscire da R:

```r
q()
```

### AmpWrap è molto lento in WSL2

Controllare che input, output e repository siano sotto la home Linux, per esempio:

```text
/home/nomeutente/projects/
```

Evitare di eseguire il workflow direttamente sotto `/mnt/c/`.

### I file Windows non sono visibili

Il disco `C:` è normalmente disponibile qui:

```bash
ls /mnt/c
ls /mnt/c/Users
```

I nomi contenenti spazi devono essere racchiusi tra virgolette:

```bash
ls "/mnt/c/Users/Nome Utente/Desktop"
```

---

## Diagnostica da inviare al docente

Se il problema persiste, eseguire questi comandi dalla repository e inviare **tutto l'output**, insieme al comando che ha prodotto l'errore:

```bash
cd "$HOME/phd-microbiome-2026"

printf '\n=== SISTEMA ===\n'
cat /etc/os-release
uname -a

printf '\n=== SPAZIO E MEMORIA ===\n'
df -h "$HOME"
free -h

printf '\n=== CONDA ===\n'
command -v conda || true
conda info || true
conda env list || true

printf '\n=== AMBIENTE DEL CORSO ===\n'
conda activate metabarcoding-phd
printf 'CONDA_PREFIX=%s\n' "$CONDA_PREFIX"
which R || true
which Rscript || true
which rstudio || true
which ampwrap || true

printf '\n=== CONTROLLO AUTOMATICO ===\n'
Rscript env/check_environment.R
```

Per salvare la diagnostica in un file:

```bash
cd "$HOME/phd-microbiome-2026"
conda activate metabarcoding-phd
Rscript env/check_environment.R 2>&1 | tee environment-check.log
```

Il file sarà disponibile come:

```text
~/phd-microbiome-2026/environment-check.log
```

---

# English

## Contents

1. [What will be installed](#what-will-be-installed)
2. [Requirements](#requirements)
3. [Before you begin: how to use these instructions](#before-you-begin-how-to-use-these-instructions)
4. [Path A — Ubuntu installed directly on the computer](#path-a--ubuntu-installed-directly-on-the-computer)
5. [Path B — Windows with WSL2 and Ubuntu](#path-b--windows-with-wsl2-and-ubuntu)
6. [Common installation on Ubuntu or WSL2](#common-installation-on-ubuntu-or-wsl2)
7. [Installing AmpWrap](#installing-ampwrap)
8. [Final environment check](#final-environment-check)
9. [Testing AmpWrap with example data](#testing-ampwrap-with-example-data)
10. [Starting RStudio](#starting-rstudio)
11. [Everyday use after installation](#everyday-use-after-installation)
12. [Using your own FASTQ files](#using-your-own-fastq-files)
13. [Updating the installation](#updating-the-installation)
14. [Common problems](#common-problems)
15. [Diagnostic information to send to the instructor](#diagnostic-information-to-send-to-the-instructor)

## What will be installed

The procedure creates one Conda environment named `metabarcoding-phd`, containing:

- R and RStudio;
- DADA2, phyloseq, vegan, and other R packages for microbiome analysis;
- Snakemake;
- FastQC, MultiQC, Cutadapt, SeqKit, and other command-line tools;
- software for Illumina and Nanopore data;
- AmpWrap, installed separately but linked to the same environment.

The repository contains only instructions, scripts, course material, and the environment recipe. Installed programs and databases may occupy many gigabytes and **must not be copied into the GitHub repository**.

### Main repository structure

```text
phd-microbiome-2026/
├── README.md
├── docs/
│   └── programma_8_ore.md
└── env/
    ├── metabarcoding-phd.yml
    ├── post-create.R
    ├── check_environment.R
    ├── package-list.tsv
    └── README_installazione.md
```

## Requirements

### Supported operating systems

Choose one of the following:

- **Ubuntu Linux** installed directly on the computer; or
- **Windows 10/11 with WSL2 and Ubuntu**.

These instructions are intended for 64-bit Intel/AMD computers, identified in Linux as `x86_64`. Windows ARM computers, including some Snapdragon models, are not covered by this guide.

### Recommended resources

- at least **8 GB RAM**; 16 GB is preferable;
- at least **15 GB free disk space** for the environment, preferably 25–30 GB when databases and results are included;
- a stable internet connection;
- administrator rights on the computer;
- enough time to complete and verify the installation before the course.

To check the free space in Ubuntu:

```bash
# Display free space on the filesystem containing your home directory
df -h "$HOME"
```

## Before you begin: how to use these instructions

### The terminal

A **terminal** is a window in which you enter text commands. These instructions use:

- the **Ubuntu terminal** on a Linux computer;
- **PowerShell**, followed by the **Ubuntu terminal**, on Windows.

Blocks labelled `powershell` must be run in PowerShell. Blocks labelled `bash` must be run in the Ubuntu terminal.

> [!WARNING]
> Do not run PowerShell commands in Ubuntu, and do not run Bash commands in PowerShell.

### Copying commands

Copy one block at a time, paste it into the terminal, and press **Enter**. Do not copy symbols displayed by the terminal before the cursor, such as `$`, `>`, or the user name.

### Passwords in Ubuntu

When a command starts with `sudo`, Ubuntu may request your Linux password:

```text
[sudo] password for username:
```

While you type, **nothing appears on screen**, not even asterisks. This is normal. Type the password and press **Enter**.

In WSL, this is the password that you created when Ubuntu was first opened. It is not necessarily your Windows password or PIN.

### Stopping a command

To stop a running command, press:

```text
Ctrl + C
```

Do not close the terminal while the environment is being created unless the process has clearly stopped or printed an error.

---

## Path A — Ubuntu installed directly on the computer

Open the **Terminal** application. It can usually be found by searching for “Terminal” in the applications menu.

Check the Ubuntu version and computer architecture:

```bash
# Ubuntu version information
cat /etc/os-release

# Expected output on a standard Intel/AMD PC: x86_64
uname -m
```

If `uname -m` returns `x86_64`, continue with [Common installation on Ubuntu or WSL2](#common-installation-on-ubuntu-or-wsl2).

---

## Path B — Windows with WSL2 and Ubuntu

WSL, the Windows Subsystem for Linux, runs Ubuntu inside Windows. All course software will be installed **inside Ubuntu**, not directly in Windows.

Official Microsoft documentation: <https://learn.microsoft.com/windows/wsl/install>

### B1. Install WSL2 and Ubuntu

1. Open the Start menu.
2. Search for **PowerShell**.
3. Right-click **Windows PowerShell** or **Terminal**.
4. Select **Run as administrator**.
5. Accept the Windows permission request.

Run:

```powershell
wsl --install -d Ubuntu
```

Restart Windows if requested.

> [!NOTE]
> If the command reports that WSL is already installed, this is not an error. Continue with the version check.

### B2. Open Ubuntu for the first time

Open **Ubuntu** from the Start menu. The first launch asks you to create:

1. a Linux user name, for example `mario`;
2. a Linux password;
3. confirmation of the password.

Use a simple user name without spaces and preferably without accented characters. The password is not displayed while you type it.

Keep this password: it is required by `sudo` commands.

### B3. Check that Ubuntu uses WSL2

Open PowerShell; administrator rights are not required for this step. Run:

```powershell
wsl -l -v
```

A correct result looks similar to:

```text
  NAME      STATE           VERSION
* Ubuntu    Running         2
```

If the `VERSION` column shows `1`, convert Ubuntu to WSL2:

```powershell
wsl --set-version Ubuntu 2
```

If the distribution has a different name, such as `Ubuntu-24.04`, use that exact name:

```powershell
wsl --set-version Ubuntu-24.04 2
```

### B4. Update WSL

From PowerShell:

```powershell
wsl --update
wsl --shutdown
```

Open Ubuntu again from the Start menu.

### B5. Check Ubuntu and WSLg

In the Ubuntu terminal:

```bash
cat /etc/os-release
uname -m
printf 'DISPLAY=%s\n' "$DISPLAY"
printf 'WAYLAND_DISPLAY=%s\n' "$WAYLAND_DISPLAY"
```

The expected architecture is `x86_64`. On a recent WSLg configuration, `DISPLAY` or `WAYLAND_DISPLAY` is normally not empty. WSLg allows graphical Linux applications such as RStudio to open on Windows.

### B6. Where to store files

For better performance, keep repositories, environments, and working data in the Linux filesystem, for example:

```text
/home/username/
```

Avoid running AmpWrap directly from Windows folders such as:

```text
/mnt/c/Users/WindowsUser/Desktop/
```

Windows files remain accessible from Ubuntu under `/mnt/c/`.

To open the current Linux folder in Windows File Explorer:

```bash
explorer.exe .
```

Continue with the common procedure below.

---

## Common installation on Ubuntu or WSL2

From this point onward, the commands are the same on native Ubuntu and Ubuntu in WSL2. Run them in the **Ubuntu terminal**.

### 1. Update Ubuntu and install basic tools

```bash
sudo apt update
sudo apt install -y \
    git \
    wget \
    curl \
    bzip2 \
    ca-certificates \
    build-essential
```

Check that Git is available:

```bash
git --version
```

### 2. Check whether Conda is already installed

```bash
command -v conda
```

- If nothing is displayed, install Miniforge in the next step.
- If a Linux path is displayed, such as `/home/mario/miniforge3/bin/conda`, continue to step 4.
- In WSL, if the path starts with `/mnt/c/`, do not use it: it is a Windows Conda installation. Install Miniforge inside Ubuntu.

### 3. Install Miniforge

Miniforge provides both Conda and Mamba. Mamba is used because it usually resolves and installs environments more quickly.

The following commands install Miniforge in your personal directory without changing the rest of the system:

```bash
cd "$HOME"

curl -L \
    "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh" \
    -o Miniforge3-Linux-x86_64.sh

bash Miniforge3-Linux-x86_64.sh -b -p "$HOME/miniforge3"

"$HOME/miniforge3/bin/conda" init bash
source "$HOME/.bashrc"

conda config --set channel_priority strict
conda config --set auto_activate_base false

rm -f "$HOME/Miniforge3-Linux-x86_64.sh"
```

Check the installation:

```bash
conda --version
mamba --version
```

Both commands should print a version number.

If `conda: command not found` is displayed, completely close the Ubuntu terminal, open it again, and retry.

### 4. Download the course repository

```bash
cd "$HOME"
git clone https://github.com/EBosi/phd-microbiome-2026.git
cd "$HOME/phd-microbiome-2026"
```

Check the location and files:

```bash
pwd
ls
```

The output of `pwd` should end with:

```text
/phd-microbiome-2026
```

At least `README.md`, `docs`, and `env` should be visible.

#### If the directory already exists

Do not run `git clone` again. Use:

```bash
cd "$HOME/phd-microbiome-2026"
git pull --ff-only
```

### 5. Create the course Conda environment

Make sure that you are inside the repository:

```bash
cd "$HOME/phd-microbiome-2026"
```

Create the environment:

```bash
mamba env create -f env/metabarcoding-phd.yml
```

This command downloads and installs many programs. It is normal to see many lines of text during this step.

When it finishes, activate the environment:

```bash
conda activate metabarcoding-phd
```

When the environment is active, the beginning of the terminal prompt should include:

```text
(metabarcoding-phd)
```

Check that Python and R come from the environment:

```bash
echo "$CONDA_PREFIX"
which python
which R
which Rscript
python --version
R --version
```

The paths should contain `envs/metabarcoding-phd`.

#### If the environment already exists

Update it rather than creating it again:

```bash
cd "$HOME/phd-microbiome-2026"
mamba env update -n metabarcoding-phd -f env/metabarcoding-phd.yml --prune
conda activate metabarcoding-phd
```

### 6. Install additional R packages

Some R packages are installed after the Conda environment has been created:

```bash
cd "$HOME/phd-microbiome-2026"
conda activate metabarcoding-phd
Rscript env/post-create.R
```

A successful result ends with:

```text
Post-create setup completed successfully
```

If the command fails because of a network problem, check the connection and run it again. The script does not reinstall packages that are already present.

---

## Installing AmpWrap

AmpWrap is downloaded from its own GitHub repository, but installed into the same `metabarcoding-phd` environment. Do not create a second Conda environment named `ampwrap`, because this would duplicate much of the software.

### 1. Download AmpWrap

```bash
cd "$HOME"
git clone https://github.com/LDoni/AmpWrap.git
```

If the `AmpWrap` directory already exists:

```bash
cd "$HOME/AmpWrap"
git pull --ff-only
```

### 2. Install the AmpWrap launchers in the environment

```bash
conda activate metabarcoding-phd
cd "$HOME/AmpWrap/ampwrap"
bash setup.sh
hash -r
```

Check the installation:

```bash
which ampwrap
ampwrap --help
ampwrap short --help
```

`which ampwrap` should return a path containing:

```text
envs/metabarcoding-phd/bin/ampwrap
```

> [!IMPORTANT]
> Run `bash setup.sh` only after activating `metabarcoding-phd`. The script installs the launchers into the currently active Conda environment.

---

## Final environment check

Return to the course repository and run the automatic check:

```bash
cd "$HOME/phd-microbiome-2026"
conda activate metabarcoding-phd
Rscript env/check_environment.R
```

The final part of the output must contain:

```text
Environment check completed successfully
```

The script checks:

- the main R packages;
- command-line programs;
- the R and Rscript paths;
- RStudio and AmpWrap, when available;
- any course data found in the repository.

If `Environment check failed` is displayed, read the immediately preceding lines: they identify the missing components.

---

## Testing AmpWrap with example data

This test downloads small FASTQ files and runs a complete AmpWrap pipeline. It requires an internet connection and may download a taxonomic database into the AmpWrap cache.

Create a dedicated test directory:

```bash
mkdir -p "$HOME/ampwrap-runs/toy-short"
cd "$HOME/ampwrap-runs/toy-short"
conda activate metabarcoding-phd
```

Run the test:

```bash
bash "$HOME/AmpWrap/test/test_short.sh" 2>&1 | tee ampwrap-test-short.log
```

When the test has finished, inspect the generated files:

```bash
pwd
find . -maxdepth 3 -type f | head -50
```

Inspect the database cache:

```bash
ampwrap db list
```

To keep the test results, do not delete `~/ampwrap-runs/toy-short`.

---

## Starting RStudio

### Native Ubuntu

In the terminal:

```bash
conda activate metabarcoding-phd
rstudio
```

### Windows with WSL2

Open Ubuntu from the Start menu and use the same commands:

```bash
conda activate metabarcoding-phd
rstudio
```

A recent WSL2 installation uses WSLg to open the graphical RStudio window.

In the RStudio console, run:

```r
Sys.which(c("R", "Rscript"))
.libPaths()
```

The paths must contain `metabarcoding-phd`.

Close RStudio using **File → Quit Session** or by closing the window.

---

## Everyday use after installation

You do not need to repeat the full installation each time.

### Open the environment

1. Open the Ubuntu terminal.
2. Activate the environment:

```bash
conda activate metabarcoding-phd
```

3. Move to the required working directory with `cd`.

### Leave the environment

```bash
conda deactivate
```

### Essential Linux commands

```bash
pwd                 # show the current directory
ls                  # list files and directories
ls -lh              # list files with readable sizes
cd directory_name   # enter a directory
cd ..               # move to the parent directory
cd "$HOME"          # return to your home directory
mkdir new_directory # create a directory
cp source destination
mv source destination
```

Before using `rm`, always check `pwd` and `ls` to confirm that you are in the correct directory. Files removed with `rm` normally do not go to a recycle bin.

---

## Using your own FASTQ files

### Copy data from Windows to WSL

In WSL, the Windows `C:` drive is available under `/mnt/c`.

Example:

```bash
mkdir -p "$HOME/projects/my-analysis/input"

cp /mnt/c/Users/WINDOWS_USER/Desktop/fastq/*.fastq.gz \
   "$HOME/projects/my-analysis/input/"
```

Replace `WINDOWS_USER` and the path with the real values.

Check the copied files:

```bash
ls -lh "$HOME/projects/my-analysis/input"
```

### Supported paired-end file names

AmpWrap recognizes, among others, these formats:

```text
sample_R1.fastq.gz
sample_R2.fastq.gz
```

or:

```text
sample_S1_L001_R1_001.fastq.gz
sample_S1_L001_R2_001.fastq.gz
```

Each `R1` file must have a corresponding `R2` file with the same sample name.

### Example AmpWrap command for Illumina reads

```bash
cd "$HOME/projects/my-analysis"
conda activate metabarcoding-phd

ampwrap short \
    -i input \
    -a FORWARD_PRIMER_SEQUENCE \
    -A REVERSE_PRIMER_SEQUENCE \
    -l EXPECTED_AMPLICON_LENGTH \
    -o output \
    -c 8
```

Replace:

- `FORWARD_PRIMER_SEQUENCE` with the forward primer sequence;
- `REVERSE_PRIMER_SEQUENCE` with the reverse primer sequence;
- `EXPECTED_AMPLICON_LENGTH` with the expected amplicon length;
- `8` with an appropriate number of CPUs for the computer.

Do not use primer sequences or lengths from an example without checking that they match your experiment.

Display all options with:

```bash
ampwrap short --help
```

---

## Updating the installation

Update only when requested by the instructor or before a new course/exercise.

### Update the course repository

```bash
cd "$HOME/phd-microbiome-2026"
git pull --ff-only
```

### Update the Conda environment

```bash
cd "$HOME/phd-microbiome-2026"
mamba env update -n metabarcoding-phd -f env/metabarcoding-phd.yml --prune
conda activate metabarcoding-phd
Rscript env/post-create.R
```

### Update AmpWrap

```bash
cd "$HOME/AmpWrap"
git pull --ff-only

conda activate metabarcoding-phd
cd "$HOME/AmpWrap/ampwrap"
bash setup.sh
hash -r
ampwrap --help
```

### Check everything again

```bash
cd "$HOME/phd-microbiome-2026"
conda activate metabarcoding-phd
Rscript env/check_environment.R
```

---

## Common problems

### `sudo` does not display the password

This is normal Linux behaviour. Type the password and press Enter.

### Forgotten Ubuntu password in WSL

From PowerShell, check the distribution name:

```powershell
wsl -l -v
```

Start it as the `root` user:

```powershell
wsl -d Ubuntu -u root
```

In the root terminal, find the user name:

```bash
ls /home
```

Reset the password, replacing `username`:

```bash
passwd username
exit
```

### `conda: command not found`

Close and reopen the Ubuntu terminal. If necessary:

```bash
source "$HOME/.bashrc"
```

Check:

```bash
command -v conda
```

If Miniforge is installed in `~/miniforge3`, initialize Conda again:

```bash
"$HOME/miniforge3/bin/conda" init bash
source "$HOME/.bashrc"
```

### `mamba: command not found`

Recent Miniforge versions normally include Mamba. Check or install it with:

```bash
conda activate base
conda install -n base -c conda-forge mamba
conda deactivate
```

### `EnvironmentNameNotFound: metabarcoding-phd`

The environment was not created, or creation did not finish correctly:

```bash
conda env list
cd "$HOME/phd-microbiome-2026"
mamba env create -f env/metabarcoding-phd.yml
```

### Environment creation was interrupted

Check disk space and the internet connection:

```bash
df -h "$HOME"
```

Remove an incomplete environment and create it again:

```bash
conda env remove -n metabarcoding-phd
cd "$HOME/phd-microbiome-2026"
mamba env create -f env/metabarcoding-phd.yml
```

Only remove the environment when it is clearly incomplete or broken.

### An R package is missing

```bash
cd "$HOME/phd-microbiome-2026"
conda activate metabarcoding-phd
Rscript env/post-create.R
Rscript env/check_environment.R
```

### `ampwrap: command not found`

```bash
conda activate metabarcoding-phd
cd "$HOME/AmpWrap/ampwrap"
bash setup.sh
hash -r
which ampwrap
```

### `git clone` reports that the directory already exists

Do not clone another copy. Update the existing repository:

```bash
cd "$HOME/phd-microbiome-2026"
git pull --ff-only
```

For AmpWrap:

```bash
cd "$HOME/AmpWrap"
git pull --ff-only
```

### `git pull` cannot continue because of local changes

Git is protecting modified files. Save the changes temporarily:

```bash
cd "$HOME/AmpWrap"
git status --short
git stash push -m "Local changes before update"
git pull --ff-only
```

Inspect the saved changes:

```bash
git stash list
git stash show -p stash@{0}
```

Do not immediately run `git stash pop` if the same files also changed in the new version, because this may create conflicts. Ask the instructor for help if the modifications were intentional.

### RStudio does not open in WSL2

In the Ubuntu terminal:

```bash
printf 'DISPLAY=%s\n' "$DISPLAY"
printf 'WAYLAND_DISPLAY=%s\n' "$WAYLAND_DISPLAY"
```

Then, from PowerShell:

```powershell
wsl --update
wsl --shutdown
```

Open Ubuntu again and retry:

```bash
conda activate metabarcoding-phd
rstudio
```

If graphical RStudio is unavailable, R can still be started in the terminal:

```bash
conda activate metabarcoding-phd
R
```

Exit R with:

```r
q()
```

### AmpWrap is very slow in WSL2

Check that input, output, and repository files are stored under the Linux home directory, for example:

```text
/home/username/projects/
```

Avoid running the workflow directly under `/mnt/c/`.

### Windows files are not visible

The `C:` drive is normally available here:

```bash
ls /mnt/c
ls /mnt/c/Users
```

Names containing spaces must be quoted:

```bash
ls "/mnt/c/Users/User Name/Desktop"
```

---

## Diagnostic information to send to the instructor

If a problem persists, run these commands from the repository and send **all output**, together with the command that produced the error:

```bash
cd "$HOME/phd-microbiome-2026"

printf '\n=== SYSTEM ===\n'
cat /etc/os-release
uname -a

printf '\n=== DISK AND MEMORY ===\n'
df -h "$HOME"
free -h

printf '\n=== CONDA ===\n'
command -v conda || true
conda info || true
conda env list || true

printf '\n=== COURSE ENVIRONMENT ===\n'
conda activate metabarcoding-phd
printf 'CONDA_PREFIX=%s\n' "$CONDA_PREFIX"
which R || true
which Rscript || true
which rstudio || true
which ampwrap || true

printf '\n=== AUTOMATIC CHECK ===\n'
Rscript env/check_environment.R
```

To save the diagnostic output to a file:

```bash
cd "$HOME/phd-microbiome-2026"
conda activate metabarcoding-phd
Rscript env/check_environment.R 2>&1 | tee environment-check.log
```

The file will be available at:

```text
~/phd-microbiome-2026/environment-check.log
```

---

## External documentation

- Microsoft WSL installation: <https://learn.microsoft.com/windows/wsl/install>
- Microsoft WSL setup and best practices: <https://learn.microsoft.com/windows/wsl/setup/environment>
- Miniforge: <https://github.com/conda-forge/miniforge>
- AmpWrap: <https://github.com/LDoni/AmpWrap>
