IMAGE   := network-science-workshop
VERSION := 2026
ARCHIVE := $(IMAGE)_$(VERSION).tar.gz
PORT    := 8787

.PHONY: build run save load clean

## Build the image from the Containerfile (requires internet — run once)
build:
	podman build -t $(IMAGE):$(VERSION) .

## Run RStudio Server at http://localhost:8787  (user: rstudio  password: network2026)
run:
	podman run --rm -p $(PORT):8787 $(IMAGE):$(VERSION)

## Save image to a distributable file (USB stick, local server, etc.)
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

## Remove the saved archive
clean:
	rm -f $(ARCHIVE)

# Windows (Docker Desktop / WSL2) — same commands, same Makefile.
# Native CMD fallback:
#   docker load < $(ARCHIVE)
#   docker run --rm -p 8787:8787 $(IMAGE):$(VERSION)
