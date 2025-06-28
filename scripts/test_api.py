#!/usr/bin/env python3
"""
Simple script to test the Nicotine API endpoints.

This script can be used to manually test the API functionality
without requiring the OpenAI API key (uses mocked responses).
"""

import requests
import json
from typing import Dict, Any
import sys


class APITester:
    """Simple API testing class."""

    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url

    def test_health_endpoints(self) -> None:
        """Test health check endpoints."""
        print("Testing health endpoints...")

        # Test root endpoint
        try:
            response = requests.get(f"{self.base_url}/")
            print(f"GET / - Status: {response.status_code}")
            if response.status_code == 200:
                print(f"Response: {response.json()}")
            print()
        except requests.exceptions.RequestException as e:
            print(f"Error testing root endpoint: {e}")
            return

        # Test health endpoint
        try:
            response = requests.get(f"{self.base_url}/health")
            print(f"GET /health - Status: {response.status_code}")
            if response.status_code == 200:
                print(f"Response: {response.json()}")
            print()
        except requests.exceptions.RequestException as e:
            print(f"Error testing health endpoint: {e}")

    def test_detect_hallucination_endpoint(self) -> None:
        """Test the detect hallucination endpoint."""
        print("Testing detect hallucination endpoint...")

        # Sample payload
        payload = {
            "id": "test-001",
            "prompt": "What is the capital of France?",
            "output": "The capital of France is Paris.",
            "settings": {"model": "gpt-4", "temperature": 0.7, "max_tokens": 1000},
        }

        try:
            response = requests.post(
                f"{self.base_url}/api/v1/detect-hallucination",
                json=payload,
                headers={"Content-Type": "application/json"},
            )
            print(f"POST /api/v1/detect-hallucination - Status: {response.status_code}")
            print(f"Response: {response.json()}")
            print()
        except requests.exceptions.RequestException as e:
            print(f"Error testing detect hallucination endpoint: {e}")

    def test_invalid_payloads(self) -> None:
        """Test error handling with invalid payloads."""
        print("Testing error handling...")

        # Invalid payload (missing required fields)
        invalid_payload = {
            "id": "test-invalid"
            # Missing required fields
        }

        try:
            response = requests.post(
                f"{self.base_url}/api/v1/detect-hallucination",
                json=invalid_payload,
                headers={"Content-Type": "application/json"},
            )
            print(
                f"POST /api/v1/detect-hallucination (invalid) - Status: {response.status_code}"
            )
            if response.status_code == 422:
                print("✓ Correctly returned validation error")
            print()
        except requests.exceptions.RequestException as e:
            print(f"Error testing invalid payload: {e}")

    def test_docs_endpoints(self) -> None:
        """Test documentation endpoints."""
        print("Testing documentation endpoints...")

        # Test Swagger docs
        try:
            response = requests.get(f"{self.base_url}/docs")
            print(f"GET /docs - Status: {response.status_code}")
            if response.status_code == 200 and "text/html" in response.headers.get(
                "content-type", ""
            ):
                print("✓ Swagger docs accessible")
            print()
        except requests.exceptions.RequestException as e:
            print(f"Error testing docs endpoint: {e}")

        # Test ReDoc
        try:
            response = requests.get(f"{self.base_url}/redoc")
            print(f"GET /redoc - Status: {response.status_code}")
            if response.status_code == 200 and "text/html" in response.headers.get(
                "content-type", ""
            ):
                print("✓ ReDoc accessible")
            print()
        except requests.exceptions.RequestException as e:
            print(f"Error testing redoc endpoint: {e}")

    def run_all_tests(self) -> None:
        """Run all API tests."""
        print(f"Starting API tests for {self.base_url}")
        print("=" * 50)

        # Test if server is running
        try:
            response = requests.get(f"{self.base_url}/health", timeout=5)
            if response.status_code != 200:
                print(
                    "Server is not responding correctly. Make sure the service is running."
                )
                return
        except requests.exceptions.RequestException:
            print("Cannot connect to the server. Make sure the service is running.")
            print(f"Expected server at: {self.base_url}")
            print("\nTo start the server:")
            print("  ./scripts/cli/docker-run.sh -d")
            print("  or")
            print("  uvicorn nicotine.api:app --host 0.0.0.0 --port 8000")
            return

        self.test_health_endpoints()
        self.test_detect_hallucination_endpoint()
        self.test_invalid_payloads()
        self.test_docs_endpoints()

        print("All tests completed!")


def main():
    """Main function."""
    base_url = "http://localhost:8000"

    if len(sys.argv) > 1:
        base_url = sys.argv[1]

    tester = APITester(base_url)
    tester.run_all_tests()


if __name__ == "__main__":
    main()
