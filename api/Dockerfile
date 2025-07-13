FROM python:3.11-slim

WORKDIR /app
COPY . /app

RUN pip install poetry && poetry install

CMD ["poetry", "run", "python", "-m", "app.main"]
