# Network Science Workshop

Teaching material for the Network Science course in the [Bioinformatics MSc Program](https://bioinfo-grad.gr), University of Crete.

Hands-on R workshops covering graph models, network topology, community detection, and biological network analysis (C. elegans connectome, E. coli PPI). Published at [savvas-paragkamian.github.io/network_science_workshop](https://savvas-paragkamian.github.io/network_science_workshop/).

---

## Quick start (students)

You need [Podman](https://podman.io) (Linux/macOS) or [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows/macOS).

### 1. Load the image (no internet needed)

Receive `network-science-workshop_2026.tar.gz` from your instructor (USB stick or local server), then:

```bash
make load
```

or without Make:

```bash
podman load < network-science-workshop_2026.tar.gz
# Windows / Docker:
docker load < network-science-workshop_2026.tar.gz
```

### 2. Start RStudio Server

```bash
make start          # runs in background
make stop           # stop when done
```

or without Make:

```bash
podman run --rm -d --name network-science-workshop -p 8787:8787 network-science-workshop:2026
podman stop network-science-workshop
# Windows / Docker:
docker run --rm -d --name network-science-workshop -p 8787:8787 network-science-workshop:2026
docker stop network-science-workshop
```

### 3. Open in your browser

Go to **http://localhost:8787**

| Field    | Value          |
|----------|----------------|
| Username | `root`         |
| Password | `network2026`  |

> **Note:** Podman runs rootless by default, so the login user is `root` inside the container. You have full access to the workshop files but cannot affect your host system.

All workshop notebooks and data are already inside the image — no internet connection required after loading.

---

## Instructor workflow

### Build the image (requires internet, done once)

```bash
make build
```

### Distribute to students

```bash
make save           # → network-science-workshop_2026.tar.gz
```

Copy the `.tar.gz` to a USB stick or a local server. Students load it with `make load`.

### Live-editing (repo mounted, changes reflect immediately)

```bash
podman compose up
```

Open http://localhost:8787 — username `root`, password `network2026`. Edits to any file in the repo are visible inside the container without rebuilding.

### Full image (adds 2018 Gene Ontology section)

```bash
make build-full     # builds on top of the lean image
```

---

## HPC / server (Apptainer / Singularity)

```bash
# On a machine with internet — build and archive the OCI image
make build
make save                        # → network-science-workshop_2026.tar.gz

# Transfer the archive to HPC (scp, rsync, USB — your choice)

# On HPC — convert to SIF (no internet needed)
apptainer build workshop_2026.sif container/apptainer.def

# Run RStudio Server
apptainer exec \
    --bind $PWD/outputs:/home/rstudio/outputs \
    workshop_2026.sif /init
```

Open http://localhost:8787 — username `root`, password `network2026`.

---

## Repository layout

```
2018/           Fall 2018 course (R Markdown, igraph 1.x)
2025/           Spring 2025 course (R Markdown, igraph 2.x)
2026/           Spring 2026 course (Quarto, igraph 2.x, Leiden)
Data/           Shared datasets (BioGRID, C. elegans connectome)
Bibliography/   Shared .bib file
Images/         Shared figures
Containerfile   Lean OCI image (2026 course only)
Containerfile.full  Extended image (adds Bioconductor for 2018 GO section)
Makefile        One-word commands: build, run, save, load
compose.yml     Instructor live-editing workflow
container/      apptainer.def for HPC/server use
.devcontainer/  GitHub Codespaces (Windows fallback)
```

## Packages

**CRAN:** `igraph`, `ggraph`, `tidygraph`, `poweRlaw`

**Bioconductor** (2018 GO section, `Containerfile.full` only): `AnnotationDbi`, `GO.db`, `topGO`, `Rgraphviz`, `GSEABase`, `org.EcK12.eg.db`
