FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем исходный код
COPY app/ ./app/
COPY static/ ./static/
COPY templates/ ./templates/

ARG COMMIT_SHA=manual-test
ENV DEPLOY_REF=$COMMIT_SHA

EXPOSE 8181

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8181"]