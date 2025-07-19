
## 📱 Laundry POS Extended

This is the **Cilyde Laundry POS (Extended)** system — a streamlined and smart point-of-sale and laundry order tracking solution designed for use in laundromats.

Built with **Flutter** and integrated with **Firebase**, this version goes beyond simple order entry. It enables full **order lifecycle management** with support for **QR-based scan-out, printer integration**, and **customer tracking** using unique auto-generated codes.

---

## 📱 Ideal Workflow

To maximize efficiency, the system is designed to be used across two devices:

- A **Sunmi V2 devices** (or any Android device with a built-in printer but would need code tweaks) for **order placement and receipt printing**.
- A **mobile phone or tablet** for **scanning and completing** customer orders.

### 🧺 Walkthrough:

1. **Customer drops off clothes**:
   - Staff opens the app on the Sunmi device.
   - Selects laundry service and clothing types.
   - Order is placed, and a **receipt is printed** (QR included).
   - QR sticker is attached to the clothes.

2. **Customer comes to pick up**:
   - Staff uses the mobile app to **scan the QR** on the clothes.
   - The order is automatically marked **complete**, and dashboard counts are updated.

---

## 🔍 Key Features

- **Active Order Tracking**: Easily view and filter pending, completed, or scanned orders.
- **Firebase Integration**: Realtime syncing of orders and customer history.
- **QR Workflow**: Simplifies order management during pickup.
- **Customer Code System**: Customers are assigned unique, easy-to-recall codes like `JO-78` based on name and phone for internal reference.
- **Daily & Monthly Reports**: Easily access summaries and analytics per date or customer.
- **Multi-Language Support**: English, Arabic, Urdu and Hindi are supported natively.

---

## 💡 How Customer Codes Work

When a new customer places an order:
- If **John Doe** has the number `12345678`, his code becomes `JO-78`.
- If **Jonathan** has `098765478`, his code becomes `JO-478`.

This approach ensures quick referencing and avoids repetition while allowing customers with similar names to still get unique codes.

---

## 📁 Project Structure

```

lib/
├── models/
├── services/
├── viewmodels/
├── views/
├── utils/
└── web/                # Web-specific version of the app (MVVM separated)

```

---

## 🛠 Technologies Used

- Flutter 3+
- Firebase Firestore
- Sunmi printer integration (via `sunmi_printer_plus`)
- GetX (or Provider) for state management
- Excel & PDF export packages
- AnimatedList for smooth UI

---

## 🔗 Contribution

This system is currently under active internal development. Contributions may be considered in the future.

---

## 🧼 Why “Extended”?

This version introduces **live order status tracking** and **scan-based completion**, elevating it beyond a basic POS app but also changing the whole database architecture. It’s optimized for teams handling both front-desk and back-end laundry workflows — increasing accountability, reducing errors, and boosting speed.

---

