# ⚖️ Parakh — AI-Powered Legal Metrology (LMPC 2011) Inspection System

> **Smart India Hackathon 2026** | **Problem Statement ID: 26034**  
> **Ministry:** Ministry of Consumer Affairs, Food & Public Distribution (Department of Consumer Affairs - DoCA)  
> **Team:** InsightX  
> **Mobile App Lead:** Parth  

---

## 📌 Problem Statement
Packaged commodities sold across India in retail and e-commerce platforms must comply with mandatory declarations under the **Legal Metrology Act, 2009** and the **Legal Metrology (Packaged Commodities) Rules, 2011**. 

**Parakh** is an end-to-end AI-powered inspection suite designed for field enforcement officers and DoCA headquarters. It scans product labels, extracts declarations via Multilingual OCR, and automatically executes LMPC 2011 rule compliance audits in < 5 seconds.

---

## 🚀 System Architecture & End-to-End Flow

`
[ 📱 Flutter Mobile App (Parth) ]
                │
                │  POST /api/scan (Multipart Image)
                ▼
[ ⚡ FastAPI Backend Engine (Darshil & Sneh) ]
                │
        ┌───────┴───────────────────────────────┐
        ▼                                       ▼
 [ 👁️ OCR Text Extraction ]            [ ⚖️ LMPC 2011 Rule Validator ]
 (English/Hindi/Regional)             • Rule 11 (Standard Units 'g'/'kg')
                                      • Rule 6(1)(e) (MRP & All Taxes)
                                      • Rule 6(1)(d) (Mfg/Packing Date)
                                      • Rule 6(1)(n) (Consumer Care)
                                      • Rule 6(1)(a) (Mfg Complete Address)
        │                                       │
        └───────┬───────────────────────────────┘
                ▼
[ 📄 ReportLab PDF Notice Generator + 🗄️ SQLite Audit DB ]
                │
                │  JSON Response (Status, Violations, Extracted Fields)
                ▼
[ 📱 Instant Result Display & 1-Tap PDF Download in App ]
`

---

## 📁 Repository Structure

`
Parakh/
├── backend/                                       # ⚡ FastAPI Backend Engine
│   ├── main.py                                    # REST API Gateway (/api/scan, /api/history)
│   ├── database.py                                # SQLite DB manager (inspections.db)
│   ├── ocr_engine.py                              # Multilingual OCR text extraction
│   ├── rule_validator.py                          # LMPC 2011 Legal Rule Engine
│   ├── pdf_generator.py                           # Automated Legal PDF Notice Generator
│   └── requirements.txt                           # Backend dependencies
│
├── mobile_app/                                    # 📱 Flutter Field Inspector Mobile App
│   ├── lib/
│   │   ├── main.dart                              # App Entry & Legal Metrology Theme
│   │   ├── models/inspection_model.dart           # Type-Safe JSON Response Parser
│   │   ├── services/api_service.dart              # Multi-part Backend API Client
│   │   └── screens/scan_screen.dart               # Camera Scanner UI & Results
│   ├── android/ (Permissions & Cleartext added)
│   └── pubspec.yaml (http, image_picker, url_launcher)
│
├── SIH2026_PS26034_InsightX_Presentation.pptx     # 🏆 Team InsightX Official Presentation
├── SIH2026-IDEA-Presentation-Format.pdf           # Original SIH PDF Template
├── .gitignore                                     # Clean Git Ignore Config
└── README.md                                      # Project Documentation
`

---

## ⚡ How to Run & Connect the Entire System

### Step 1: Start the Backend Server (FastAPI)
`ash
# Navigate to backend directory
cd backend

# Install dependencies
pip install -r requirements.txt

# Start FastAPI server (runs on port 8000)
python main.py
`
> **Backend will be live at:** http://localhost:8000 (API Docs: http://localhost:8000/docs)

---

### Step 2: Configure & Run Flutter Mobile App (Parth)
1. In [mobile_app/lib/services/api_service.dart](mobile_app/lib/services/api_service.dart), verify the aseUrl:
   * **Android Emulator:** http://10.0.2.2:8000 (Default)
   * **Physical Android Phone:** http://<Laptop_WiFi_IP>:8000 (e.g. http://192.168.1.5:8000)
   * **Windows/Web:** http://localhost:8000

2. Run the App:
`ash
cd mobile_app
flutter pub get
flutter run
`

---

## 👥 Team InsightX

| Member | Role | Key Contribution |
|---|---|---|
| **Parth** | Flutter Mobile App Lead | Field Inspector Mobile Application UI & API Integration |
| **Darshil** | API Gateway Lead | FastAPI REST Endpoints, Multipart Handlers & CORS |
| **Sneh** | Backend Engine Lead | LMPC 2011 Rules Engine, OCR & PDF Notice Generator |
| **Sujal** | Web Dashboard Lead | DoCA Central Analytics & Monitoring Portal |
| **Members 5 & 6** | QA & Pitch Leads | SIH Pitch Presentation & Edge Case Label Datasets |
