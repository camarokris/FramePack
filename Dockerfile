# Use NVIDIA CUDA base image with Python 3.10
FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-dev \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create symbolic links for Python if they don't exist
RUN if [ ! -f /usr/bin/python ]; then ln -s /usr/bin/python3.10 /usr/bin/python; fi && \
    if [ ! -f /usr/bin/pip ]; then ln -s /usr/bin/pip3 /usr/bin/pip; fi

# Set working directory
WORKDIR /app

# Copy requirements files
COPY requirements.txt requirements.docker.txt ./

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.docker.txt

# Install PyTorch with CUDA support
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Copy the rest of the application
COPY . .

# Create outputs directory
RUN mkdir -p outputs

# Expose port for Gradio
EXPOSE 7860

# Set the entrypoint
ENTRYPOINT ["python", "demo_gradio.py"] 