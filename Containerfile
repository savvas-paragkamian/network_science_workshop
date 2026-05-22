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

# Quarto — detect arch so the same Containerfile builds on amd64 and arm64
RUN ARCH=$(dpkg --print-architecture) \
    && curl -fsSL "https://quarto.org/download/latest/quarto-linux-${ARCH}.deb" -o /tmp/quarto.deb \
    && dpkg -i /tmp/quarto.deb \
    && rm /tmp/quarto.deb

# rocker/tidyverse already has ggplot2, dplyr, tidyr, tibble, purrr, knitr.
# Only add the two packages the 2026 workshop needs beyond that.
RUN Rscript -e "install.packages( \
    c('igraph', 'poweRlaw'), \
    repos = 'https://cloud.r-project.org', \
    Ncpus = parallel::detectCores())"

# Only the data files the 2026 workshop actually reads
COPY --chown=rstudio:rstudio Data/BIOGRID-ORGANISM-Escherichia_coli_K12_W3110-3.5.165.mitab.txt \
                              /home/rstudio/Data/
COPY --chown=rstudio:rstudio Data/C-elegans-frontal.txt \
                              Data/C-elegans-frontal-meta.csv \
                              /home/rstudio/Data/
COPY --chown=rstudio:rstudio Bibliography/ /home/rstudio/Bibliography/
COPY --chown=rstudio:rstudio Images/       /home/rstudio/Images/
COPY --chown=rstudio:rstudio 2026/         /home/rstudio/2026/

RUN echo 'session-default-working-dir=/home/rstudio' >> /etc/rstudio/rsession.conf

ENV PASSWORD=network2026 \
    ROOT=false \
    HOME=/home/rstudio

WORKDIR /home/rstudio
EXPOSE 8787
