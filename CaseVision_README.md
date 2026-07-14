<p align="center">
  <img src="./assets/casevision-logo.png" width="180" />
</p>

<h1 align="center">CaseVision</h1>
<p align="center"><b>AI-Powered Legal Research Assistant for Pakistani Law</b></p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white" />
  <img src="https://img.shields.io/badge/Google_Gemini-8E75B2?style=for-the-badge&logo=googlegemini&logoColor=white" />
</p>

---

## ⚖️ About

**CaseVision** is an AI-powered legal research platform built to help users navigate Pakistani law. It combines document intelligence, OCR, and large language models to analyze legal documents like FIRs, extract meaning, predict relevant laws, and explain findings in plain Urdu — making legal information more accessible.

---

## ✨ Features

- 📄 **FIR Upload Pipeline** — Upload FIRs and legal documents directly from the mobile app
- 🔍 **AI-Powered Case Analysis** — Google Gemini (`gemini-2.5-flash`) generates structured analysis including:
  - Case summary
  - Predicted applicable laws
  - Plain-language Urdu explanation
  - Related case references
- 🖼️ **OCR Support** — Extracts text from text-based PDFs, scanned PDFs, and images, supporting both **English and Urdu**
- 🔐 **Secure Authentication** — Firebase Authentication for user management
- ☁️ **Cloud Data Sync** — Firestore for real-time data, MySQL for structured storage
- 📱 **Cross-Platform Mobile App** — Built with Flutter for a smooth native experience
- 🧠 **Retrieval-Augmented Search** — LangChain + ChromaDB power semantic search over legal documents and case law

---

## 🏗️ Tech Stack

| Layer | Technology |
|---|---|
| **Mobile App** | Flutter (Dart) |
| **Backend API** | FastAPI (Python) |
| **Database** | MySQL, Firestore |
| **Authentication** | Firebase Auth |
| **AI/LLM** | Google Gemini (`gemini-2.5-flash`) |
| **OCR** | pytesseract, pdf2image |
| **Retrieval / RAG** | LangChain, ChromaDB |

---

## 📂 Project Structure

```
CaseVision/
├── mobile/              # Flutter mobile application
│   ├── lib/
│   ├── android/
│   └── pubspec.yaml
├── backend/             # FastAPI backend
│   ├── app/
│   │   ├── routes/
│   │   ├── services/
│   │   └── models/
│   └── requirements.txt
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK
- Python 3.10+
- MySQL Server
- Firebase project (with Auth + Firestore enabled)
- Google Gemini API key

### Backend Setup
```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### Mobile App Setup
```bash
cd mobile
flutter pub get
flutter run
```

### Environment Variables
Create a `.env` file in the backend directory with:
```
GEMINI_API_KEY=your_api_key_here
MYSQL_HOST=localhost
MYSQL_USER=your_user
MYSQL_PASSWORD=your_password
FIREBASE_CREDENTIALS_PATH=path/to/firebase-credentials.json
```

---

## 🖼️ How It Works

1. User uploads an FIR or legal document (PDF/image) from the mobile app
2. Backend runs OCR to extract text (supports scanned documents in English & Urdu)
3. Extracted text is sent to Google Gemini for structured analysis
4. LangChain + ChromaDB retrieve related case law for context
5. Results (summary, predicted laws, Urdu explanation, related cases) are returned to the app in structured JSON

---

## 📱 App Package

`com.muzamil.casevision`

---

## 👤 Author

**Muzamil Zaman**
[Portfolio](https://muzamilzamann.github.io) · [LinkedIn](https://www.linkedin.com/in/muzamil-zaman-53789a285/) · [GitHub](https://github.com/muzamilzamann)

---

<p align="center"><i>Final Year Project — Making Pakistani legal research accessible through AI.</i></p>
