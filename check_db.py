import sqlite3, json

conn = sqlite3.connect('backend/inspections.db')
c = conn.cursor()
c.execute('SELECT inspection_id, timestamp, status, extracted_fields FROM inspections ORDER BY timestamp DESC')
rows = c.fetchall()
print(f'Total Records: {len(rows)}')
for r in rows:
    fields = json.loads(r[3]) if r[3] else {}
    loc = fields.get("Location", "N/A")
    print(f'  [{r[2]}] {r[1][:19]} | Location: {loc} | ID: {r[0][:8]}')
conn.close()
