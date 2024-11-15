from fastapi import APIRouter, HTTPException
from app.models import Item

router = APIRouter(
    prefix="/items",
    tags=["items"]
)

items_db = {}

@router.post("/")
def create_item(item: Item):
    items_db[len(items_db)] = item
    return item

@router.get("/")
def read_items():
    return list(items_db.values())

@router.get("/{item_id}")
def read_item(item_id: int):
    if item_id not in items_db:
        raise HTTPException(status_code=404, detail="Item not found")
    return items_db[item_id]