FROM python:3.12-bookworm

# Sovereign V15: Security Hardening Pulse
# Upgrading base packages to patch known vulnerabilities
# Full Bookworm has curl and xz-utils pre-installed
RUN curl -L https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz | tar -xJ -C /usr/local/bin --strip-components=2

WORKDIR /app

# Copy requirements if any (processor engine uses standard libs mostly)
# For V15, we'll just install common needs
RUN pip install python-dotenv

COPY . .

# Environment sensing
ENV IS_DOCKER=True
ENV PYTHONUNBUFFERED=1

CMD ["python", "-u", "processor_engine.py"]
