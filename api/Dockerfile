FROM python:3.11-slim

WORKDIR /app
COPY . /app

RUN pip install poetry && poetry install --no-dev

CMD ["poetry", "run", "python", "main.py"]
