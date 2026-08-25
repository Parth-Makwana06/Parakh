import sqlite3
import uuid
import json
from datetime import datetime
from typing import List, Dict, Any

DB_NAME = "inspections.db"

def _get_connection():
    conn = sqlite3.connect(DB_NAME)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = _get_connection()
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS inspections (
            inspection_id TEXT PRIMARY KEY,
            timestamp TEXT,
            status TEXT,
            total_violations INTEGER,
            violations_list TEXT,
            extracted_fields TEXT,
            image_path TEXT
        )
    ''')
    conn.commit()
    conn.close()

# Initialize DB on import
init_db()

def save_inspection(status: str, total_violations: int, violations_list: List[str], extracted_fields: Dict[str, Any], image_path: str) -> str:
    inspection_id = str(uuid.uuid4())
    timestamp = datetime.now().isoformat()
    
    conn = _get_connection()
    cursor = conn.cursor()
    cursor.execute('''
        INSERT INTO inspections (inspection_id, timestamp, status, total_violations, violations_list, extracted_fields, image_path)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ''', (
        inspection_id,
        timestamp,
        status,
        total_violations,
        json.dumps(violations_list),
        json.dumps(extracted_fields),
        image_path
    ))
    conn.commit()
    conn.close()
    return inspection_id

def get_all_inspections() -> List[Dict[str, Any]]:
    conn = _get_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM inspections ORDER BY timestamp DESC')
    rows = cursor.fetchall()
    conn.close()
    
    inspections = []
    for row in rows:
        inspections.append({
            "inspection_id": row["inspection_id"],
            "timestamp": row["timestamp"],
            "status": row["status"],
            "total_violations": row["total_violations"],
            "violations_list": json.loads(row["violations_list"]) if row["violations_list"] else [],
            "extracted_fields": json.loads(row["extracted_fields"]) if row["extracted_fields"] else {},
            "image_path": row["image_path"]
        })
    return inspections

def get_inspection(inspection_id: str) -> Dict[str, Any]:
    conn = _get_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM inspections WHERE inspection_id = ?', (inspection_id,))
    row = cursor.fetchone()
    conn.close()
    if row:
        return {
            "inspection_id": row["inspection_id"],
            "timestamp": row["timestamp"],
            "status": row["status"],
            "total_violations": row["total_violations"],
            "violations_list": json.loads(row["violations_list"]) if row["violations_list"] else [],
            "extracted_fields": json.loads(row["extracted_fields"]) if row["extracted_fields"] else {},
            "image_path": row["image_path"]
        }
    return None
