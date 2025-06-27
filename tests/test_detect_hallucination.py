import pytest
from nicotine import (
    detect_hallucination,
    LLMOutput,
    LLMSettings,
    HallucinationEvaluation,
)
import nicotine.system  # adjust import if needed


def test_detect_hallucination_basic(monkeypatch):
    # Arrange: fake return value for the parse function
    expected = HallucinationEvaluation(
        is_hallucination=False,
        rationale="Correct answer.",
        delusion_percentage=0.0,
        error=None,
    )

    def mock_parse(*args, **kwargs):
        class MockResponse:
            output_parsed = expected

        return MockResponse()

    monkeypatch.setattr(nicotine.system.client.responses, "parse", mock_parse)

    settings = LLMSettings(model="gpt-4.1", temperature=0.8, max_tokens=1000)
    output = LLMOutput(
        id="1",
        prompt="What is the capital of France?",
        output="Paris",
        settings=settings,
    )

    # Act
    evaluation = detect_hallucination(output)

    # Assert
    assert evaluation.is_hallucination is False
    assert evaluation.rationale == "Correct answer."
    assert evaluation.delusion_percentage == 0.0
    assert evaluation.error is None
