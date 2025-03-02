FROM linuxbase

RUN mkdir /apps

ENV PATH=/venv/bin:$PATH
ENV PATH=/root/.cargo/bin:$PATH
ENV PATH="/root/.local/bin/:$PATH"

# Install uv and the PostgreSQL client (`psql`)
RUN apt-get update && apt-get install -y ca-certificates postgresql-client python3-pip

# Download UV
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && curl -O https://dl.min.io/client/mc/release/linux-amd64/mc \
    && chmod +x mc \
    && mv mc /usr/local/bin/

# Set up a virtual env to use for whatever app is destined for this container.
RUN uv venv --python 3.12.6 /venv

# Install base Python packages
RUN uv pip install \
    certifi==2025.1.31 \
    charset-normalizer==3.4.1 \
    click==8.1.8 \
    fsspec==2025.2.0 \
    gitdb==4.0.12 \
    gitpython==3.1.44 \
    giturlparse==0.12.0 \
    hexbytes==1.3.0 \
    humanize==4.11.0 \
    idna==3.10 \
    jsonpath-ng==1.7.0 \
    makefun==1.15.6 \
    markdown-it-py==3.0.0 \
    mdurl==0.1.2 \
    orjson==3.10.15 \
    packaging==24.2 \
    pathvalidate==3.2.3 \
    pendulum==3.0.0 \
    pluggy==1.5.0 \
    ply==3.11 \
    python-dateutil==2.9.0.post0 \
    pytz==2025.1 \
    pyyaml==6.0.2 \
    requests==2.32.3 \
    requirements-parser==0.11.0 \
    rich==13.9.4 \
    rich-argparse==1.7.0 \
    semver==3.0.4 \
    setuptools==75.8.0 \
    simplejson==3.19.3 \
    six==1.17.0 \
    smmap==5.0.2 \
    tenacity==9.0.0 \
    time-machine==2.16.0 \
    tomlkit==0.13.2 \
    types-setuptools==75.8.0.20250210 \
    typing-extensions==4.12.2 \
    tzdata==2025.1 \
    urllib3==2.3.0

RUN echo "\nsource /venv/bin/activate\n" >> /root/.zshrc
RUN uv --version

# Copy ingestion to pythonbase container
#COPY ingest_claims /apps/ingest_claims

# Copy requirements to pythonbase container
COPY requirements.txt /apps/requirements.txt

# Run install of requirements
RUN uv pip install --upgrade -r /apps/requirements.txt \
    && uv pip install --upgrade granian[pname]

#COPY tests /apps/tests

RUN echo "We're good:" \
RUN /venv/bin/python --version

CMD ["tail", "-f", "/dev/null"]