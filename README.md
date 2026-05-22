# Network Science Workshop

Teaching material for the Network Science course in the [Bioinformatics MSc Program](https://bioinfo-grad.gr), University of Crete.

Hands-on R workshops covering graph models, network topology, community detection, and biological network analysis (*C. elegans* connectome, *E. coli* PPI). Published at [savvas-paragkamian.github.io/network_science_workshop](https://savvas-paragkamian.github.io/network_science_workshop/).

---

## Repository structure

```
2018/               Fall 2018 course (R Markdown, igraph 1.x)
2025/               Spring 2025 course (R Markdown, igraph 2.x)
2026/               Spring 2026 course (Quarto, igraph 2.x, Leiden)
Data/               Shared datasets (BioGRID, C. elegans connectome)
Bibliography/       Shared .bib file
Images/             Shared figures
renv.lock           Pinned R package versions (for non-container use)
Containerfile       Lean OCI image — 2026 course (igraph + poweRlaw on rocker/tidyverse)
Containerfile.full  Extended image — adds Bioconductor for 2018 GO section
Makefile            One-word commands: build, start, stop, save, load
compose.yml         Instructor live-editing workflow (repo mounted into container)
container/          apptainer.def for HPC / server use
.devcontainer/      GitHub Codespaces (Windows fallback)
```

---

## Choose your setup

| Situation | Recommended path |
|-----------|-----------------|
| Student, workshop day, USB stick | [Load image from archive](#option-b----load-from-archive-offline) |
| Student, internet available | [Pull from Docker Hub](#option-a----pull-from-docker-hub-requires-internet) |
| No Docker/Podman (QEMU issues, etc.) | [renv — plain R install](#option-c----no-container-renv) |
| Instructor preparing or editing content | [Instructor workflow](#instructor--developer-workflow) |
| HPC or shared server | [Apptainer / Singularity](#hpc--server-apptainer--singularity) |

All container paths require **Git** and **Podman** or **Docker**. The renv path requires only **R ≥ 4.3** and **Quarto**.

---

## Prerequisites

### Linux

<details>
<summary><strong>Fedora / RHEL / CentOS Stream</strong></summary>

```bash
sudo dnf install -y git podman podman-compose
```

Podman runs rootless by default — no daemon, no `sudo` needed for container commands.
</details>

<details>
<summary><strong>Ubuntu / Debian</strong></summary>

```bash
# Podman (recommended — rootless, no daemon)
sudo apt-get update
sudo apt-get install -y git podman podman-compose

# OR Docker Engine
sudo apt-get install -y git docker.io docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER   # log out and back in for group to take effect
```
</details>

<details>
<summary><strong>Arch Linux</strong></summary>

```bash
sudo pacman -S git podman podman-compose
# or: sudo pacman -S git docker docker-compose
```
</details>

### macOS

The Containerfile detects the CPU architecture at build time and installs the matching Quarto binary, so both **Intel** and **Apple Silicon** builds work natively.

**Docker Desktop (recommended):**

Install [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/). It includes `docker compose` and handles cross-architecture images automatically.

**Podman:**

```bash
brew install git podman podman-compose
```

Initialise the Podman VM once:

```bash
podman machine init    # download and configure the VM (~700 MB, once only)
podman machine start   # start the VM (run after every reboot)
podman machine stop    # stop when not in use
```

> If Podman fails with a QEMU / architecture error, use Docker Desktop or the [renv path](#option-c----no-container-renv) instead.

### Windows

**Option A — Docker Desktop (simplest):**

1. Install [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/) (requires WSL2 backend; the installer enables it).
2. Install [Git for Windows](https://git-scm.com/download/win).
3. Open **Git Bash** or **PowerShell** for all commands below.

**Option B — WSL2 + Podman (advanced):**

1. Enable WSL2: `wsl --install` in an admin PowerShell, reboot.
2. Open the Ubuntu WSL2 terminal and follow the Ubuntu instructions above.

> All `make` commands work in Git Bash and WSL2. In PowerShell, use the explicit `podman`/`docker` commands shown alongside each `make` target.

---

## Clone the repository

```bash
git clone https://github.com/savvas-paragkamian/network_science_workshop.git
cd network_science_workshop
```

---

## Quick start — students

### Option A — Pull from Docker Hub (requires internet)

```bash
podman pull savvasparagkamian/network-science-workshop:2026
# or: docker pull savvasparagkamian/network-science-workshop:2026
```

Then jump to [Start RStudio Server](#2-start-rstudio-server) below.

### Option B — Load from archive (offline)

Receive `network-science-workshop_2026.tar.gz` from your instructor, then:

```bash
make load
```

<details>
<summary>Without Make</summary>

```bash
# Linux / macOS (Podman)
podman load < network-science-workshop_2026.tar.gz

# Windows / Docker
docker load < network-science-workshop_2026.tar.gz
```
</details>

### 2. Start RStudio Server

```bash
make start          # runs in background; prints the URL
make stop           # stop when done
```

<details>
<summary>Without Make</summary>

```bash
# Podman
podman run --rm -d --name network-science-workshop \
    -p 8787:8787 network-science-workshop:2026
podman stop network-science-workshop

# Docker
docker run --rm -d --name network-science-workshop \
    -p 8787:8787 network-science-workshop:2026
docker stop network-science-workshop
```
</details>

### 3. Open in your browser

Go to **http://localhost:8787**

| Field    | Value         |
|----------|---------------|
| Username | `rstudio`     |
| Password | `network2026` |

> **Podman note:** Podman is rootless, so the effective user inside the container is `root`. Use `root` as the username if `rstudio` is rejected.

All workshop notebooks and data are already inside the image — no internet needed at runtime.

---

## Option C — No container (renv)

If Docker/Podman is unavailable (QEMU issues, corporate firewall, no admin rights), install the packages directly into your local R.

**Requirements:** R ≥ 4.3, [Quarto CLI](https://quarto.org/docs/get-started/).

```r
# In R — installs all pinned dependencies from renv.lock
install.packages("renv")
renv::restore(lockfile = "renv.lock", prompt = FALSE)
```

Then render the workshop notebook from the terminal:

```bash
quarto render 2026/workshop_network_science_2026.qmd
```

Or open the `.qmd` in RStudio and click **Render**.

---

## Instructor / developer workflow

This workflow mounts the repository into the container so that every file edit on your host is immediately visible inside RStudio — no rebuild required.

### 1. Build the image

Requires internet. Run once; takes 5–10 minutes.

```bash
make build
```

<details>
<summary>Without Make</summary>

```bash
# Podman
podman build -t network-science-workshop:2026 -f Containerfile .

# Docker
docker build -t network-science-workshop:2026 -f Containerfile .
```
</details>

### 2. Start with Compose (live mount)

```bash
podman compose up          # Podman
docker compose up          # Docker
```

The `compose.yml` mounts the entire repository at `/home/rstudio/workshop` inside the container. Any file you save in your editor on the host appears instantly in RStudio.

> **SELinux (Fedora / RHEL):** The volume in `compose.yml` is annotated with `:z` for SELinux relabelling. This is correct on Fedora/RHEL and harmless elsewhere.

> **macOS / Windows:** If Compose reports a bind-mount permission error, ensure the Podman VM or Docker Desktop has access to your home directory (Docker Desktop → Settings → Resources → File Sharing).

To run in the background:

```bash
podman compose up -d       # detached
podman compose down        # stop and remove the container
```

### 3. Open RStudio Server

Go to **http://localhost:8787**

| Field    | Value         |
|----------|---------------|
| Username | `root`        |
| Password | `network2026` |

The compose file sets `ROOT: "true"`, so the login is always `root` in this workflow.

### 4. Working in RStudio

**Navigate to the workshop notebook:**

In the **Files** pane (bottom-right), open:
```
workshop/ → 2026/ → workshop_network_science_2026.qmd
```

**Run individual code chunks:**

| Action | Keyboard shortcut |
|--------|-------------------|
| Run current chunk | `Ctrl+Shift+Enter` (Windows/Linux) · `Cmd+Shift+Enter` (macOS) |
| Run current line / selection | `Ctrl+Enter` · `Cmd+Enter` |
| Run all chunks above | `Ctrl+Alt+P` · `Cmd+Option+P` |
| Run all chunks | `Ctrl+Alt+R` · `Cmd+Option+R` |

Click the green **▶ Run** triangle at the top-right of any chunk to run it individually, or the downward **▾** arrow to run all chunks above.

**Render the full document to HTML:**

Click the **Render** button in the editor toolbar (or `Ctrl+Shift+K` · `Cmd+Shift+K`).

Alternatively, in the RStudio **Terminal** tab:

```bash
quarto render workshop/2026/workshop_network_science_2026.qmd
```

The output `workshop_network_science_2026.html` is written to `2026/` — because the repo is mounted, the rendered HTML appears on your host immediately.

### 5. Stop

```bash
podman compose down        # Podman
docker compose down        # Docker
```

### 6. Distribute to students

Once satisfied with the content, export the image:

```bash
make save           # → network-science-workshop_2026.tar.gz
```

Copy the `.tar.gz` to a USB stick or a local server. Students load it with `make load`.

### 7. Full image (adds 2018 Gene Ontology section)

```bash
make build-full     # builds Containerfile.full on top of the lean image
```

This adds Bioconductor packages (`topGO`, `Rgraphviz`, `org.EcK12.eg.db`, etc.) needed for the 2018 workshop.

---

## HPC / server (Apptainer / Singularity)

```bash
# On a machine with internet — build and export the OCI image
make build
make save                              # → network-science-workshop_2026.tar.gz

# Transfer the archive to HPC (scp, rsync, USB — your choice)

# On HPC — convert to SIF (no internet needed)
apptainer build workshop_2026.sif container/apptainer.def

# Run RStudio Server
apptainer exec \
    --bind $PWD:/home/rstudio/workshop \
    workshop_2026.sif /init
```

Open **http://localhost:8787** — username `root`, password `network2026`.

---

## Packages

**2026 workshop** (`Containerfile`, `renv.lock`): `igraph`, `poweRlaw` — plus `ggplot2`, `dplyr`, `tidyr`, `tibble`, `purrr`, `knitr` which are pre-installed in the `rocker/tidyverse` base image. Network visualisations use base `plot.igraph()` — no `ggraph` or `tidygraph` required.

**Bioconductor** (2018 GO section, `Containerfile.full` only): `AnnotationDbi`, `GO.db`, `topGO`, `Rgraphviz`, `GSEABase`, `org.EcK12.eg.db`
