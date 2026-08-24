def validate_lmpc_rules(raw_text: str) -> dict:
    """
    Mock function for Rule Validator.
    In a real implementation, this would use NLP or regex to check for LMPC rule compliance.
    """
    return {
        "status": "Fail",
        "total_violations": 1,
        "violations_list": [
            "Missing consumer care details."
        ],
        "extracted_fields": {
            "MRP": "Rs. 150.00",
            "Net_Quantity": "500g",
            "Manufacturer": "ABC Corp"
        }
    }
