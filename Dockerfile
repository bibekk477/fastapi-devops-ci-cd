FROM python:3.12-slim AS base

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app

# Run tests inside container
RUN pytest app/tests --maxfail=1 --disable-warnings -q

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]