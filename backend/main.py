import os
import shutil
from typing import List, Dict, Any
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, JSONResponse
import uvicorn

# Import core modules
import ocr_engine
import rule_validator
import database
import pdf_generator

app = FastAPI(
    title="MetrologyLens AI API Gateway",
    description="Central API Gateway for Legal Metrology compliance verification system.",
    version="1.0.0"
)

# Enable CORS for all origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Ensure upload directory exists
UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@app.get("/", tags=["Health"])
def root():
    return {
        "status": "online",
        "system": "Parakh - Legal Metrology AI Inspection Engine",
        "team": "InsightX",
        "endpoints": ["/api/scan", "/api/history", "/api/download-notice/{id}"]
    }

@app.post("/api/scan", tags=["Scanner"], summary="Scan Product Image")
async def scan_product(file: UploadFile = File(...)):
    """
    Accepts an uploaded image of a packaged commodity, runs OCR to extract text,
    validates against Legal Metrology rules, saves the inspection log, and returns the result.
    """
    try:
        # 1. Save uploaded image to local 'uploads/' directory
        file_path = os.path.join(UPLOAD_DIR, file.filename)
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        # 2. Extract raw text and bounding boxes using OCR engine
        ocr_result = ocr_engine.extract_text_from_image(file_path)
        raw_text = ocr_result.get("raw_text", "")

        # 3. Validate rules to determine Pass/Fail and violations
        validation_result = rule_validator.validate_lmpc_rules(raw_text)
        status = validation_result.get("status", "Fail")
        total_violations = validation_result.get("total_violations", 0)
        violations_list = validation_result.get("violations_list", [])
        extracted_fields = validation_result.get("extracted_fields", {})

        # 4. Save the inspection log into SQLite
        inspection_id = database.save_inspection(
            status=status,
            total_violations=total_violations,
            violations_list=violations_list,
            extracted_fields=extracted_fields,
            image_path=file_path
        )

        # 5. Return structured JSON response
        return JSONResponse(content={
            "inspection_id": inspection_id,
            "status": status,
            "total_violations": total_violations,
            "violations_list": violations_list,
            "extracted_fields": extracted_fields
        })

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/history", tags=["History"], summary="Get Inspection History")
async def get_history():
    """
    Retrieves all past inspection records for the Web Dashboard.
    """
    try:
        inspections = database.get_all_inspections()
        return inspections
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/download-notice/{inspection_id}", tags=["Notices"], summary="Download Legal Notice PDF")
async def download_notice(inspection_id: str):
    """
    Generates and returns a downloadable legal notice PDF for a given inspection ID.
    """
    try:
        pdf_path = pdf_generator.generate_legal_notice_pdf(inspection_id)
        if not os.path.exists(pdf_path):
            raise HTTPException(status_code=404, detail="Notice could not be generated or found.")
        
        return FileResponse(
            path=pdf_path,
            media_type="application/pdf",
            filename=f"Legal_Notice_{inspection_id}.pdf"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
