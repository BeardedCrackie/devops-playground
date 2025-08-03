import os
from typing import Union
from prometheus_fastapi_instrumentator import Instrumentator
import pika
import motor.motor_asyncio
from bson import ObjectId
from typing import Optional, List
from bson import ObjectId
from pydantic import BaseModel
import time
from fastapi.middleware.cors import CORSMiddleware
from celery import Celery
from celery_worker import log_task_created  # import task
from fastapi import BackgroundTasks
from fastapi import FastAPI, WebSocket, HTTPException

app = FastAPI(root_path="/api")
active_connections = []

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8081", "http://127.0.0.1:8081"],  # Add both origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize and instrument Prometheus metrics
Instrumentator().instrument(app).expose(app)


# MongoDB connection
MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017")  # fallback for local dev
client = motor.motor_asyncio.AsyncIOMotorClient(MONGO_URI)
db = client["sandbox"]
collection = db["items"]


# RabbitMQ setup
RABBITMQ_HOST = os.getenv("RABBITMQ_HOST", "localhost")
RABBITMQ_PORT = int(os.getenv("RABBITMQ_PORT", 5672))
RABBITMQ_USER = os.getenv("RABBITMQ_USER", "guest")
RABBITMQ_PASS = os.getenv("RABBITMQ_PASS", "guest")
RABBITMQ_URI = f'amqp://{RABBITMQ_USER}:{RABBITMQ_PASS}@{RABBITMQ_HOST}:{RABBITMQ_PORT}//'

credentials = pika.PlainCredentials(RABBITMQ_USER, RABBITMQ_PASS)
parameters = pika.ConnectionParameters(
    host=RABBITMQ_HOST,
    port=RABBITMQ_PORT,
    credentials=credentials
)


@app.on_event("startup")
def wait_for_rabbitmq():
    max_retries = 10
    for attempt in range(max_retries):
        try:
            connection = pika.BlockingConnection(pika.ConnectionParameters(
                host=os.getenv("RABBITMQ_HOST", "localhost"),
                port=int(os.getenv("RABBITMQ_PORT", 5672)),
                credentials=pika.PlainCredentials(
                    os.getenv("RABBITMQ_USER", "guest"),
                    os.getenv("RABBITMQ_PASS", "guest")
                )
            ))
            channel = connection.channel()
            channel.queue_declare(queue='hello', durable=True)
            connection.close()
            print("✅ RabbitMQ is ready")
            return
        except Exception as e:
            print(f"⏳ Waiting for RabbitMQ... ({attempt+1}/{max_retries})")
            time.sleep(3)
    raise RuntimeError("❌ RabbitMQ not available after retries")


celery_app = Celery("worker", broker=RABBITMQ_URI)

@celery_app.task
def log_task_created(title: str):
    time.sleep(2)  # simulate slow job
    print(f"✅ Celery: New task created: {title}")

# Models
class TaskCreate(BaseModel):
    title: str
    description: Optional[str] = None
    done: bool = False

class Task(TaskCreate):
    id: str

def task_helper(task) -> dict:
    return {
        "id": str(task["_id"]),
        "title": task.get("title", "[No title]"),
        "description": task.get("description", ""),
        "done": task.get("done", False)
    }

# Routes


@app.get("/consume/")
def read_mq():
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()
    method_frame, header_frame, body = channel.basic_get(queue='hello', auto_ack=True)
    if method_frame:
        return {"status": "success", "message": body.decode()}
    else:
        return {"status": "empty", "message": "No message in queue"}
    connection.close()


@app.get("/tasks/", response_model=List[Task])
async def list_tasks():
    tasks = []
    async for task in collection.find():
        tasks.append(task_helper(task))
    return tasks

@app.get("/tasks/{task_id}", response_model=Task)
async def get_task(task_id: str):
    task = await collection.find_one({"_id": ObjectId(task_id)})
    if task:
        return task_helper(task)
    raise HTTPException(status_code=404, detail="Task not found")

    
async def broadcast_new_task(title: str):
    for ws in active_connections:
        try:
            print(f"Sending notification to WS: {title}")
            await ws.send_text(f"Task created: {title}")
        except Exception as e:
            print("WebSocket failed:", e)


@app.post("/tasks/", response_model=Task)
async def create_task(task: TaskCreate):
    result = await collection.insert_one(task.dict())
    new_task = await collection.find_one({"_id": result.inserted_id})
    # notify via WebSocket
    await broadcast_new_task(task.title)
    return task_helper(new_task)


@app.put("/tasks/{task_id}", response_model=Task)
async def update_task(task_id: str, task: TaskCreate):
    result = await collection.update_one(
        {"_id": ObjectId(task_id)},
        {"$set": task.dict()}
    )
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="Task not found")
    updated_task = await collection.find_one({"_id": ObjectId(task_id)})
    return task_helper(updated_task)

@app.delete("/tasks/{task_id}")
async def delete_task(task_id: str):
    result = await collection.delete_one({"_id": ObjectId(task_id)})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Task not found")
    return {"detail": "Task deleted"}



@app.websocket("/ws/notifications")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    active_connections.append(websocket)
    try:
        while True:
            await websocket.receive_text()  # keep connection alive
    except WebSocketDisconnect:
        active_connections.remove(websocket)
