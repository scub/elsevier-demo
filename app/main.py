# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "fastapi[standard]>=0.162.0",
# ]
# ///
from fastapi import FastAPI
from fastapi.responses import HTMLResponse
import os

app = FastAPI()

@app.get("/")
async def read_root():
    SECRETSMANAGER_KEY = os.getenv('SECRETSMANAGER_KEY', 'unavailable') 

    html_content = f"""
    <html>
        <head>
            <title>Demo App</title>
        </head>
        <body>
            <h1>Hello, World!</h1>
            <p>Secrets Manager secret: {SECRETSMANAGER_KEY}</p>
        </body>
    </html>
    """
    return HTMLResponse(content=html_content, status_code=200)

@app.get("/items/{item_id}")
def read_item(item_id: int, q: str | None = None):
    return {"item_id": item_id, "q": q}