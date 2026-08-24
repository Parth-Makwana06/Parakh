import os

def extract_text_from_image(path: str) -> dict:
    """
    Mock function for OCR Engine.
    In real implementation, this would use EasyOCR/Tesseract to extract text and bounding boxes.
    """
    return {
        "raw_text": "Sample Product Name\nNet Quantity: 500g\nMRP: Rs. 150.00\nManufactured by: ABC Corp",
        "bounding_boxes": []
    }
