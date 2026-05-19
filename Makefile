IMAGE    := network-science-workshop
VERSION  := 2026
ARCHIVE  := $(IMAGE)_$(VERSION).tar.gz
PORT     := 8787
# rocker/tidyverse only publishes linux/amd64 for this tag.
# Pinning the platform here ensures the build works from any host architecture
# (Apple Silicon M1/M2, x86_64, etc.) and produces an image that runs natively
# on x86_64 lab machines.  On Apple Silicon, Docker Desktop uses Rosetta 2
# automatically; Podman uses QEMU — both are transparent to the user.
PLATFORM := linux/amd64

.PHONY: build build-full run start stop save load clean

## Build the lean image for the 2026 course (requires internet — run once)
build:
	podman build --platform $(PLATFORM) -t $(IMAGE):$(VERSION) -f Containerfile .

## Build the full image including Bioconductor for the 2018 GO section
build-full: build
	podman build --platform $(PLATFORM) -t $(IMAGE):$(VERSION)-full -f Containerfile.full .

## Run RStudio Server in the foreground (Ctrl-C to stop)
run:
	podman run --rm -p $(PORT):8787 $(IMAGE):$(VERSION)

## Start RStudio Server in the background → http://localhost:8787  (user: root  password: network2026)
start:
	podman run --rm -d --name $(IMAGE) -p $(PORT):8787 $(IMAGE):$(VERSION)
	@echo "  RStudio Server running at http://localhost:$(PORT)"
	@echo "  Username: root   Password: network2026"
	@echo "  Stop with: make stop"

## Stop the background container
stop:
	podman stop $(IMAGE)

## Save lean image to a distributable file (USB stick, local server, etc.)
save: $(ARCHIVE)

$(ARCHIVE):
	podman save $(IMAGE):$(VERSION) | gzip > $(ARCHIVE)
	@echo ""
	@echo "  Distribute $(ARCHIVE) to students."
	@echo "  They load it with:  make load   (or: podman load < $(ARCHIVE))"
	@echo "  Then run with:      make run"
	@echo ""

## Load a pre-built image — students use this, not 'build'
load:
	podman load < $(ARCHIVE)

clean:
	rm -f $(ARCHIVE)

# Windows (Docker Desktop / WSL2): same commands work.
# Native CMD fallback:
#   docker load < $(ARCHIVE)
#   docker run --rm -p 8787:8787 $(IMAGE):$(VERSION)
