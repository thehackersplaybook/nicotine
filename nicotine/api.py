from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import logging
import uvicorn
from .system import (
    LLMOutput,
    HallucinationEvaluation,
    detect_hallucination,
)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Nicotine API",
    description="AI Hallucination Detection Service",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class HealthResponse(BaseModel):
    status: str
    message: str


class ErrorResponse(BaseModel):
    error: str
    detail: str


@app.get("/", response_model=HealthResponse)
async def root() -> HealthResponse:
    """Root endpoint providing basic service information."""
    return HealthResponse(
        status="healthy", message="Nicotine AI Hallucination Detection Service."
    )


@app.get("/health", response_model=HealthResponse)
async def health_check() -> HealthResponse:
    """Health check endpoint for monitoring."""
    return HealthResponse(status="healthy", message="Service is running.")


@app.post("/api/v1/detect-hallucination", response_model=HallucinationEvaluation)
async def detect_hallucination_endpoint(
    llm_output: LLMOutput,
) -> HallucinationEvaluation:
    """
    Detect hallucinations in LLM output.

    Args:
        llm_output: The LLM output to analyze for hallucinations

    Returns:
        HallucinationEvaluation: Analysis results including hallucination detection

    Raises:
        HTTPException: If there's an error processing the request
    """
    try:
        logger.info(f"Processing hallucination detection for ID: {llm_output.id}.")
        result = detect_hallucination(llm_output)
        logger.info(f"Completed analysis for ID: {llm_output.id}.")
        return result
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}.")
        raise HTTPException(
            status_code=500,
            detail=f"Error processing hallucination detection: {str(e)}.",
        )


@app.exception_handler(Exception)
async def global_exception_handler(request, exc: Exception):
    """Global exception handler for unhandled errors."""
    logger.error(f"Unhandled exception: {str(exc)}.")
    return JSONResponse(
        status_code=500,
        content=ErrorResponse(
            error="Internal Server Error", detail="An unexpected error occurred."
        ).model_dump(),
    )


def create_app() -> FastAPI:
    """Factory function to create the FastAPI application."""
    return app


if __name__ == "__main__":
    uvicorn.run(
        "nicotine.api:app", host="0.0.0.0", port=8000, reload=True, log_level="info"
    )
