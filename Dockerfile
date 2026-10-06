FROM ubuntu:latest

# Update package lists
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m -s /bin/bash testuser

# Allow testuser to use sudo without a password
RUN echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set working directory
WORKDIR /home/testuser

# Switch to non-root user
USER testuser

# Start with an interactive shell
CMD ["/bin/bash"]