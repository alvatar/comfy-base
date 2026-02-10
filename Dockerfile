# ============================================
# COMFY-BASE: Shared base image for ComfyUI projects
# ============================================
# Used by: alvatar/comfy2d, alvatar/comfy3d
#
# Includes:
#   - CUDA 12.8 + cuDNN (devel, for compiling CUDA kernels)
#   - Python 3.12 venv
#   - PyTorch 2.9.1 (cu128)
#   - ComfyUI (via comfy-cli)
#   - flash-attn (compiled from source)
#   - Common Python packages
#   - SSH server
#
# Build:
#   docker build -t alvatar/comfy-base:latest .
# ============================================

FROM nvidia/cuda:12.8.0-cudnn-devel-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV TZ=Etc/UTC

# ============================================
# SYSTEM PACKAGES
# ============================================
# Superset of comfy2d + comfy3d requirements (minus Blender)
RUN apt-get update && apt-get install -y \
    git \
    git-lfs \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    python3-pip \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    libopengl0 \
    libxkbcommon0 \
    libxxf86vm1 \
    libxfixes3 \
    libxi6 \
    ffmpeg \
    wget \
    curl \
    build-essential \
    ninja-build \
    unzip \
    sudo \
    xz-utils \
    libeigen3-dev \
    openssh-server \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/sshd /root/.ssh && chmod 700 /root/.ssh

# ============================================
# CUDA ARCHITECTURE LIST
# ============================================
# V100(7.0), T4(7.5), A100(8.0), RTX30(8.6), RTX40/L40(8.9), H100(9.0),
# RTX50(10.0), Blackwell(12.0)
ENV TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6;8.9;9.0;10.0;12.0"

# ============================================
# PYTHON ENVIRONMENT
# ============================================
WORKDIR /app
RUN python3.12 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"
ENV VIRTUAL_ENV="/app/venv"

RUN pip install --upgrade pip setuptools wheel ninja

# ============================================
# PYTORCH
# ============================================
RUN pip install torch==2.9.1 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128

# ============================================
# COMFYUI INSTALLATION
# ============================================
RUN pip install comfy-cli
RUN comfy --workspace=/app/comfyui --skip-prompt install --nvidia

WORKDIR /app/comfyui

# ============================================
# HEAVY COMPILATIONS (slow to build, rarely change)
# ============================================
# flash-attn: ~10 min compile, needed by both comfy2d and comfy3d
RUN pip install flash-attn --no-build-isolation

# ============================================
# COMMON PYTHON PACKAGES
# ============================================
# Packages used by both comfy2d and comfy3d plugins
RUN pip install \
    accelerate \
    transformers \
    safetensors \
    scipy \
    opencv-python-headless \
    einops \
    timm \
    huggingface_hub \
    sentencepiece \
    spandrel

# ============================================
# DEFAULT SETTINGS
# ============================================
RUN mkdir -p /app/comfyui/user/default
COPY config/comfy.settings.json /app/comfyui/user/default/comfy.settings.json

# ============================================
# NETWORK / PORTS / ENTRYPOINT
# ============================================
EXPOSE 8188 22

# Default CMD — child images can override
CMD ["bash", "-c", "echo \"$SSH_PUBLIC_KEY\" > /root/.ssh/authorized_keys 2>/dev/null; chmod 600 /root/.ssh/authorized_keys; service ssh start; exec comfy --workspace=/app/comfyui launch -- --listen 0.0.0.0"]
