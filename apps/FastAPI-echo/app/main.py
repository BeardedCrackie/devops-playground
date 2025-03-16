from fastapi import FastAPI, Request

app = FastAPI()

@app.get("/{path:path}")
async def echo(request: Request, path: str):
    return {
        "method": request.method,
        "path": f"/{path}",
        "headers": dict(request.headers),
        "query_params": dict(request.query_params),
    }
