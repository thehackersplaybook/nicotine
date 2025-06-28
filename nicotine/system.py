from pydantic import BaseModel
from openai import OpenAI
import os


# Add these lines BEFORE anything that reads OPENAI_API_KEY:
try:
    from dotenv import load_dotenv

    load_dotenv()
except ImportError:
    pass  # dotenv is optional, ignore if not installed

api_key = os.getenv("OPENAI_API_KEY")

if not api_key:
    raise ValueError("OPENAI_API_KEY is not set.")

client = OpenAI(api_key=api_key)


class LLMSettings(BaseModel):
    """
    Settings for an LLM.
    """

    model: str = "gpt-4.1"
    temperature: float = 0.7
    max_tokens: int = 1000


class LLMInput(BaseModel):
    """
    Input to an LLM.
    """

    id: str
    prompt: str
    settings: LLMSettings


class LLMOutput(BaseModel):
    """
    Output from an LLM.
    """

    id: str
    prompt: str
    output: str
    settings: LLMSettings


class HallucinationEvaluation(BaseModel):
    """
    Evaluation of hallucinations in the output.
    """

    is_hallucination: bool
    rationale: str
    delusion_percentage: float
    error: str | None = None


def detect_hallucination(output: LLMOutput) -> HallucinationEvaluation:
    """
    Detect hallucinations in the input using the references.
    """
    hallucination_prompt = f"""
    You are a helpful assistant that detects hallucinations in the input.

    Input: {output.prompt}
    Output: {output.output}
    """
    try:
        response = client.responses.parse(
            input=hallucination_prompt,
            model=output.settings.model,
            temperature=output.settings.temperature,
            max_output_tokens=output.settings.max_tokens,
            text_format=HallucinationEvaluation,
        )
        if response.output_parsed is None:
            return HallucinationEvaluation(
                is_hallucination=False,
                rationale="Parsing failed (None returned)",
                delusion_percentage=0.0,
                error="output_parsed was None",
            )
        return response.output_parsed
    except Exception as e:
        print(f"Error detecting hallucinations: {e}. Returning default values.")
        return HallucinationEvaluation(
            is_hallucination=False,
            rationale="Error detecting hallucinations",
            delusion_percentage=0.0,
            error=str(e),
        )
