from unittest.mock import MagicMock, patch
import pytest
from datetime import date
from fastapi.testclient import TestClient
from app import app

client = TestClient(app)


@pytest.fixture
def dynamodb_mock():
    with patch('boto3.resource') as mock:
        table_mock = MagicMock()
        mock.return_value.Table.return_value = table_mock
        yield table_mock


def test_get_user_birthday(dynamodb_mock):
    table_mock = dynamodb_mock
    table_mock.get_item.return_value = {
        'Item': {
            'username': 'john',
            'dateOfBirth': '2000-01-02'
        }
    }

    today = date.today()
    next_birthday = date(today.year + 1, 1, 2)
    days_birthday = (next_birthday - today).days

    response = client.get("/hello/john")

    assert response.status_code == 200
    assert response.json() == {
        "message": f"Hello, john! Your birthday is in {days_birthday} day(s)!"}


def test_create_user(dynamodb_mock):
    table_mock = dynamodb_mock
    table_mock.get_item.return_value = {}
    table_mock.table_status = 'ACTIVE'

    response = client.put("/hello/john", json={"dateOfBirth": "2000-01-01"})

    assert response.status_code == 204
    assert table_mock.put_item.call_count == 1


@pytest.mark.parametrize("invalid_date", [
    "3000-01-01",  # data futura
    "2000-13-01",  # mês inválido
    "2000-01-32",  # dia inválido
    "2000-01-0",  # dia inválido
    "2000-01-00"  # dia inválido
])
def test_invalid_date_of_birth(invalid_date):
    from app import User
    with pytest.raises(ValueError):
        User(dateOfBirth=invalid_date)


def test_valid_date_of_birth():
    from app import User
    user = User(dateOfBirth="2000-01-01")


def test_hello_username_not_alpha():
    response = client.put("/hello/123", json={"dateOfBirth": "2000-01-01"})
    assert response.status_code == 400
