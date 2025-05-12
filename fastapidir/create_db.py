from sqlmodel import create_engine, SQLModel, Session

postgres_url = "postgresql://petbell:i12pose@localhost:5432/order_db"
engine = create_engine(postgres_url, echo=True)

def create_db_and_tables():
    SQLModel.metadata.create_all(engine)
    
create_db_and_tables()
