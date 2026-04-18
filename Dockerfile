FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app/ ./app/
COPY static/ ./static/
COPY templates/ ./templates/
COPY config.json .
ARG COMMIT_SHA=unknown
RUN echo ${COMMIT_SHA} > .commit_hash
EXPOSE 8181
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8181"]