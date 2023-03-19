"""
Author: Luiz Ferreira
Github: @luizsfer
Date: 2023-03-19
"""

import os
import logging
from datetime import date, datetime
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, validator
import mangum
import boto3
from botocore.exceptions import ClientError

# Enable stage name in API Gateway when not using a custom domain
BASE_PATH = "/" + os.environ.get('BASE_PATH', '')

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(root_path="/user_api")

logging.warning(BASE_PATH)

# Configure the DynamoDB client
table_name = os.environ.get("DYNAMODB_TABLE_NAME", "table")


def get_table():
    dynamodb = boto3.resource('dynamodb')
    return dynamodb.Table(table_name)


class User(BaseModel):
    """
    User model
    """
    dateOfBirth: date

    @validator("dateOfBirth")
    def validate_date(cls, valid):
        if valid > date.today():
            raise ValueError("Date of birth cannot be in the future")
        return valid


@app.get("/hello/{username}")
async def read_hello(username: str):
    logging.warning("This is a warning in get")
    logger.info("GET /hello/%s", username)

    table = get_table()
    try:
        response = table.get_item(Key={'username': username})
    except ClientError as error:
        logger.exception("DynamoDB error")
        raise HTTPException(
            status_code=500, detail="Internal Server Error") from error

    if 'Item' not in response:
        logger.warning("User %s not found", username)
        raise HTTPException(status_code=404, detail='User not found')

    birthday = datetime.strptime(
        response['Item']['dateOfBirth'], '%Y-%m-%d').date()
    today = date.today()
    next_birthday = date(today.year, birthday.month, birthday.day)

    if next_birthday < today:
        next_birthday = next_birthday.replace(year=today.year + 1)

    days_birthday = (next_birthday - today).days
    message = (
        f"Hello, {username}! Happy Birthday!"
        if days_birthday == 0
        else f"Hello, {username}! Your birthday is in {days_birthday} day(s)!"
    )

    return {"message": message}


@app.post("/hello/{username}", status_code=204)
async def post_hello(username: str, dateOfBirth: User):
    logger.info("POST /hello/%s", username)

    if not username.isalpha():
        logger.warning("Invalid username: %s", username)
        raise HTTPException(
            status_code=400,
            detail="Username must be alphabetic"
        )

    table = get_table()
    try:
        response = table.get_item(Key={'username': username})
    except Exception as error:
        logger.exception("DynamoDB error")
        raise HTTPException(
            status_code=500, detail="Internal Server Error") from error

    if 'Item' in response:
        logger.warning("User %s already exists", username)
        raise HTTPException(
            status_code=409,
            detail="User already exists"
        )

    try:
        table.put_item(
            Item=({
                'username': username,
                'dateOfBirth': dateOfBirth.dateOfBirth.isoformat()
            })
        )
    except Exception as error:
        logger.exception("DynamoDB error")
        raise HTTPException(
            status_code=500,
            detail="Internal Server Error"
        ) from error

    return None

handler = mangum.Mangum(app, api_gateway_base_path=BASE_PATH)
