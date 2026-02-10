# Comfy-Base: Shared Base Image for ComfyUI Projects

## Project Overview

Shared Docker base image providing the common foundation for ComfyUI projects: CUDA, Python, PyTorch, ComfyUI, flash-attn, and common Python packages.

This image changes rarely — only when bumping CUDA, PyTorch, or ComfyUI versions.

## Docker Image

- **Image name:** `alvatar/comfy-base:latest`
- **Build:** `docker build -t alvatar/comfy-base:latest .`
- **Push:** `docker push alvatar/comfy-base:latest`
- **Registry:** Docker Hub under `alvatar/`

## What's Included

| Layer | Contents |
|-------|----------|
| Base | `nvidia/cuda:12.8.0-cudnn-devel-ubuntu24.04` |
| Python | 3.12 (pinned), venv at `/app/venv` |
| PyTorch | 2.9.1 cu128 |
| ComfyUI | via comfy-cli at `/app/comfyui` |
| flash-attn | Compiled from source (~10 min build) |
| Common pip | accelerate, transformers, einops, timm, scipy, opencv-python-headless, huggingface_hub, safetensors, sentencepiece, spandrel |
| CUDA archs | 7.0, 7.5, 8.0, 8.6, 8.9, 9.0, 10.0, 12.0 |

## Collaboration Rules

**We work together. Always ask before making changes.**

### Ask Permission Before
- Any file edits or code changes
- Docker builds, pushes, or destructive operations
- Dockerfile modifications
- Git commits or pushes

### Git Rules
- **NEVER commit or push without explicit permission**
- Show diffs and wait for approval before committing

### Honesty Requirements
- Never report skipped tests as passed
- Be explicit about what was tested vs what was not
- Don't claim success if the operation wasn't performed

## Critical Docker Cleanup Rules

### Safe Cleanup
```bash
docker container prune -f        # Remove stopped containers
docker image prune -f             # Remove dangling images only
docker builder prune -f           # Remove build cache
```

### NEVER Run
```bash
docker image prune -a             # Removes ALL unused images
docker system prune -a            # Removes everything
```

`alvatar/comfy-base:latest` takes ~15 minutes to build (flash-attn compilation). Accidentally pruning it means rebuilding from scratch.
