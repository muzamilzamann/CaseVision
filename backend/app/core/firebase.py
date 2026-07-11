import firebase_admin
from firebase_admin import credentials, auth as firebase_auth
from fastapi import Header, HTTPException, status

from app.core.config import settings

_cred = credentials.Certificate(settings.firebase_credentials_path)
firebase_admin.initialize_app(_cred)


def get_current_firebase_user(authorization: str = Header(...)) -> dict:
    """
    Verifies the Firebase ID token sent in the Authorization header
    (format: "Bearer <token>") and returns the decoded token claims.
    """
    if not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing or invalid Authorization header",
        )

    token = authorization.split(" ", 1)[1]

    try:
        decoded_token = firebase_auth.verify_id_token(token)
        return decoded_token
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired Firebase token",
        )