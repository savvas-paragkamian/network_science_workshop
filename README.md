# Network Science Workshop

Teaching material for the Network Science course in the [Bioinformatics MSc Program](https://bioinfo-grad.gr), University of Crete.

Hands-on R workshops covering graph models, network topology, community detection, and biological network analysis (*C. elegans* connectome, *E. coli* PPI). Published at [savvas-paragkamian.github.io/network_science_workshop](https://savvas-paragkamian.github.io/network_science_workshop/).

---

## Prerequisites

You need **Git** and either **Podman** or **Docker**. Pick the row that matches your OS.

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

> **Apple Silicon (M1/M2/M3):** The workshop image is built for `linux/amd64` because the base image (`rocker/tidyverse`) does not publish an `arm64` variant. **Docker Desktop** is the recommended choice on Apple Silicon — it uses Rosetta 2 to run `amd64` images natively and transparently, with no extra configuration. Podman works too but requires QEMU emulation (slower).

**Docker Desktop (recommended on Apple Silicon):**

Install [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/). It includes `docker compose` and handles `amd64` emulation via Rosetta 2 automatically.

**Podman (Intel Mac or if you prefer Podman):**

```bash
brew install git podman podman-compose
```

Podman on macOS runs inside a lightweight Linux VM. Initialise it once:

```bash
podman machine init          # download and configure the VM (~700 MB, once only)
podman machine start         # start the VM (run this after every reboot)
podman machine stop          # stop when not in use
```

On Apple Silicon with Podman, QEMU must be available in the VM for `linux/amd64` emulation. If the build fails with an architecture error, switch to Docker Desktop.

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

### Option A — Pull from Docker Hub (requires internet, ~1 GB)

```bash
podman pull savvasparagkamian/network-science-workshop:2026
# or: docker pull savvasparagkamian/network-science-workshop:2026
```

Then jump to [Start RStudio Server](#2-start-rstudio-server) below.

### Option B — Load from archive (offline, USB stick or local server)

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
make start          # background; prints the URL
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

All workshop notebooks and data are already inside the image — no internet needed.

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

> **SELinux (Fedora / RHEL):** The volume in `compose.yml` is annotated with `:z` for SELinux relabelling. This is correct on Fedora/RHEL and harmless elsewhere; do not remove it on those systems.

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

Click the **Render** button in the editor toolbar (or use the keyboard shortcut `Ctrl+Shift+K` · `Cmd+Shift+K`).

Alternatively, in the RStudio **Terminal** tab:

```bash
quarto render workshop/2026/workshop_network_science_2026.qmd
```

The output file `workshop_network_science_2026.html` is written to `2026/` — because the repo is mounted, the rendered HTML appears on your host at `2026/workshop_network_science_2026.html` immediately.

**Edit and save:**

Edit `.qmd` source files in RStudio or in your host editor — both see the same files. Re-render or re-run chunks to see changes.

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

## Repository layout

```
2018/               Fall 2018 course (R Markdown, igraph 1.x)
2025/               Spring 2025 course (R Markdown, igraph 2.x)
2026/               Spring 2026 course (Quarto, igraph 2.x, Leiden)
Data/               Shared datasets (BioGRID, C. elegans connectome)
Bibliography/       Shared .bib file
Images/             Shared figures
Containerfile       Lean OCI image (2026 course only)
Containerfile.full  Extended image (adds Bioconductor for 2018 GO section)
Makefile            One-word commands: build, start, stop, save, load
compose.yml         Instructor live-editing workflow
container/          apptainer.def for HPC/server use
.devcontainer/      GitHub Codespaces (Windows fallback)
```

## Packages

**CRAN:** `igraph`, `ggraph`, `tidygraph`, `poweRlaw`

**Bioconductor** (2018 GO section, `Containerfile.full` only): `AnnotationDbi`, `GO.db`, `topGO`, `Rgraphviz`, `GSEABase`, `org.EcK12.eg.db`
