# Base image for DGX (ARM64 / PyTorch)
FROM nvcr.io/nvidia/pytorch:25.11-py3

# 1. Install Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs git curl sudo && \
    apt-get clean

# 2. Install OpenClaw globally
RUN npm install -g openclaw@latest

# 3. Setup Workspace
WORKDIR /workspace
ENV PATH="/usr/local/bin:/root/.npm-global/bin:$PATH"

# 4. Setup Config Directory
RUN mkdir -p /root/.openclaw

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
