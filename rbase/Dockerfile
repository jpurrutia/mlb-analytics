# Use an R base image
FROM rocker/r-base:latest

# Create a working directory
RUN mkdir -p /apps

# Set Environment Variables (Modify as needed)
ENV PATH="/root/.local/bin/:$PATH"

# Install necessary system dependencies (modify if needed)
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libcurl4-openssl-dev \
    libssl-dev \
    libpq-dev  # PostgreSQL client (like psql in Python base)

# Set the working directory
WORKDIR /apps

# Copy R dependencies (assuming a dependencies file exists)
COPY requirements.R /apps/requirements.R

# Install R dependencies from the copied file
RUN Rscript /apps/requirements.R

# Print R version to verify installation
RUN echo "We're good:" \
    && R --version

# Keep container running (modify based on app needs)
CMD ["tail", "-f", "/dev/null"]
