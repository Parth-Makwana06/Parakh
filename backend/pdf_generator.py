import os
import datetime
from fpdf import FPDF
import database

class ParakhPDF(FPDF):
    def header(self):
        self.set_font('helvetica', 'B', 24)
        self.set_text_color(0, 150, 180) # Cyan-like
        self.cell(0, 10, "PARAKH", border=0, new_x="LMARGIN", new_y="NEXT", align='L')
        self.set_font('helvetica', 'B', 12)
        self.set_text_color(100, 100, 100)
        self.cell(0, 6, "National Legal Metrology Monitoring Portal", border=0, new_x="LMARGIN", new_y="NEXT", align='L')
        self.cell(0, 6, "Official Inspection Report", border=0, new_x="LMARGIN", new_y="NEXT", align='L')
        self.ln(5)
        # Line
        self.set_draw_color(0, 150, 180)
        self.set_line_width(1)
        self.line(10, self.get_y(), 200, self.get_y())
        self.ln(10)

    def footer(self):
        self.set_y(-15)
        self.set_font('helvetica', 'I', 8)
        self.set_text_color(128)
        self.cell(0, 10, f'Page {self.page_no()}', align='R')

def generate_legal_notice_pdf(inspection_id: str) -> str:
    notices_dir = "notices"
    os.makedirs(notices_dir, exist_ok=True)
    pdf_path = os.path.join(notices_dir, f"notice_{inspection_id}.pdf")
    
    # Get data from DB
    data = database.get_inspection(inspection_id)
    if not data:
        # Fallback empty data if ID not found somehow
        data = {
            "status": "FAIL",
            "total_violations": 1,
            "timestamp": datetime.datetime.now().isoformat(),
            "extracted_fields": {},
            "violations_list": [{"rule": "LMPC", "description": "Unknown"}],
            "image_path": None
        }

    pdf = ParakhPDF()
    pdf.add_page()
    
    # STATUS BOX
    pdf.set_font('helvetica', 'B', 14)
    if data['status'].lower() in ['pass', 'compliant']:
        pdf.set_text_color(0, 150, 0)
        status_text = "COMPLIANT (PASS)"
    else:
        pdf.set_text_color(200, 0, 0)
        status_text = "VIOLATION DETECTED (FAIL)"
        
    pdf.cell(0, 10, "INSPECTION STATUS:", align='R')
    pdf.ln(8)
    pdf.cell(0, 10, status_text, align='R')
    pdf.ln(15)
    
    # Summary Table
    pdf.set_font('helvetica', 'B', 12)
    pdf.set_text_color(0, 0, 0)
    pdf.cell(0, 10, "INSPECTION SUMMARY", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font('helvetica', '', 11)
    
    pdf.set_fill_color(245, 245, 245)
    pdf.cell(90, 8, f"INSPECTION ID: {inspection_id[:8]}...", border=1, fill=True)
    pdf.cell(5, 8, "", border=0)
    pdf.cell(95, 8, f"DATE: {data['timestamp'][:10]}", border=1, fill=True, new_x="LMARGIN", new_y="NEXT")
    pdf.ln(2)
    
    loc = data['extracted_fields'].get('Location', 'Unknown')
    pdf.cell(90, 8, f"LOCATION: {loc}", border=1, fill=True)
    pdf.cell(5, 8, "", border=0)
    score = 100 - (data['total_violations'] * 15)
    score = max(0, score)
    pdf.cell(95, 8, f"COMPLIANCE SCORE: {score}/100", border=1, fill=True, new_x="LMARGIN", new_y="NEXT")
    pdf.ln(10)
    
    # Product Details
    pdf.set_font('helvetica', 'B', 12)
    pdf.cell(0, 10, "PRODUCT DETAILS", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font('helvetica', '', 11)
    
    fields = data['extracted_fields']
    mrp = fields.get('mrp', 'Missing')
    net_qty = fields.get('net_qty', 'Missing')
    mfg_date = fields.get('mfg_date', 'Missing')
    mfg_dec = 'Present' if fields.get('mfg_declaration') else 'Missing'
    
    pdf.cell(90, 8, f"DECLARED MRP: {mrp}", border=1)
    pdf.cell(5, 8, "", border=0)
    pdf.cell(95, 8, f"NET QUANTITY: {net_qty}", border=1, new_x="LMARGIN", new_y="NEXT")
    pdf.ln(2)
    pdf.cell(90, 8, f"MFG DATE: {mfg_date}", border=1)
    pdf.cell(5, 8, "", border=0)
    pdf.cell(95, 8, f"MFG DETAILS: {mfg_dec}", border=1, new_x="LMARGIN", new_y="NEXT")
    pdf.ln(15)

    # Scanned Evidence
    if data['image_path'] and os.path.exists(data['image_path']):
        pdf.set_font('helvetica', 'B', 12)
        pdf.cell(0, 10, "SCANNED EVIDENCE", new_x="LMARGIN", new_y="NEXT")
        try:
            # Add image, width 150
            pdf.image(data['image_path'], w=150)
            pdf.ln(5)
        except Exception as e:
            pdf.set_font('helvetica', 'I', 10)
            pdf.cell(0, 10, f"[Could not load image: {e}]", new_x="LMARGIN", new_y="NEXT")
            
    pdf.add_page()
    # Violations List
    pdf.set_font('helvetica', 'B', 12)
    pdf.cell(0, 10, "IDENTIFIED VIOLATIONS", new_x="LMARGIN", new_y="NEXT")
    
    violations = data['violations_list']
    if not violations:
        pdf.set_font('helvetica', '', 11)
        pdf.set_text_color(0, 150, 0)
        pdf.cell(0, 10, "No violations detected. Product is fully compliant.", new_x="LMARGIN", new_y="NEXT")
    else:
        pdf.set_text_color(200, 0, 0)
        pdf.set_font('helvetica', '', 11)
        for i, v in enumerate(violations):
            rule = v.get('rule', 'Rule') if isinstance(v, dict) else 'Rule'
            desc = v.get('description', v) if isinstance(v, dict) else v
            pdf.multi_cell(0, 6, f"{i+1}. {rule}: {desc}")
            pdf.ln(2)
            
    pdf.ln(15)
    pdf.set_font('helvetica', 'I', 9)
    pdf.set_text_color(100, 100, 100)
    pdf.cell(0, 5, f"Generated securely by Parakh AI System on {datetime.datetime.now().strftime('%d/%m/%Y, %H:%M:%S')}", align='C', new_x="LMARGIN", new_y="NEXT")
    pdf.cell(0, 5, "This is a digitally generated document intended for Legal Metrology enforcement workflows.", align='C')

    pdf.output(pdf_path)
    return pdf_path
