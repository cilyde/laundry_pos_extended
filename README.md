
## 📱 Laundry POS Extended

A modern point-of-sale system built with **Flutter**, tailored for laundry shops. Supports **Sunmi V2/V2s/V2 Pro printers**, **QR-based order management**, multilingual UI (English, Arabic, Hindi & Urdu), and integrates tightly with **Firebase Firestore** for real-time data sync and cloud operations. Extended version includes the ability track the status of each order.

### ✨ Features

* ✅ Order creation with multiple services (wash, iron, both)
* 🧺 Itemized clothes selection per service
* 🧾 Auto-printing on Sunmi V2/V2s with QR code for order tracking
* 📦 Order status tracking (active/completed)
* 📅 Daily transaction reports and summaries
* 🌐 Web dashboard for supervisors (View orders, filter by customer/date)
* 📲 Multilingual support (English, Hindi, Arabic, Urdu)
* 📤 Export to Excel/PDF (sales and historical orders)
* ⚙️ Minimal maintenance barcode/QR scanning

---

## 🚀 Getting Started

### Prerequisites

* Flutter (>=3.10)
* Dart (>=3.0)
* Firebase CLI (`firebase login`)
* Sunmi device with printer (V2 or V2s)

### 1. Clone the repo

```bash
git clone https://github.com/cilyde/laundry_pos_extended.git
cd laundry_pos_extended
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Firebase setup

Ensure you've configured Firebase using:

```bash
flutterfire configure
```

and added the `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS) in appropriate locations.

---

## 📁 Folder Structure

```
lib/
├── main.dart
├── models/           # Data models (Order, Payment, etc.)
├── services/         # Firebase, Printer, Scanner, etc.
├── viewmodels/       # MVVM ViewModels
├── views/            # UI Screens (POS, Dashboard, etc.)
├── web/              # Web dashboard logic (MVVM split)
└── utils/            # Helpers like translations, date logic
```

---

## 🧪 Testing

To run the app locally on a Sunmi device:

```bash
flutter run --release
```

To run the web dashboard:

```bash
flutter run -d chrome -t lib/web/main_web.dart
```

---

## 🛠️ Tech Stack

* **Flutter** (MVVM architecture)
* **Firebase Firestore**
* **Sunmi Printer SDK (`sunmi_printer_plus`)**
* **Google Sheets / Excel export**
* **Cupertino-style UI**

---

## 📦 Deployment Notes

* Sunmi printers use thermal paper: excessive blank lines reduce printer lifespan.
* Orders are stored under `/vOrders/{yyyy-MM-dd}/orders/{orderId}`
* Customers stored in `/vCustomers/{customer_code}`
* Web dashboard should be hosted separately from mobile builds

---

## ✅ To Do

* [ ] Role-based access for supervisor vs staff
* [ ] Notification system for ready orders
* [ ] Integrate with WhatsApp for order confirmation

---
