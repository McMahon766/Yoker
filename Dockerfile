FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY edge_tts_api.py .

# Create non-root user (Render best practice)
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app && \
    mkdir -p /tmp && \
    chown -R appuser:appuser /tmp

USER appuser

# Render assigns PORT dynamically
ENV PORT=8000
EXPOSE 8000

CMD uvicorn edge_tts_api:app --host 0.0.0.0 --port ${PORT} --workers 2
