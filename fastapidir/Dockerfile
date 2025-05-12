FROM python:3.10-slim
EXPOSE 8000
# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

WORKDIR /app


COPY fastapidir/requirements.txt .
# don't add python keyword or add -m with it
RUN python -m pip install  -r requirements.txt  

COPY fastapidir/ .

# Install system dependencies needed to build psycopg2
# RUN apt-get update && apt-get install -y \
   # build-essential \
   # libpq-dev \
   # && rm -rf /var/lib/apt/lists/*



CMD ["uvicorn","fastapp:app","--host", "0.0.0.0", "--port", "8000" ]