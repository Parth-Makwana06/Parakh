import sys
from fpdf import FPDF

class PDFReport(FPDF):
    def header(self):
        # Arial bold 15
        self.set_font('helvetica', 'B', 15)
        # Calculate width of title and position
        w = self.get_string_width("PROJECT REPORT: PARAKH") + 6
        self.set_x((210 - w) / 2)
        # Colors of frame, background and text
        self.set_draw_color(0, 80, 180)
        self.set_fill_color(230, 230, 250)
        self.set_text_color(0, 50, 100)
        # Thickness of frame (1 mm)
        self.set_line_width(1)
        # Title
        self.cell(w, 9, "PROJECT REPORT: PARAKH", border=1, new_x="LMARGIN", new_y="NEXT", align='C', fill=True)
        self.ln(10)

    def footer(self):
        # Position at 1.5 cm from bottom
        self.set_y(-15)
        # Arial italic 8
        self.set_font('helvetica', 'I', 8)
        # Text color in gray
        self.set_text_color(128)
        # Page number
        self.cell(0, 10, f'Page {self.page_no()}', align='C')

    def chapter_title(self, num, label):
        # Arial 12
        self.set_font('helvetica', 'B', 12)
        # Background color
        self.set_fill_color(200, 220, 255)
        # Title
        self.cell(0, 6, f'Part {num} : {label}', new_x="LMARGIN", new_y="NEXT", align='L', fill=True)
        self.ln(4)

    def chapter_body(self, body):
        # Times 12
        self.set_font('times', '', 11)
        # Output justified text
        self.multi_cell(0, 5, body)
        self.ln()

def create_report():
    pdf = PDFReport()
    pdf.add_page()
    
    # 1. Introduction
    pdf.chapter_title(1, 'Project Overview')
    body1 = (
        "Project Name: Parakh (MetrologyLens AI)\n\n"
        "Parakh is an AI-powered compliance and inspection system designed to enforce the "
        "Legal Metrology (Packaged Commodities) Rules, 2011. It allows government inspectors and auditors "
        "to scan packaged commodities using a mobile application. The system leverages OCR and advanced "
        "Large Language Models (LLMs) to extract text from product labels and automatically validate if "
        "the required mandatory declarations (like MRP, Net Quantity, Manufacturer Details, Consumer Care, "
        "and Manufacturing Date) are present and compliant.\n"
    )
    pdf.chapter_body(body1)
    
    # 2. System Architecture
    pdf.chapter_title(2, 'System Architecture & Tech Stack')
    body2 = (
        "1. Mobile Application (Frontend):\n"
        "- Framework: Flutter (Dart)\n"
        "- Key Features:\n"
        "  * Multi-image Capture & Gallery Upload.\n"
        "  * Bilingual Support (English & Hindi) powered by a custom SettingsService.\n"
        "  * Dynamic Theming (Light/Dark mode) that seamlessly adapts to the system theme.\n"
        "  * Dynamic Dashboard showing Daily Targets, Completed Inspections, and Pending tasks.\n"
        "  * Real-time Local History tracking with image and compliance violation logging.\n"
        "  * Beautiful UI with responsive Cards and color-coded compliance status (Green for Pass, Red for Fail).\n\n"
        "2. API Gateway & AI Engine (Backend):\n"
        "- Framework: Python, FastAPI\n"
        "- Key Features:\n"
        "  * Endpoints for image upload, OCR processing, and Rule Validation.\n"
        "  * Integrates with Google Gemini (or similar LLMs) for highly accurate layout extraction.\n"
        "  * Evaluates missing parameters against Legal Metrology Rules (e.g., Rule 6).\n"
        "  * Generates beautiful 'Parakh Inspection PDF' reports for formal notices.\n\n"
        "3. Web Dashboard:\n"
        "- Framework: HTML, CSS, JavaScript (served via FastAPI)\n"
        "- Purpose: Acts as a Central Monitoring Portal for higher authorities to track live compliance scores.\n"
    )
    pdf.chapter_body(body2)
    
    # 3. Core Workflows
    pdf.chapter_title(3, 'Core Workflows')
    body3 = (
        "A. The Inspection Flow:\n"
        "   1. The Field Inspector logs into the Mobile App.\n"
        "   2. Navigates to the 'Scan' tab and clicks photos of a product's label.\n"
        "   3. Clicks 'Analyze'. The images are sent to the FastAPI Backend via Multipart Upload.\n"
        "   4. The Backend extracts details (Net Qty, MRP, Phone, Email, Date) and checks for violations.\n"
        "   5. The App instantly displays a '100% COMPLIANT' or 'NON-COMPLIANCE DETECTED' card.\n"
        "   6. The scan is saved locally in the 'History' tab and updates the 'Completed Today' dashboard metric.\n\n"
        "B. Formal Legal Actions:\n"
        "   - If a product fails, the Inspector can click 'Download PDF'.\n"
        "   - The backend serves a heavily detailed official 'Show Cause Notice' / 'Inspection Report'.\n"
        "   - This PDF can be shared or printed for penal actions under the Legal Metrology Act, 2009.\n"
    )
    pdf.chapter_body(body3)

    # 4. Recent Enhancements
    pdf.chapter_title(4, 'Recent Technical Enhancements')
    body4 = (
        "- UI/UX Polishing: Solved dark mode invisible text issues by switching from hardcoded Hex values to "
        "Flutter's dynamic Theme.of(context).colorScheme.\n"
        "- Layout Fixes: Resolved UI overflow and spacing issues in the Scan Screen.\n"
        "- History Management: Built an entirely new HistoryService to store complex objects (Inspection Results + "
        "Images) locally and display them in a dedicated list view.\n"
        "- Dynamic Stats: Connected the Home Screen dashboard to actual inspection history to give a real-world "
        "feel to the Inspector's 'Pending Tasks'.\n"
        "- Branding: Integrated the official 'logo.jpg' into the top AppBar for a professional look.\n"
    )
    pdf.chapter_body(body4)
    
    # Save the pdf
    pdf_file = r"P:\Hackathon\Parakh_Project_Report.pdf"
    pdf.output(pdf_file)
    print(f"Report saved to {pdf_file}")

if __name__ == '__main__':
    create_report()
