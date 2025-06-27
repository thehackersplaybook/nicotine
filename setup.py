from setuptools import setup, find_packages

setup(
    name="nicotine",
    version="0.1.0",
    description="Nicotine is a Python library to detect hallucinations in large-language models (LLMs).",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    author="The Hackers Playbook",
    author_email="contact.adityapatange@gmail.com",
    url="https://github.com/thehackersplaybook/nicotine",
    license="MIT",
    packages=find_packages(),
    install_requires=[
        "openai",
        "fastapi",
        "uvicorn",
        "python-dotenv",
    ],
    python_requires=">=3.9",
    include_package_data=True,
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent",
    ],
)
