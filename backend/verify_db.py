from app.models.database import engine, Base
from app.models.auth_models import RevokedToken
from sqlalchemy import inspect

inspector = inspect(engine)
if "revoked_tokens" in inspector.get_table_names():
    print("TABLE_EXISTS: revoked_tokens")
else:
    print("TABLE_MISSING: revoked_tokens")
    # Try to create it if missing (sometimes uvicorn auto-init fails)
    try:
        Base.metadata.create_all(bind=engine)
        print("Created tables successfully")
    except Exception as e:
        print(f"Error creating tables: {e}")
