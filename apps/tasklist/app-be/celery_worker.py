from celery import Celery
import os
import time

RABBITMQ_HOST = os.getenv("RABBITMQ_HOST", "rabbitmq")
RABBITMQ_USER = os.getenv("RABBITMQ_USER", "admin")
RABBITMQ_PASS = os.getenv("RABBITMQ_PASS", "secret")
RABBITMQ_URI = f'amqp://{RABBITMQ_USER}:{RABBITMQ_PASS}@{RABBITMQ_HOST}:5672//'

celery_app = Celery("worker", broker=RABBITMQ_URI)

@celery_app.task(name="app.log_task_created")  # 👈 match exactly
def log_task_created(title: str):
    print(f"[CELERY] New task: {title}")

