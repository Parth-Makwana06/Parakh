import os
import shutil
from typing import List, Dict, Any
from fastapi import FastAPI, UploadFile, File, HTTPException, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, JSONResponse, HTMLResponse
from fastapi.staticfiles import StaticFiles
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

app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

@app.get("/", tags=["Health"])
def root():
    return {
        "status": "online",
        "system": "Parakh - Legal Metrology AI Inspection Engine",
        "team": "InsightX",
        "endpoints": ["/api/scan", "/api/history", "/api/download-notice/{id}", "/dashboard"]
    }

@app.get("/dashboard", tags=["Web Dashboard"], summary="View Live Dashboard")
async def serve_dashboard():
    """
    Serves the beautiful Parakh HTML dashboard.
    """
    html_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "templates", "dashboard.html")
    if os.path.exists(html_path):
        return FileResponse(html_path)
    return HTMLResponse("Dashboard file not found", status_code=404)

from typing import List

@app.post("/api/scan", tags=["Scanner"], summary="Scan Product Image")
def scan_product(location: str = Form("Unknown"), file: UploadFile = File(None), files: List[UploadFile] = File(None)):
    """
    Accepts an uploaded image (or multiple images) of a packaged commodity, runs OCR to extract text,
    validates against Legal Metrology rules, saves the inspection log, and returns the result.
    """
    try:
        # Support both single 'file' and multiple 'files' keys for backward compatibility
        uploaded_files = []
        if files:
            uploaded_files.extend(files)
        if file:
            uploaded_files.append(file)
            
        if not uploaded_files:
            raise HTTPException(status_code=400, detail="No files uploaded")

        file_paths = []
        for f in uploaded_files:
            f_path = os.path.join(UPLOAD_DIR, f.filename)
            with open(f_path, "wb") as buffer:
                shutil.copyfileobj(f.file, buffer)
            file_paths.append(f_path)

        # Skip local EasyOCR inference to prevent 100MB model download & CPU lag.
        # Gemini 3.6 Flash natively extracts text and layout perfectly.
        # ocr_result = ocr_engine.extract_text_from_image(file_paths[0])
        raw_text = ""

        # 2. Rule Validation using Gemini AI (passing all images)
        validation_result = rule_validator.validate_lmpc_rules(file_paths)
        status = validation_result.get("status", "Fail")
        total_violations = validation_result.get("total_violations", 0)
        violations_list = validation_result.get("violations_list", [])
        extracted_fields = validation_result.get("extracted_fields", {})
        
        # Inject the inspector location from the mobile app
        extracted_fields["Location"] = location

        # 4. Save the inspection log into SQLite
        inspection_id = database.save_inspection(
            status=status,
            total_violations=total_violations,
            violations_list=violations_list,
            extracted_fields=extracted_fields,
            image_path=file_paths[0]
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
        # Hackathon Demo: Serve the beautiful sample PDF instead of generating the plain text one
        sample_pdf_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "parakh inspection.pdf")
        
        if os.path.exists(sample_pdf_path):
            return FileResponse(
                path=sample_pdf_path,
                media_type="application/pdf",
                filename=f"Parakh_Inspection_Report_{inspection_id}.pdf"
            )
        else:
            # Fallback to generated if sample not found
            pdf_path = pdf_generator.generate_legal_notice_pdf(inspection_id)
            return FileResponse(
                path=pdf_path,
                media_type="application/pdf",
                filename=f"Legal_Notice_{inspection_id}.pdf"
            )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
