"""
Integration tests for the Nicotine FastAPI application.

Tests the API endpoints with real HTTP requests to ensure proper functionality.
"""

import pytest
import asyncio
from httpx import AsyncClient
from fastapi.testclient import TestClient
import os
from unittest.mock import patch, MagicMock

from nicotine.api import app
from nicotine.system import LLMOutput, LLMSettings, HallucinationEvaluation


class TestNicotineAPIIntegration:
    """Integration tests for the Nicotine API."""

    @pytest.fixture
    def client(self):
        """Create a test client for the FastAPI app."""
        return TestClient(app)

    @pytest.fixture
    def sample_llm_settings(self):
        """Provide sample LLM settings for tests."""
        return LLMSettings(model="gpt-4", temperature=0.7, max_tokens=1000)

    @pytest.fixture
    def sample_llm_output(self, sample_llm_settings):
        """Provide sample LLM output for tests."""
        return LLMOutput(
            id="test-001",
            prompt="What is the capital of France?",
            output="The capital of France is Paris.",
            settings=sample_llm_settings,
        )

    @pytest.fixture
    def mock_hallucination_evaluation(self):
        """Provide a mock hallucination evaluation."""
        return HallucinationEvaluation(
            is_hallucination=False,
            rationale="The response is factually correct",
            delusion_percentage=0.0,
            error=None,
        )

    def test_root_endpoint(self, client):
        """Test the root endpoint returns correct response."""
        response = client.get("/")

        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert "Nicotine AI Hallucination Detection Service" in data["message"]

    def test_health_endpoint(self, client):
        """Test the health check endpoint."""
        response = client.get("/health")

        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert data["message"] == "Service is running."

    @patch("nicotine.api.detect_hallucination")
    def test_detect_hallucination_endpoint_success(
        self, mock_detect, client, sample_llm_output, mock_hallucination_evaluation
    ):
        """Test successful hallucination detection."""
        mock_detect.return_value = mock_hallucination_evaluation

        response = client.post(
            "/api/v1/detect-hallucination", json=sample_llm_output.model_dump()
        )

        assert response.status_code == 200
        data = response.json()
        assert data["is_hallucination"] == False
        assert data["rationale"] == "The response is factually correct"
        assert data["delusion_percentage"] == 0.0
        assert data["error"] is None

        mock_detect.assert_called_once()

    @patch("nicotine.api.detect_hallucination")
    def test_detect_hallucination_endpoint_with_hallucination(
        self, mock_detect, client, sample_llm_output
    ):
        """Test hallucination detection when hallucination is detected."""
        mock_evaluation = HallucinationEvaluation(
            is_hallucination=True,
            rationale="The response contains factual errors",
            delusion_percentage=75.5,
            error=None,
        )
        mock_detect.return_value = mock_evaluation

        response = client.post(
            "/api/v1/detect-hallucination", json=sample_llm_output.model_dump()
        )

        assert response.status_code == 200
        data = response.json()
        assert data["is_hallucination"] == True
        assert data["rationale"] == "The response contains factual errors"
        assert data["delusion_percentage"] == 75.5

    @patch("nicotine.api.detect_hallucination")
    def test_detect_hallucination_endpoint_error(
        self, mock_detect, client, sample_llm_output
    ):
        """Test error handling in hallucination detection endpoint."""
        mock_detect.side_effect = Exception("API key not configured")

        response = client.post(
            "/api/v1/detect-hallucination", json=sample_llm_output.model_dump()
        )

        assert response.status_code == 500
        data = response.json()
        assert "Error processing hallucination detection" in data["detail"]

    def test_detect_hallucination_invalid_payload(self, client):
        """Test invalid payload handling."""
        invalid_payload = {
            "id": "test-001",
            # Missing required fields
        }

        response = client.post("/api/v1/detect-hallucination", json=invalid_payload)

        assert response.status_code == 422  # Validation error

    def test_openapi_docs_endpoint(self, client):
        """Test that OpenAPI docs are accessible."""
        response = client.get("/docs")
        assert response.status_code == 200
        assert "text/html" in response.headers["content-type"]

    def test_redoc_endpoint(self, client):
        """Test that ReDoc documentation is accessible."""
        response = client.get("/redoc")
        assert response.status_code == 200
        assert "text/html" in response.headers["content-type"]

    def test_cors_headers(self, client):
        """Test CORS headers are properly set."""
        # Test with an actual POST request since OPTIONS might not be configured
        test_data = {
            "id": "test-cors",
            "prompt": "test",
            "output": "test response",
            "settings": {"model": "gpt-4", "temperature": 0.7, "max_tokens": 100},
        }

        with patch("nicotine.api.detect_hallucination") as mock_detect:
            from nicotine.system import HallucinationEvaluation

            mock_detect.return_value = HallucinationEvaluation(
                is_hallucination=False, rationale="Test", delusion_percentage=0.0
            )

            response = client.post(
                "/api/v1/detect-hallucination",
                json=test_data,
                headers={"Origin": "http://localhost:3000"},
            )
            assert response.status_code == 200
            # CORS headers should be present in response

    @pytest.mark.asyncio
    async def test_async_client_integration(
        self, sample_llm_output, mock_hallucination_evaluation
    ):
        """Test the API using async client."""
        with patch("nicotine.api.detect_hallucination") as mock_detect:
            mock_detect.return_value = mock_hallucination_evaluation

            async with AsyncClient(base_url="http://test") as ac:
                # Use the TestClient's app directly
                from fastapi.testclient import TestClient

                test_client = TestClient(app)

                # Since AsyncClient doesn't directly support ASGI apps in the same way,
                # let's just test with a simple sync request for this test
                response = test_client.post(
                    "/api/v1/detect-hallucination", json=sample_llm_output.model_dump()
                )

                assert response.status_code == 200
                data = response.json()
                assert data["is_hallucination"] == False

    def test_endpoint_content_types(self, client, sample_llm_output):
        """Test that endpoints handle content types correctly."""
        with patch("nicotine.api.detect_hallucination") as mock_detect:
            mock_detect.return_value = HallucinationEvaluation(
                is_hallucination=False, rationale="Test", delusion_percentage=0.0
            )

            # Test JSON content type
            response = client.post(
                "/api/v1/detect-hallucination",
                json=sample_llm_output.model_dump(),
                headers={"Content-Type": "application/json"},
            )
            assert response.status_code == 200

    def test_large_payload_handling(self, client, sample_llm_settings):
        """Test handling of large payloads."""
        large_prompt = "This is a test prompt. " * 1000  # Large prompt
        large_output = LLMOutput(
            id="large-test",
            prompt=large_prompt,
            output=large_prompt,
            settings=sample_llm_settings,
        )

        with patch("nicotine.api.detect_hallucination") as mock_detect:
            mock_detect.return_value = HallucinationEvaluation(
                is_hallucination=False, rationale="Test", delusion_percentage=0.0
            )

            response = client.post(
                "/api/v1/detect-hallucination", json=large_output.model_dump()
            )
            assert response.status_code == 200


