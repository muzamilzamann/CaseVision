import json
import os
import shutil
import uuid

from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.fir import FIR
from app.schemas.fir import FIRResponse
from app.core.firebase import get_current_firebase_user
from app.services.ocr_service import extract_text_from_file
from app.services.gemini_service import analyze_fir_text

router = APIRouter()

UPLOAD_DIR = "uploads"
ALLOWED_EXTENSIONS = {".pdf", ".jpg", ".jpeg", ".png", ".txt"}


@router.post("/upload", response_model=FIRResponse)
def upload_fir(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_firebase_user),
):
    ext = os.path.splitext(file.filename)[1].lower()
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(status_code=400, detail="Unsupported file type")

    os.makedirs(UPLOAD_DIR, exist_ok=True)
    unique_name = f"{uuid.uuid4().hex}{ext}"
    file_path = os.path.join(UPLOAD_DIR, unique_name)

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # Create the FIR record immediately with "processing" status.
    fir = FIR(
        user_uid=current_user["uid"],
        user_email=current_user.get("email", ""),
        file_name=file.filename,
        file_path=file_path,
        status="processing",
    )
    db.add(fir)
    db.commit()
    db.refresh(fir)

    try:
        extracted_text = extract_text_from_file(file_path)
        if not extracted_text.strip():
            raise ValueError("No text could be extracted from the document.")

        analysis = analyze_fir_text(extracted_text)

        fir.summary = analysis["summary"]
        fir.predicted_laws = json.dumps(analysis["predicted_laws"])
        fir.urdu_explanation = json.dumps(analysis["urdu_explanation"])
        fir.related_cases = json.dumps(analysis["related_cases"])
        fir.status = "completed"

    except Exception as e:
        fir.status = "failed"
        fir.summary = f"Analysis failed: {str(e)}"
        fir.predicted_laws = json.dumps([])
        fir.urdu_explanation = json.dumps([])
        fir.related_cases = json.dumps([])

    db.commit()
    db.refresh(fir)

    return FIRResponse(
        id=fir.id,
        file_name=fir.file_name,
        status=fir.status,
        summary=fir.summary,
        predicted_laws=json.loads(fir.predicted_laws) if fir.predicted_laws else None,
        urdu_explanation=json.loads(fir.urdu_explanation) if fir.urdu_explanation else None,
        related_cases=json.loads(fir.related_cases) if fir.related_cases else None,
        created_at=fir.created_at,
    )


@router.get("/list", response_model=list[FIRResponse])
def list_firs(
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_firebase_user),
):
    firs = db.query(FIR).filter(FIR.user_uid == current_user["uid"]).order_by(FIR.created_at.desc()).all()

    return [
        FIRResponse(
            id=f.id,
            file_name=f.file_name,
            status=f.status,
            summary=f.summary,
            predicted_laws=json.loads(f.predicted_laws) if f.predicted_laws else None,
            urdu_explanation=json.loads(f.urdu_explanation) if f.urdu_explanation else None,
            related_cases=json.loads(f.related_cases) if f.related_cases else None,
            created_at=f.created_at,
        )
        for f in firs
    ]