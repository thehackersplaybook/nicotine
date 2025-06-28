# nicotine/__init__.py
from .system import (
    LLMInput,
    LLMOutput,
    LLMSettings,
    HallucinationEvaluation,
    detect_hallucination,
)
from .api import app, create_app

__all__ = [
    "LLMInput",
    "LLMOutput",
    "LLMSettings",
    "HallucinationEvaluation",
    "detect_hallucination",
    "app",
    "create_app",
]
