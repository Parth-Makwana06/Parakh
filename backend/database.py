import sqlite3
import os
from datetime import datetime

DB_PATH = os.path.join(os.path.dirname(__file__), "inspections.db")

def init_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS inspections (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_name TEXT,
            brand TEXT,
            mrp TEXT,
            net_qty TEXT,
            mfg_date TEXT,
            status TEXT,
            violations_count INTEGER,
            violations_json TEXT,
            extracted_json TEXT,
            image_path TEXT,
            timestamp TEXT
        )
    ''')
    conn.commit()
    conn.close()

def save_inspection(product_name, brand, mrp, net_qty, mfg_date, status, count, violations_json, extracted_json, image_path):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    cursor.execute('''
        INSERT INTO inspections (product_name, brand, mrp, net_qty, mfg_date, status, violations_count, violations_json, extracted_json, image_path, timestamp)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', (product_name, brand, mrp, net_qty, mfg_date, status, count, violations_json, extracted_json, image_path, now))
    conn.commit()
    inserted_id = cursor.lastrowid
    conn.close()
    return inserted_id

def get_all_inspections():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM inspections ORDER BY id DESC")
    rows = cursor.fetchall()
    conn.close()
    return rows

def get_inspection_by_id(inspection_id: int):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM inspections WHERE id = ?", (inspection_id,))
    row = cursor.fetchone()
    conn.close()
    return row
