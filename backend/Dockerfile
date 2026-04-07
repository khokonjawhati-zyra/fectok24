FROM python:3.12-bookworm
WORKDIR /app

# Sovereign V15: Standard Image includes build-essential and headers

# Install Python dependencies
RUN pip install --no-cache-dir \
    fastapi \
    uvicorn[standard] \
    httpx \
    pydantic \
    python-dotenv \
    websockets \
    requests \
    google-api-python-client \
    google-auth-httplib2 \
    google-auth-oauthlib \
    PyJWT \
    passlib \
    pycryptodome \
    stripe \
    python-multipart

RUN mkdir -p /app/vault/data

# Copy local code
COPY . .

# Sovereign V15: Expose Backend Pulse
EXPOSE 5000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"]
