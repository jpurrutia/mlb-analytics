FROM pythonbase

# Replace the existing requirements with your ML/AI requirements.
# (Assume this requirements.txt includes scikit-learn, tensorflow, pandas, etc., plus duckdb.)
COPY requirements.txt /apps/requirements.txt

# Install the ML/AI packages and Jupyter Notebook.
RUN uv pip install --upgrade -r /apps/requirements.txt \
    && uv pip install --upgrade jupyter

# (Optional) Set the default command to run Jupyter Notebook.
# Remove or change this if you prefer to override it via docker-compose.
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
