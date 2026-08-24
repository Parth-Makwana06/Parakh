import os
import cv2
import easyocr
import numpy as np

# Initialize the EasyOCR Reader once (singleton pattern)
_reader = None

def get_reader():
    global _reader
    if _reader is None:
        # Load English and Hindi models
        _reader = easyocr.Reader(['en', 'hi'], gpu=False)
    return _reader

def enhance_image_for_ocr(image_path: str):
    """
    Uses OpenCV CLAHE (Contrast Limited Adaptive Histogram Equalization)
    to remove plastic packaging glare and enhance text visibility.
    """
    img = cv2.imread(image_path)
    if img is None:
        return None
        
    # Convert to grayscale
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    # Apply CLAHE
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    enhanced = clahe.apply(gray)
    
    # Denoise
    denoised = cv2.fastNlMeansDenoising(enhanced, None, 10, 7, 21)
    return denoised

def extract_text_from_image(path: str) -> dict:
    """
    Uses OpenCV for enhancement and EasyOCR to extract text and bounding boxes.
    """
    try:
        # 1. Enhance the image to remove glare
        enhanced_img = enhance_image_for_ocr(path)
        
        # 2. Extract text using EasyOCR
        reader = get_reader()
        
        # If enhancement failed for some reason, use original path
        image_input = enhanced_img if enhanced_img is not None else path
        
        results = reader.readtext(image_input)
        
        raw_text_parts = []
        bounding_boxes = []
        
        for (bbox, text, prob) in results:
            raw_text_parts.append(text)
            # bbox is a list of 4 points: [top-left, top-right, bottom-right, bottom-left]
            # Convert to standard format [x, y, w, h] or just save the polygon
            # Convert float/int64 to standard python int for JSON serialization
            poly = [[int(pt[0]), int(pt[1])] for pt in bbox]
            bounding_boxes.append({
                "text": text,
                "confidence": float(prob),
                "polygon": poly
            })
            
        return {
            "raw_text": " ".join(raw_text_parts),
            "bounding_boxes": bounding_boxes
        }
    except Exception as e:
        print(f"OCR Error: {e}")
        return {
            "raw_text": "",
            "bounding_boxes": []
        }
