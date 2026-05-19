# OCI-compliant image — works with: podman build, docker build, apptainer build
# rocker/verse ships: R 4.4.2, RStudio Server, tidyverse, rmarkdown, knitr, BiocManager, Quarto
FROM rocker/verse:4.4.2

# igraph links against libglpk; Rgraphviz needs the graphviz headers at build time
RUN apt-get update && apt-get install -y --no-install-recommends \
        libglpk-dev \
        graphviz \
        libgraphviz-dev \
    && rm -rf /var/lib/apt/lists/*

# CRAN — only packages not already in rocker/verse
RUN Rscript -e "install.packages( \
    c('igraph', 'ggraph', 'tidygraph', 'poweRlaw'), \
    repos = 'https://cloud.r-project.org', \
    Ncpus = parallel::detectCores())"

# Bioconductor — used in the GO enrichment section of workshop_2 (2018)
RUN Rscript -e "BiocManager::install( \
    c('AnnotationDbi', 'GO.db', 'topGO', 'Rgraphviz', \
      'GSEABase', 'org.EcK12.eg.db'), \
    ask = FALSE, update = FALSE)"

# Bundle course materials so the image is self-contained.
# Students need only the image file — no git clone, no internet at runtime.
COPY --chown=rstudio:rstudio Data/         /home/rstudio/workshop/Data/
COPY --chown=rstudio:rstudio Bibliography/ /home/rstudio/workshop/Bibliography/
COPY --chown=rstudio:rstudio Images/       /home/rstudio/workshop/Images/
COPY --chown=rstudio:rstudio 2026/         /home/rstudio/workshop/2026/

# Password baked in — acceptable for an offline teaching image.
# Override at runtime: podman run -e PASSWORD=other ...
ENV PASSWORD=network2026 \
    ROOT=false

WORKDIR /home/rstudio/workshop
EXPOSE 8787
