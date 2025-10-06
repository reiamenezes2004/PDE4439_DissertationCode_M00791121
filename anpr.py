# all the imports required for the anpr system
import os
import cv2
import pytesseract
import re
import numpy as np
import firebase_admin
from firebase_admin import credentials, db

# firebase setup
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
KEY_PATH = os.path.join(BASE_DIR, "serviceAccountKey.json")

cred = credentials.Certificate(KEY_PATH)
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://ocp-charge-default-rtdb.firebaseio.com/'
})

BOOKINGS_PATH = "/bookings"

def get_latest_booking_plate():
    bookings = db.reference(BOOKINGS_PATH).get()
    if bookings:
        latest_key = sorted(bookings.keys())[-1]
        return bookings[latest_key].get("plate", "").upper()
    return None

# tesseract path
pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"

# detecting and warping (straightening) the plate region from the paper
def get_inner_plate(frame):

    # preprocessing
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    blur = cv2.GaussianBlur(gray, (5, 5), 0)
    edges = cv2.Canny(blur, 100, 200)

    # finds contours
    contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if not contours:
        return None, frame, None

    # chooses the largest contour
    c = max(contours, key=cv2.contourArea)

    peri = cv2.arcLength(c, True)
    approx = cv2.approxPolyDP(c, 0.02 * peri, True)

    if len(approx) == 4:

        # perspective transform
        pts = approx.reshape(4, 2)
        rect = np.zeros((4, 2), dtype="float32")

        s = pts.sum(axis=1)
        rect[0] = pts[np.argmin(s)]  # top-left
        rect[2] = pts[np.argmax(s)]  # bottom-right

        diff = np.diff(pts, axis=1)
        rect[1] = pts[np.argmin(diff)]  # top-right
        rect[3] = pts[np.argmax(diff)]  # bottom-left

        (tl, tr, br, bl) = rect
        widthA = np.linalg.norm(br - bl)
        widthB = np.linalg.norm(tr - tl)
        heightA = np.linalg.norm(tr - br)
        heightB = np.linalg.norm(tl - bl)
        maxWidth = max(int(widthA), int(widthB))
        maxHeight = max(int(heightA), int(heightB))

        # perspective correction

        dst = np.array([
            [0, 0],
            [maxWidth - 1, 0],
            [maxWidth - 1, maxHeight - 1],
            [0, maxHeight - 1]], dtype="float32")

        M = cv2.getPerspectiveTransform(rect, dst)
        warp = cv2.warpPerspective(frame, M, (maxWidth, maxHeight))

        # crop from 10% width; so it keeps both the letter and the digits - keeps the inner plate
        h, w = warp.shape[:2]
        cropped = warp[0:h, int(w*0.10):w]

        # green bounding box around the frame
        pts = pts.astype(int)
        cv2.polylines(frame, [pts], True, (0, 255, 0), 3)

        return cropped, warp, frame
    else:
        return None, None, frame


# ocr using tesseract
def read_plate_chars(plate_img):

    gray = cv2.cvtColor(plate_img, cv2.COLOR_BGR2GRAY)
    gray = cv2.resize(gray, None, fx=2, fy=2, interpolation=cv2.INTER_CUBIC) # upscale it by 2x, improved the accuracy
    _, thresh = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU) # Otsu's adaptive threshold - pure black and white image

    config = r'--oem 3 --psm 8 -c tessedit_char_whitelist=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789' # neural network + legacy (3), image single word, good for short plates (8)
    text = pytesseract.image_to_string(thresh, config=config) # extracts text using OCR
    text = re.sub(r'[^A-Z0-9]', '', text.upper()) # look only A-Z and 0-9 for better speed and accuracy
    return text

# main anpr system
def anpr_system():
    registered_plate = get_latest_booking_plate() # gets the latest plate from firebas booking
    if not registered_plate:
        print("❌ No booking found in Firebase.") # emoji used to differentiate while debugging
        return

    registered_plate = re.sub(r'[^A-Z0-9]', '', registered_plate.upper())
    print("Booking Plate:", registered_plate)

    cap = cv2.VideoCapture(0) # starts laptop webcam (0)
    stable_count = 0
    last_detected = ""

    while True:
        ret, frame = cap.read() # read frames
        if not ret:
            break

        plate_img, warped, debug_frame = get_inner_plate(frame)
        detected_plate = ""
        if plate_img is not None:
            detected_plate = read_plate_chars(plate_img)

        if detected_plate:
            print("Detected:", detected_plate)

            if detected_plate == last_detected:
                stable_count += 1
            else:
                stable_count = 1
                last_detected = detected_plate

            if stable_count >= 1 and detected_plate == registered_plate:
                print("✅ Access Granted")
                cv2.putText(debug_frame, "ACCESS GRANTED", (20, 80),
                            cv2.FONT_HERSHEY_SIMPLEX, 1.2, (0, 255, 0), 3, cv2.LINE_AA)
                cv2.imshow("ANPR Camera", debug_frame)
                cv2.waitKey(2000)
                break
            else:
                cv2.putText(debug_frame, "ACCESS DENIED", (20, 80),
                            cv2.FONT_HERSHEY_SIMPLEX, 1.2, (0, 0, 255), 3, cv2.LINE_AA)

        cv2.imshow("ANPR Camera", debug_frame)

        if cv2.waitKey(1) & 0xFF == ord('q'): # q to exit 
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    anpr_system()
