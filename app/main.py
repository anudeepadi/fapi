from fastapi import FastAPI
from app.routers import items

app = FastAPI(
    title="FastAPI Application",
    description="A sample FastAPI application with automated deployment",
    version="1.0.0"
)

app.include_router(items.router)

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}