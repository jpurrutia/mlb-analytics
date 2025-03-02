FROM pythonbase

WORKDIR /app

# Copy source code files
COPY . /app/ingestbase/

# Install DLT and dependencies
COPY requirements.txt /app/
RUN uv pip install -r requirements.txt

# Add app directory to Python path
ENV PYTHONPATH=/app:$PYTHONPATH

CMD ["tail", "-f", "/dev/null"]
