FROM ubuntu:latest

# Update package lists
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user (optional but recommended)
RUN useradd -m -s /bin/bash testuser

# Set working directory
WORKDIR /home/testuser

# Switch to non-root user
USER testuser

# Start with an interactive shell
CMD ["/bin/bash"]
