import re

def extract_entities(text: str):
    entities = {}
    
    # 1. Net Quantity (e.g. 500 g, 1 kg, 500 gm, 200ml, 1 Litre)
    qty_match = re.search(r'(\d+(\.\d+)?)\s*(g|kg|ml|l|gm|gms|Kgs|Litre|gram|grams|N)\b', text, re.IGNORECASE)
    entities["net_qty"] = qty_match.group(0) if qty_match else None

    # 2. MRP (e.g. MRP Rs. 50, ₹ 120.00, Rs 99, MRP: 250)
    mrp_match = re.search(r'(MRP|M\.R\.P\.|Rs\.?|₹|INR)\s*[:.]?\s*(\d+(\.\d{2})?)', text, re.IGNORECASE)
    entities["mrp"] = mrp_match.group(0) if mrp_match else None

    # 3. Manufacturing / Packing Date (e.g. 08/2026, Aug 2026, 08-2026)
    date_match = re.search(r'(\d{2}[\/\-]\d{4})|((Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s*\d{4})', text, re.IGNORECASE)
    entities["mfg_date"] = date_match.group(0) if date_match else None

    # 4. Consumer Care Email / Phone
    phone_match = re.search(r'(\b1800[-\s]?\d{3}[-\s]?\d{3,4}\b|\b0\d{2,4}[-\s]?\d{6,8}\b|\b\d{10}\b)', text)
    email_match = re.search(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', text)
    entities["consumer_phone"] = phone_match.group(0) if phone_match else None
    entities["consumer_email"] = email_match.group(0) if email_match else None

    # 5. Manufacturer / Packer Address
    mfg_kw = re.search(r'(Mfg by|Manufactured by|Packed by|Marketed by|Pkd by|Mfd by|Producer)', text, re.IGNORECASE)
    entities["mfg_declaration"] = bool(mfg_kw)

    # 6. Generic Product Name / Brand
    brand_match = re.search(r'(Amul|Tata|Nestle|Britannia|Parle|ITC|Patanjali|Haldiram|Dabur|Cadbury)', text, re.IGNORECASE)
    entities["brand"] = brand_match.group(0) if brand_match else "Standard Commodity"
    entities["product_name"] = "Packaged Consumer Goods"

    return entities

def validate_lmpc_rules(raw_text: str):
    entities = extract_entities(raw_text)
    violations = []
    
    # -------------------------------------------------------------
    # RULE 11: Standard Units of Measurement
    # -------------------------------------------------------------
    if entities["net_qty"]:
        qty_str = entities["net_qty"].lower()
        if any(bad_unit in qty_str for bad_unit in ["gm", "gms", "kgs", "gram", "grams"]):
            violations.append({
                "rule": "Rule 11 (Standard Units of Weight & Measure)",
                "severity": "HIGH",
                "description": f"Non-standard unit symbol '{entities['net_qty']}' detected. Mandatory legal SI symbol is 'g' or 'kg' as per Schedule II."
            })
    else:
        violations.append({
            "rule": "Rule 6(1)(c) (Net Quantity Declaration)",
            "severity": "CRITICAL",
            "description": "Net Quantity declaration is completely missing on Principal Display Panel."
        })

    # -------------------------------------------------------------
    # RULE 6(1)(e): Maximum Retail Price (MRP) & Tax Inclusivity
    # -------------------------------------------------------------
    if entities["mrp"]:
        tax_included = bool(re.search(r'(incl|inclusive|tax|taxes)', raw_text, re.IGNORECASE))
        if not tax_included:
            violations.append({
                "rule": "Rule 6(1)(e) (Maximum Retail Price Declaration)",
                "severity": "HIGH",
                "description": "MRP declared without mandatory 'inclusive of all taxes' or 'incl. of all taxes' statement."
            })
    else:
        violations.append({
            "rule": "Rule 6(1)(e) (Maximum Retail Price Declaration)",
            "severity": "CRITICAL",
            "description": "Maximum Retail Price (MRP) declaration is missing on the package."
        })

    # -------------------------------------------------------------
    # RULE 6(1)(d): Month & Year of Manufacture / Packing
    # -------------------------------------------------------------
    if not entities["mfg_date"]:
        violations.append({
            "rule": "Rule 6(1)(d) (Date of Manufacture/Packing)",
            "severity": "MEDIUM",
            "description": "Month and Year of manufacture/packing/import is missing."
        })

    # -------------------------------------------------------------
    # RULE 6(1)(n): Consumer Care Helpline
    # -------------------------------------------------------------
    if not entities["consumer_phone"] and not entities["consumer_email"]:
        violations.append({
            "rule": "Rule 6(1)(n) (Consumer Care Details)",
            "severity": "MEDIUM",
            "description": "Mandatory Consumer Care contact details (Helpline Phone No. or Email Address) are missing."
        })

    # -------------------------------------------------------------
    # RULE 6(1)(a): Manufacturer / Packer Complete Address
    # -------------------------------------------------------------
    if not entities["mfg_declaration"]:
        violations.append({
            "rule": "Rule 6(1)(a) (Manufacturer/Packer Details)",
            "severity": "HIGH",
            "description": "Manufacturer or Packer Name & complete address declaration is missing."
        })

    status = "COMPLIANT" if len(violations) == 0 else "NON_COMPLIANT"
    
    return {
        "status": status,
        "total_violations": len(violations),
        "violations": violations,
        "extracted_fields": entities
    }