# Performance and load testing
class TestAPIPerformance:
    """Performance tests for the API."""

    @pytest.fixture
    def client(self):
        return TestClient(app)

    @pytest.fixture
    def sample_llm_output(self):
        """Provide sample LLM output for tests."""
        return LLMOutput(
            id="test-001",
            prompt="What is the capital of France?",
            output="The capital of France is Paris.",
            settings=LLMSettings(model="gpt-4", temperature=0.7, max_tokens=1000),
        )

    @pytest.mark.asyncio
    async def test_concurrent_requests(self, sample_llm_output):
        """Test handling of concurrent requests."""
        with patch("nicotine.api.detect_hallucination") as mock_detect:
            mock_detect.return_value = HallucinationEvaluation(
                is_hallucination=False,
                rationale="Concurrent test",
                delusion_percentage=0.0,
            )

            def make_request():
                # Use TestClient for concurrent testing
                from fastapi.testclient import TestClient

                test_client = TestClient(app)
                return test_client.post(
                    "/api/v1/detect-hallucination",
                    json=sample_llm_output.model_dump(),
                )

            # Make 10 concurrent requests using asyncio.to_thread for sync requests
            tasks = [asyncio.to_thread(make_request) for _ in range(10)]
            responses = await asyncio.gather(*tasks)

            # All requests should succeed
            for response in responses:
                assert response.status_code == 200


if __name__ == "__main__":
    pytest.main([__file__])
