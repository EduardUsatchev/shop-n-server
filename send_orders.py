import requests
import time
import random
import uuid

# כתובת ה-API שלך (כדאי להחליף לכתובת נכונה)
API_URL = "http://192.168.49.2:30080/orders"

# פונקציה לשליחת בקשת POST חדשה
def send_order():
    order_id = str(uuid.uuid4())
    items = ["coffee", "tea", "sandwich", "cookie"]
    item = random.choice(items)
    payload = {
        "id": order_id,
        "item": item
    }
    try:
        response = requests.post(API_URL, json=payload)
        print(f"Sent order {order_id} for {item}: status {response.status_code}")
    except Exception as e:
        print(f"Error sending order: {e}")

# ריצה אינסופית עם השהייה של כמה שניות בין בקשות
if __name__ == "__main__":
    while True:
        send_order()
        time.sleep(random.uniform(1, 5))  # שינה בין 1 ל-5 שניות
