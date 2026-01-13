"""
Utility functions and helpers
"""

import hashlib
import json
from datetime import datetime
from typing import Dict, Any


def generate_hash(data: Dict[str, Any]) -> str:
    """Generate SHA-256 hash of data"""
    data_str = json.dumps(data, sort_keys=True)
    return hashlib.sha256(data_str.encode()).hexdigest()


def format_timestamp(dt: datetime = None) -> str:
    """Format datetime to ISO string"""
    if dt is None:
        dt = datetime.utcnow()
    return dt.isoformat()


def validate_uuid(uuid_string: str) -> bool:
    """Validate UUID format"""
    import uuid
    try:
        uuid.UUID(uuid_string)
        return True
    except (ValueError, AttributeError):
        return False
