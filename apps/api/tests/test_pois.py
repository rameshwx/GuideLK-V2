import pytest
from fastapi.testclient import TestClient


def test_create_and_list_pois(client: TestClient):
    create_payload = {
        "name": "Sigiriya Rock",
        "category": "heritage",
        "description": "Ancient rock fortress",
        "photos": ["https://example.com/sigiriya.jpg"],
        "latitude": 7.9570,
        "longitude": 80.7603,
        "is_published": True,
    }

    response = client.post("/pois/", json=create_payload)
    assert response.status_code == 201
    created = response.json()
    assert created["name"] == "Sigiriya Rock"
    assert created["latitude"] == pytest.approx(create_payload["latitude"])

    list_response = client.get("/pois/")
    assert list_response.status_code == 200
    items = list_response.json()
    assert len(items) == 1
    assert items[0]["id"] == created["id"]
