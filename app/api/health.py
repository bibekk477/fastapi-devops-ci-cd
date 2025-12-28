from fastapi import APIRouter

router = APIRouter()


# /health endpoint
@router.get("/health")
def health_check():
    return {"status": "ok"}
