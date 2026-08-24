# ⚖️ MetrologyLens AI (NiyamScan) — LMPC 2011 Automated Compliance System

> **Smart India Hackathon 2026** | **Problem Statement ID: 26034**  
> **Ministry:** Ministry of Consumer Affairs, Food & Public Distribution (Department of Consumer Affairs - DoCA)  
> **Team:** InsightX  
> **Mobile App Lead:** Parth  

---

## 📌 Problem Statement Overview
Packaged commodities sold across India in retail and e-commerce platforms are legally required to bear mandatory declarations under the **Legal Metrology Act, 2009** and the **Legal Metrology (Packaged Commodities) Rules, 2011**. 

Manual inspection by enforcement agencies is slow and error-prone. **MetrologyLens AI (NiyamScan)** is an AI-powered inspection suite capable of scanning product packaging labels, extracting declarations via Multilingual OCR & Computer Vision, and automatically validating them against Legal Metrology Rules, 2011 in under 5 seconds.

---

## 🚀 Key Features

* 📸 **Smart Multi-Angle Scanning:** Capture labels via Flutter mobile application using camera or gallery upload.
* 👁️ **Multilingual OCR & Layout Extraction:** Extracts text across English, Hindi & Indian regional scripts with bounding-box segmentation.
* ⚖️ **LMPC 2011 Automated Rule Engine:**
  - **Rule 11:** Flags illegal non-standard unit symbols (e.g. 100 gm instead of legal standard 100 g).
  - **Rule 6(1)(e):** Verifies MRP format and mandatory "inclusive of all taxes" declaration.
  - **Rule 6(1)(d):** Validates Month & Year of manufacture / packing.
  - **Rule 6(1)(n):** Ensures consumer grievance contact numbers and emails are present.
  - **Rule 6(1)(a):** Checks completeness of manufacturer / packer name and address.
* 📄 **Court-Admissible PDF Notices:** 1-tap generation of official digital inspection notices with timestamp and violation details.
* 📊 **DoCA Central Web Portal:** Real-time nationwide compliance monitoring, analytics charts, and violation heatmaps.

---

## 🏗️ System Architecture

`
[ 📱 Mobile App (Flutter) / 🌐 Web Portal ]
                    │
                    ▼
[ ⚡ FastAPI API Gateway (POST /api/scan) ]
                    │
                    ▼
[ 👁️ OpenCV Preprocessing + PaddleOCR / EasyOCR Engine ]
                    │
                    ▼
[ ⚖️ LMPC 2011 Rule Validator (Python Engine) ]
                    │
                    ▼
[ 📄 ReportLab PDF Notice + 🗄️ SQLite / PostgreSQL Audit Logs ]
`

---

## 📁 Repository Structure

`
P:\Hackathon\
├── mobile_app/                                    # 📱 Parth's Flutter Mobile Application
│   ├── lib/
│   │   ├── main.dart                              # App Entry Point & Theme
│   │   ├── models/inspection_model.dart           # LMPC Response Data Model
│   │   ├── services/api_service.dart              # Multipart API Service
│   │   └── screens/scan_screen.dart               # Camera Scanner UI & Results
│   ├── android/ (Permissions & Cleartext added)
│   ├── pubspec.yaml (http, image_picker, url_launcher)
│   └── ...
├── SIH2026_PS26034_InsightX_Presentation.pptx     # 🏆 Team InsightX Official PPT
├── SIH2026-IDEA-Presentation-Format.pdf           # Original SIH PDF Template
├── .gitignore                                     # Clean Git Ignore Rules
└── README.md                                      # Documentation
`

---

## 📱 How to Run the Flutter Mobile App (Parth)

### 1. Prerequisites:
- Flutter SDK (3.x or higher)
- Android Studio / VS Code with Flutter extension
- Android physical device (with USB debugging ON) or Emulator

### 2. Run Commands:
`ash
# Navigate to mobile app directory
cd mobile_app

# Fetch dependencies
flutter pub get

# Run on connected device
flutter run
`

---

## 👥 Team InsightX — Roles & Responsibilities

| Member | Role | Module | Tech Stack |
|---|---|---|---|
| **Parth** | Mobile App Lead | Field Inspector Mobile App | Flutter, Dart, CameraX, url_launcher |
| **Darshil** | API Gateway Lead | REST APIs & Route Validation | FastAPI, Uvicorn, Python, CORS |
| **Sneh** | Backend Engine Lead | OCR Pipeline, Rules & DB | OpenCV, EasyOCR, SQLite, ReportLab |
| **Sujal** | Web Dashboard Lead | DoCA Central Analytics Portal | HTML5, Tailwind CSS, Chart.js, JS |
| **Member 5** | AI / QA Testing Lead | Edge Case Tuning & OCR Testing | Python, Regex, Image Datasets |
| **Member 6** | Legal & Pitch Lead | SIH Presentation & Legal Research | Legal Metrology Act 2009, PPT |

---

## 📜 License & Compliance
Developed for **Smart India Hackathon 2026** under the **Legal Metrology (Packaged Commodities) Rules, 2011**, Ministry of Consumer Affairs, Government of India.
