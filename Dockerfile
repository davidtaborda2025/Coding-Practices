FROM python:3.9-slim

RUN apt-get update && apt-get install -y \
    r-base \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages(c('ggplot2', 'DBI', 'RPostgres', 'scales'), repos='https://cloud.r-project.org/')"

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN chmod -R 777 Python/Python/static

CMD ["python", "Python/Python/application.py"]