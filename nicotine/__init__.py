# nicotine/__init__.py
from .system import (
    LLMInput,
    LLMOutput,
    LLMSettings,
    HallucinationEvaluation,
    detect_hallucination,
)

__all__ = [
    "LLMInput",
    "LLMOutput",
    "LLMSettings",
    "HallucinationEvaluation",
    "detect_hallucination",
]
