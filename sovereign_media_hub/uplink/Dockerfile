FROM python:3.11-bookworm
WORKDIR /app
# Full Bookworm has curl and xz-utils pre-installed
RUN curl -L https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz | tar -xJ -C /usr/local/bin --strip-components=2

RUN pip install --no-cache-dir flask flask-cors requests python-dotenv
COPY . .
CMD ["python", "uplink_server.py"]
