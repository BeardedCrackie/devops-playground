# Tasklist App Overview

Welcome to the **Tasklist** app! This application is a **sample demonstration** created using Vibe Coding principles. 

## Purpose of the App

This application serves as a demonstration of a full-stack implementation using FastAPI, MongoDB, RabbitMQ, Celery, and WebSockets.

## Technologies Used

- **FastAPI**: For building RESTful API endpoints.
- **MongoDB**: NoSQL database for task storage.
- **RabbitMQ**: Message broker for managing communication between services.
- **Celery**: Distributed task queue for asynchronous background tasks.
- **Pydantic**: Data validation and serialization using models.
- **CORS Middleware**: Enable cross-origin requests during development.

## Docker Setup Instructions

To run this application seamlessly with Docker, follow the steps below:

1. **Create a `.env` file** in your project root with the following content:
   ```env
   RABBITMQ_USER=guest
   RABBITMQ_PASS=guest
   ```

2. **Docker Compose Configuration**:
   The `docker-compose.yml` file is already configured with the necessary services.

3. **Building and Starting Services**:
   Run the following command from your terminal at the project root where `docker-compose.yml` is located:
   ```bash
   docker-compose up --build
   ```

4. **Access the Application**:
   - **Backend API**: Open your browser and go to `http://localhost:8000/docs` to access the interactive API documentation.
   - **Frontend Application**: Access it at `http://localhost:8080`.
   - **RabbitMQ Management Interface**: Visit `http://localhost:15672` and log in with the credentials defined in your `.env` file.

## Example Usage

### Creating a Task
```json
POST /tasks/
{
    "title": "New Task",
    "description": "This is a test task."
}
```

### Retrieving All Tasks
```http
GET /tasks/
```

### Updating a Task
```json
PUT /tasks/{task_id}
{
    "title": "Updated Task",
    "description": "Updated description here.",
    "done": true
}
```

### Deleting a Task
```http
DELETE /tasks/{task_id}
```
