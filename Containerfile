# Lean image for the 2026 course (and 2025).
# Base: rocker/tidyverse ships R, RStudio Server, tidyverse, devtools, rmarkdown, knitr.
# It stops before tinytex (LaTeX) — we render to HTML only, no PDF engine needed.
FROM docker.io/rocker/tidyverse:4.4.2

# System packages — all in one layer to keep image lean
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        libglpk-dev \
        neovim \
        tmux \
        git \
    && rm -rf /var/lib/apt/lists/*

# Quarto is in rocker/verse but not tidyverse; install the CLI directly
RUN curl -fsSL https://quarto.org/download/latest/quarto-linux-amd64.deb -o /tmp/quarto.deb \
    && dpkg -i /tmp/quarto.deb \
    && rm /tmp/quarto.deb

# CRAN packages not in rocker/tidyverse
RUN Rscript -e "install.packages( \
    c('igraph', 'ggraph', 'tidygraph', 'poweRlaw'), \
    repos = 'https://cloud.r-project.org', \
    Ncpus = parallel::detectCores())"

# Only the data files the 2026 workshop actually reads
COPY --chown=rstudio:rstudio Data/BIOGRID-ORGANISM-Escherichia_coli_K12_W3110-3.5.165.mitab.txt \
                              /home/rstudio/workshop/Data/
COPY --chown=rstudio:rstudio Data/C-elegans-frontal.txt \
                              Data/C-elegans-frontal-meta.csv \
                              /home/rstudio/workshop/Data/
COPY --chown=rstudio:rstudio Bibliography/ /home/rstudio/workshop/Bibliography/
COPY --chown=rstudio:rstudio Images/       /home/rstudio/workshop/Images/
COPY --chown=rstudio:rstudio 2026/         /home/rstudio/workshop/2026/

ENV PASSWORD=network2026 \
    ROOT=false

WORKDIR /home/rstudio/workshop
EXPOSE 8787
