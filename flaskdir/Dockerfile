# For more information, please refer to https://aka.ms/vscode-docker-python
FROM python:3.9-slim-buster

WORKDIR /app

EXPOSE 5000

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

# Install pip requirements
COPY flaskdir/requirements.txt .
# I added this to  debug
RUN apt-get update && apt-get install -y build-essential libpq-dev && rm -rf /var/lib/apt/lists/*
RUN python -m pip install --upgrade pip

RUN python -m pip install -r requirements.txt



COPY flaskdir/ .

ENV FLASK_APP=flaskapp.py

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-python-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

# During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "flaskapp:app"]
