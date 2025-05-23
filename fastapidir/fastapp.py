
from typing import Annotated
from fastapi import FastAPI, Depends, HTTPException, Query
from sqlmodel import create_engine, SQLModel, Session, select, Field
# from create_db import create_db_and_tables


class Orders(SQLModel, table=True):
    id: int| None = Field(default=None, primary_key=True)
    product_id: str = Field(index=True)
    quantity: int = Field(default=1)
    
postgres_url = "postgresql://petbell:i12pose@order_db:5432/order_db"
engine = create_engine(postgres_url, echo=True)

def create_db_and_tables():
    SQLModel.metadata.create_all(engine)

    
def get_session():
    engine = create_engine(postgres_url)
    with Session(engine) as session:
        yield session
        
sessionDep = Annotated[Session, Depends(get_session)]
create_db_and_tables()

app = FastAPI()


    
@app.get("/")
def index():
    return {"message": "Welcome to the Orders API!"}

@app.get("/orders", response_model=list[Orders])
def get_orders(
    session: sessionDep,
    product_id: str | None = Query(default=None, title="Product ID", description="Filter by Product ID")
):
    query = select(Orders)
    if product_id:
        query = query.where(Orders.product_id == product_id)
        
    orders = session.exec(query).all()
    return orders

@app.get("/orders/{order_id}", response_model=Orders)
async def get_one_order(order_id: int, session: sessionDep):
    order = session.get(Orders, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return order

@app.post("/orders", response_model=Orders)
def create_order(order: Orders, session: sessionDep):
    session.add(order)
    session.commit()
    session.refresh(order)
    return order


