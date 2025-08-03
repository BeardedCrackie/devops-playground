const API_BASE = window.ENV.API_URL;
const WS_BASE = window.ENV.WS_URL;

const form = document.getElementById("task-form");
const titleInput = document.getElementById("title");
const descInput = document.getElementById("description");
const taskList = document.getElementById("task-list");


const ws = new WebSocket(`${WS_BASE}/ws/notifications`);

document.addEventListener("DOMContentLoaded", () => {
  if ("Notification" in window && Notification.permission !== "granted") {
    Notification.requestPermission().then((permission) => {
      console.log("Notification permission:", permission);
    });
  }
});




ws.onopen = () => {
  console.log("WebSocket connection opened");
};

ws.onmessage = (event) => {
  console.log("WebSocket message received:", event.data);

  if (Notification.permission === "granted") {
    new Notification("🔔 New Task", { body: event.data });
  } else {
    alert(event.data);  // fallback for denied/missing permission
  }
};


ws.onerror = (e) => {
  console.error("WebSocket error", e);
};

form.addEventListener("submit", async (e) => {
  e.preventDefault();
  const task = {
    title: titleInput.value,
    description: descInput.value,
    done: false
  };
  await fetch(`${API_BASE}/tasks/`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(task)
  });
  titleInput.value = "";
  descInput.value = "";
  await loadTasks();
});

async function deleteTask(taskId) {
  await fetch(`${API_BASE}/tasks/${taskId}`, { method: "DELETE" });
  await loadTasks();
}

async function loadTasks() {
  taskList.innerHTML = "";
  const res = await fetch(`${API_BASE}/tasks/`);
  const tasks = await res.json();
  tasks.forEach(task => {
    const li = document.createElement("li");
    li.className = "list-group-item d-flex justify-content-between align-items-center";
    li.innerHTML = `
      <span>
        <strong>${task.title}</strong><br/>
        <small>${task.description || ""}</small>
      </span>
      <button class="btn btn-sm btn-danger">Delete</button>
    `;
    li.querySelector("button").addEventListener("click", () => deleteTask(task.id));
    taskList.appendChild(li);
  });
}

loadTasks();
