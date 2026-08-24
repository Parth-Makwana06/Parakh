import os
import shutil
import json
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse

from database import init_db, save_inspection, get_all_inspections
from ocr_engine import extract_text_from_image
from rule_validator import validate_lmpc_rules
from pdf_generator import generate_legal_notice_pdf

app = FastAPI(
    title="Parakh - LMPC 2011 AI Inspection API",
    description="Backend API for Legal Metrology (Packaged Commodities) Rules, 2011 Automated Inspection System",
    version="1.0.0"
)

# Enable CORS for Flutter Mobile App, Web, and Emulators
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOAD_DIR = os.path.join(os.path.dirname(__file__), "uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)
init_db()

@app.get("/")
def root():
    return {
        "status": "online",
        "system": "Parakh - Legal Metrology AI Inspection Engine",
        "team": "InsightX",
        "endpoints": ["/api/scan", "/api/history", "/api/download-notice/{id}"]
    }

@app.post("/api/scan")
async def scan_product(file: UploadFile = File(...)):
    try:
        # 1. Save uploaded image from Flutter app
        file_location = os.path.join(UPLOAD_DIR, file.filename)
        with open(file_location, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        # 2. Run OCR Extraction
        ocr_result = extract_text_from_image(file_location)
        
        # 3. Validate against LMPC 2011 Rules
        compliance_result = validate_lmpc_rules(ocr_result["raw_text"])
        
        # 4. Save to Database
        record_id = save_inspection(
            product_name=compliance_result["extracted_fields"].get("product_name", "Packaged Commodity"),
            brand=compliance_result["extracted_fields"].get("brand", "Standard Brand"),
            mrp=compliance_result["extracted_fields"].get("mrp", "N/A"),
            net_qty=compliance_result["extracted_fields"].get("net_qty", "N/A"),
            mfg_date=compliance_result["extracted_fields"].get("mfg_date", "N/A"),
            status=compliance_result["status"],
            count=compliance_result["total_violations"],
            violations_json=json.dumps(compliance_result["violations"]),
            extracted_json=json.dumps(compliance_result["extracted_fields"]),
            image_path=file_location
        )
        
        compliance_result["inspection_id"] = record_id
        compliance_result["image_path"] = file_location
        compliance_result["ocr_text"] = ocr_result["raw_text"]
        return compliance_result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Scan failed: {str(e)}")

@app.get("/api/history")
def fetch_history():
    rows = get_all_inspections()
    history = []
    for r in rows:
        history.append({
            "id": r[0],
            "product_name": r[1],
            "brand": r[2],
            "mrp": r[3],
            "net_qty": r[4],
            "mfg_date": r[5],
            "status": r[6],
            "violations_count": r[7],
            "violations": json.loads(r[8]) if r[8] else [],
            "extracted_fields": json.loads(r[9]) if r[9] else {},
            "image_path": r[10],
            "timestamp": r[11]
        })
    return {"inspections": history, "total": len(history)}

@app.get("/api/download-notice/{inspection_id}")
def download_pdf(inspection_id: int):
    pdf_path = generate_legal_notice_pdf(inspection_id)
    if os.path.exists(pdf_path):
        return FileResponse(pdf_path, media_type='application/pdf', filename=f"Legal_Notice_{inspection_id}.pdf")
    raise HTTPException(status_code=404, detail="Inspection Notice PDF not found")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
