from app.models.database import engine
from sqlalchemy import text

def migrate():
    with engine.connect() as conn:
        print("Adding voted tracking columns to eligibility_records...")
        cols = [
            "has_voted BOOLEAN DEFAULT FALSE",
            "voted_at TIMESTAMP"
        ]
        for col in cols:
            try:
                conn.execute(text(f"ALTER TABLE eligibility_records ADD COLUMN {col};"))
                conn.commit()
                print(f"Added {col}")
            except Exception as e:
                print(f"Skipping {col}: {e}")

if __name__ == "__main__":
    migrate()
