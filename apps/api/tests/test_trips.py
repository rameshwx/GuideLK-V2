from fastapi.testclient import TestClient


def create_poi(client: TestClient) -> int:
    payload = {
        "name": "Temple of the Tooth",
        "category": "heritage",
        "latitude": 7.2936,
        "longitude": 80.6413,
    }
    response = client.post("/pois/", json=payload)
    assert response.status_code == 201
    return response.json()["id"]


def test_trip_lifecycle(client: TestClient):
    poi_id = create_poi(client)

    trip_payload = {
        "name": "Hill Country Adventure",
        "stops": [
            {
                "kind": "poi",
                "poi_id": poi_id,
                "day_index": 0,
                "sort": 0,
            }
        ],
    }

    create_response = client.post("/trips/", json=trip_payload)
    assert create_response.status_code == 201
    trip = create_response.json()
    assert trip["name"] == "Hill Country Adventure"
    assert len(trip["stops"]) == 1
    stop_id = trip["stops"][0]["id"]

    mark_response = client.post(
        f"/trips/stops/{stop_id}/mark",
        json={"status": "visited"},
    )
    assert mark_response.status_code == 200
    assert mark_response.json()["status"] == "visited"

    list_response = client.get("/trips/")
    assert list_response.status_code == 200
    assert list_response.json()[0]["id"] == trip["id"]
