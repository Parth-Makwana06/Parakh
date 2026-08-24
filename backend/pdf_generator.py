import os
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from reportlab.lib import colors
import datetime

def generate_legal_notice_pdf(inspection_id: str) -> str:
    notices_dir = "notices"
    os.makedirs(notices_dir, exist_ok=True)
    
    pdf_path = os.path.join(notices_dir, f"notice_{inspection_id}.pdf")
    
    # Generate REAL PDF
    c = canvas.Canvas(pdf_path, pagesize=letter)
    c.setFont("Helvetica-Bold", 16)
    c.drawString(50, 750, "GOVERNMENT OF INDIA")
    c.setFont("Helvetica-Bold", 14)
    c.drawString(50, 730, "DEPARTMENT OF LEGAL METROLOGY")
    
    c.setFont("Helvetica-Bold", 12)
    c.setFillColor(colors.red)
    c.drawString(50, 700, "NOTICE OF NON-COMPLIANCE (LMPC RULES, 2011)")
    
    c.setFillColor(colors.black)
    c.setFont("Helvetica", 11)
    
    text = [
        f"Date: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M')}",
        f"Inspection Reference ID: {inspection_id}",
        "",
        "To,",
        "The Manufacturer / Packer / Importer",
        "",
        "Subject: Show Cause Notice for violation of the Legal Metrology (Packaged",
        "Commodities) Rules, 2011.",
        "",
        "Sir/Madam,",
        "During an inspection, it was found that the packaged commodity scanned under",
        f"Reference ID {inspection_id} does not comply with the mandatory declarations required",
        "under Rule 6 of the Legal Metrology (Packaged Commodities) Rules, 2011.",
        "",
        "You are hereby directed to submit your explanation within 15 days of this notice.",
        "Failure to respond may lead to penal action under the Legal Metrology Act, 2009.",
        "",
        "Sincerely,",
        "Field Inspector",
        "MetrologyLens AI System"
    ]
    
    y = 660
    for line in text:
        c.drawString(50, y, line)
        y -= 18
        
    c.save()
    
    return pdf_path
