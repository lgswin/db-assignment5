FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    ansible \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Ansible playbook and inventory
COPY up.yaml /app/
COPY ansible.cfg /app/

# Create directory for MySQL files
RUN mkdir -p /var/lib/mysql-files

# Command to run when container starts
CMD ["ansible-playbook", "up.yaml"] 