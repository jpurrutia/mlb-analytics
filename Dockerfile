FROM linuxbase

RUN mkdir /apps


ENV PATH=/venv/bin:$PATH
ENV PATH=/root/.cargo/bin:$PATH
ENV PATH="/root/.local/bin/:$PATH"

# Install uv and the PostgreSQL client (`psql`)
RUN apt-get update && apt-get install -y \
    ca-certificates \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Download UV
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install DuckDB
#RUN curl --fail --location --progress-bar --output duckdb_cli-linux-amd64.zip https://github.com/duckdb/duckdb/releases/download/v1.2.0/duckdb_cli-linux-amd64.zip && unzip duckdb_cli-linux-amd64.zip

# Set up a virtual env to use for whatever app is destined for this container.
RUN uv venv --python 3.12.6 /venv

RUN echo "\nsource /venv/bin/activate\n" >> /root/.zshrc
RUN uv --version


# Copy requirements to mlmlpythonbase container
COPY requirements.txt /apps/requirements.txt

# Run install of requirements
RUN uv pip install --upgrade -r /apps/requirements.txt \
    && uv pip install --upgrade granian[pname]

RUN uv pip install --upgrade jupyter

RUN uv pip install --upgrade granian[pname]

RUN echo "We're good:" \
RUN /venv/bin/python --version

# Expose Jupyter's default port
EXPOSE 8888

# Set the default command to run Jupyter
CMD ["uv", "jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
#CMD ["tail", "-f", "/dev/null"]
