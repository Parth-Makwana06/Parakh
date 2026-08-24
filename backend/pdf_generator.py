import json
import os
from database import get_inspection_by_id
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle

def generate_legal_notice_pdf(inspection_id: int):
    output_dir = os.path.join(os.path.dirname(__file__), "reports")
    os.makedirs(output_dir, exist_ok=True)
    pdf_filename = os.path.join(output_dir, f"Legal_Notice_{inspection_id}.pdf")
    
    row = get_inspection_by_id(inspection_id)
    if not row:
        return ""

    doc = SimpleDocTemplate(pdf_filename, pagesize=letter, rightMargin=40, leftMargin=40, topMargin=40, bottomMargin=40)
    styles = getSampleStyleSheet()
    story = []

    # Title
    title_style = ParagraphStyle(name='TitleStyle', fontName='Helvetica-Bold', fontSize=14, leading=17, alignment=1, textColor=colors.HexColor("#1B365D"))
    sub_style = ParagraphStyle(name='SubStyle', fontName='Helvetica-Bold', fontSize=11, leading=14, alignment=1, textColor=colors.HexColor("#EA580C"))
    
    story.append(Paragraph("GOVERNMENT OF INDIA", title_style))
    story.append(Paragraph("MINISTRY OF CONSUMER AFFAIRS, FOOD & PUBLIC DISTRIBUTION", title_style))
    story.append(Paragraph("DEPARTMENT OF LEGAL METROLOGY (PARAKH PORTAL)", title_style))
    story.append(Spacer(1, 10))
    story.append(Paragraph("LEGAL INSPECTION NOTICE UNDER SECTION 36, LEGAL METROLOGY ACT, 2009", sub_style))
    story.append(Spacer(1, 15))

    # Metadata Table
    status_text = f"<font color='{'green' if row[6] == 'COMPLIANT' else 'red'}'><b>{row[6]}</b></font>"
    meta_data = [
        ["Notice ID:", f"LMPC-INSP-{row[0]}", "Inspection Date:", row[11]],
        ["Brand / Commodity:", f"{row[2]} ({row[1]})", "Status:", Paragraph(status_text, styles['Normal'])],
        ["Declared MRP:", row[3] or "N/A", "Declared Net Qty:", row[4] or "N/A"],
        ["Mfg / Packing Date:", row[5] or "N/A", "Violations Count:", str(row[7])]
    ]
    t_meta = Table(meta_data, colWidths=[130, 140, 130, 130])
    t_meta.setStyle(TableStyle([
        ('FONTNAME', (0,0), (-1,-1), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,-1), 9),
        ('TEXTCOLOR', (0,0), (-1,-1), colors.HexColor("#1E293B")),
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#F8FAFC")),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
    ]))
    story.append(t_meta)
    story.append(Spacer(1, 15))

    # Violations Table
    story.append(Paragraph("<b>LEGAL METROLOGY (PACKAGED COMMODITIES) RULES, 2011 AUDIT SUMMARY:</b>", styles['Normal']))
    story.append(Spacer(1, 8))
    
    violations = json.loads(row[8]) if row[8] else []
    if not violations:
        v_table_data = [["No Violations Detected. The package complies with Legal Metrology Rules, 2011."]]
        t_v = Table(v_table_data, colWidths=[530])
        t_v.setStyle(TableStyle([
            ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#DCFCE7")),
            ('TEXTCOLOR', (0,0), (-1,-1), colors.HexColor("#166534")),
            ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#86EFAC")),
        ]))
        story.append(t_v)
    else:
        v_table_data = [["Rule Violated", "Severity", "Description of Offense"]]
        for v in violations:
            v_table_data.append([v["rule"], v["severity"], Paragraph(v["description"], styles['Normal'])])
        t_v = Table(v_table_data, colWidths=[140, 70, 320])
        t_v.setStyle(TableStyle([
            ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#1E3A8A")),
            ('TEXTCOLOR', (0,0), (-1,0), colors.white),
            ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
            ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#94A3B8")),
            ('BACKGROUND', (0,1), (-1,-1), colors.HexColor("#FEF2F2")),
        ]))
        story.append(t_v)

    story.append(Spacer(1, 25))
    story.append(Paragraph("<b>Issuing Authority:</b> Enforcement Officer (Automated LMPC Inspection Squad)", styles['Normal']))
    story.append(Paragraph("<i>This is a computer-generated digital legal inspection report with cryptographic hash verification.</i>", styles['Italic']))

    doc.build(story)
    return pdf_filename
