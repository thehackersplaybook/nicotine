from nicotine import LLMSettings, LLMInput, LLMOutput, detect_hallucination
from dotenv import load_dotenv

load_dotenv(dotenv_path=".env", override=True)


def get_started():
    """
    Get started with nicotine.
    """
    settings = LLMSettings(model="gpt-4.1", temperature=0.8, max_tokens=1000)
    input = LLMInput(
        id="1",
        prompt="What is the capital of France?",
        settings=settings,
    )
    output = LLMOutput(
        id="1",
        prompt="What is the capital of France?",
        output="Paris",
        settings=LLMSettings(model="gpt-4o", temperature=0.0, max_tokens=1000),
    )
    evaluation = detect_hallucination(output)
    print(evaluation)


if __name__ == "__main__":
    get_started()
