
# API Home task

This is a simple FastAPI app that allows users to store their date of birth and retrieve a message calculating the number of days until their next birthday. The app is built using FastAPI and AWS infrastructure.

## Table of Contents
- [API Home task](#api-home-task)
  - [Table of Contents](#table-of-contents)
  - [Architecture Diagram](#architecture-diagram)
  - [Solution Formulation](#solution-formulation)
  - [API Documentation](#api-documentation)
    - [``GET /hello/{username}``](#get-hellousername)
    - [`POST /hello/{username}`](#post-hellousername)
    - [User Model](#user-model)
  - [Project Structure](#project-structure)
  - [Installation](#installation)
  - [How to Run Locally](#how-to-run-locally)
  - [Tech Stack and Tools](#tech-stack-and-tools)
  - [Makefile Explained](#makefile-explained)
  - [Testing](#testing)
  - [Cost Estimation (Ignoring Free Tier)](#cost-estimation-ignoring-free-tier)
    - [AWS Lambda](#aws-lambda)
    - [API Gateway](#api-gateway)
    - [DynamoDB](#dynamodb)
    - [CloudWatch Log Groups](#cloudwatch-log-groups)
    - [Total Cost](#total-cost)
  - [Resources](#resources)
  - [Closing Thoughts](#closing-thoughts)

## Architecture Diagram

The app is designed with a serverless architecture using AWS Lambda, API Gateway, and DynamoDB. The following diagram shows the high-level architecture of the app.

[image]

- API Gateway receives incoming HTTP requests and routes them to the corresponding Lambda function.
- The Lambda function processes the request, interacting with DynamoDB to store or retrieve user data.
- DynamoDB stores the user data, providing a scalable and reliable data storage solution.
- The Lambda function returns the processed response to API Gateway, which then returns the response to the user.

## Solution Formulation

In this app, I focused on creating a clean and efficient API using FastAPI. I also made sure to handle edge cases and errors gracefully, providing clear feedback to the user. The solution is modular and easily extensible, with well-separated concerns for data access, application logic, and infrastructure management.

The thorough test suite covers a wide range of scenarios and helps ensure the app's reliability and robustness. The project is structured for easy deployment and management using Terraform and a Makefile to automate common tasks.

## API Documentation

### ``GET /hello/{username}``

Returns a message with the number of days until the user's next birthday.

**Parameters**

- `username` (string): The username of the user.

**Responses**

- `200 OK`: Returns a message with the number of days until the user's next birthday.
- `404 Not Found`: The user with the given username does not exist.
- `500 Internal Server Error`: An error occurred while processing the request.

### `POST /hello/{username}`

Adds a new user with a date of birth.

**Parameters**

- `username` (string): The username of the user.

**Request Body**

```json
Content-Type: application/json
Body: JSON object with user's date of birth
{
  "dateOfBirth": "{date of birth in YYYY-MM-DD format}"
}
```

**Response**

- `204 No Content`: The user was added successfully.
- `400 Bad Request`: The username parameter is not alphabetic.
- `409 Conflict`: A user with the given username already exists.
- `500 Internal Server Error`: An error occurred while processing the request.

### User Model

The User model has the following attributes:

- `dateOfBirth (date)`: The user's date of birth in the format "YYYY-MM-DD".

## Project Structure

```bash
app
- app/tests/
- app/tests/requirements.txt
- app/tests/test_app.py
- app/app.py
- app/requirements.txt
infra
- infra/modules
- infra/modules/api_gateway
- infra/modules/cloudwatch
- infra/modules/dynamodb
- infra/modules/lambda
- infra/modules/s3_bucket
- infra/build_lambda.sh
- infra/main.tf
- infra/outputs.tf
Makefile
```

## Installation

Before you start, make sure you have the following tools installed:
- Python 3.11
- Pip
- Virtualenv (or equivalent)
- Git
- AWS CLI
- Terraform

## How to Run Locally

 1. Clone the repository:

```bash
git clone https://github.com/luizsfer/api-home-task.git
cd revolut-home-task
  ```

2. Install the required packages:

```bash
make install
```

3. Run the tests:

```bash
make test
```

4. Deploy the app to AWS:

```bash
make deploy
```
5. Test the deployed API:

```bash
make add-user
```

## Tech Stack and Tools

- FastAPI
- Python 3.11
- Boto3 for AWS DynamoDB
- Pytest for testing
- AWS Lambda, API Gateway, DynamoDB, and S3
- Terraform for infrastructure management
- Makefile for build automation

## Makefile Explained

The Makefile is a simple build automation tool that manages the common tasks required to build, test, and deploy the app. It consists of several targets, each representing a specific task. Here's a brief explanation of each target:

- install: Installs the required Python packages for the app and tests.
- build: Cleans the previous build, creates a Lambda package with the app and its dependencies, and zips it for deployment.
- test: Runs the test suite using Pytest.
- deploy: Builds and deploys the app to AWS using Terraform.
- empty-bucket: Removes all objects from the specified S3 bucket.
- destroy: Deletes all the deployed AWS resources using Terraform.
- clean: Removes the package directory and lambda.zip file.
- add-user: Adds a user (username) with a sample date of birth (1990-12-13) using the deployed API endpoint.

## Testing

The tests for the app are located in the app/tests directory and can be run using Pytest. The tests cover various scenarios, including:

- Getting a user's birthday message
- Creating a new user
- Handling DynamoDB errors
- Validating date of birth input
- Handling invalid usernames
- Handling duplicate usernames
- Handling internal server errors

To run the tests, simply execute the following command:
```bash
make test
```

## Cost Estimation (Ignoring Free Tier)

The cost of running this solution for 1 million requests per month can be estimated by considering the main components involved: AWS Lambda, API Gateway, DynamoDB, and CloudWatch Log Groups. We will ignore the AWS Free Tier in this calculation and make assumptions about the usage and storage requirements. Note that the actual costs might differ based on various factors such as region, data transfer, and additional features.

### AWS Lambda

AWS Lambda pricing is based on the number of requests and the duration of function execution. With 1 million requests per month and assuming an average execution time of 200ms and 128MB memory allocation for each Lambda invocation, the total cost of Lambda would be:

Number of requests: 1,000,000
Cost per million requests: $0.20
Total execution duration: 1,000,000 * 200ms = 200,000 seconds
Total GB-seconds: (200,000 seconds * 128MB) / 1024MB = 25,000 GB-seconds
Cost per GB-second: $0.00001667

**Total cost for AWS Lambda would be $0.20 (requests) + $0.00001667 * 25,000 (duration) = $0.62.**

### API Gateway

API Gateway pricing is based on the number of API calls and the data transfer out. With 1 million requests per month, the cost would be:

Number of requests: 1,000,000
Cost per million requests: $1.00

**Total cost for API Gateway would be $1.00.**

### DynamoDB

DynamoDB pricing is based on the provisioned read and write capacity units, storage, and data transfer. Assuming we need 1 read capacity unit (RCU) and 1 write capacity unit (WCU) for our use case, and the storage requirements are 10GB:

RCU per month: 1 RCU * 30 days * 24 hours = 720 RCU-hours
Cost per RCU-hour: $0.00013
WCU per month: 1 WCU * 30 days * 24 hours = 720 WCU-hours
Cost per WCU-hour: $0.00065
Storage cost: 10GB * $0.25 = $2.50

**Total cost for DynamoDB would be (720 * $0.00013) + (720 * $0.00065) + $2.50 = $3.61.**

### CloudWatch Log Groups

Assuming 1 million requests generate 1GB of logs and there is no data archiving, the cost for CloudWatch Logs would be:

Log ingestion: 1GB * $0.50 = $0.50
Log storage: 1GB * $0.03 = $0.03

**Total cost for CloudWatch Log Groups would be $0.53.**


### Total Cost

The total cost of running this solution for 1 million requests per month would be:

AWS Lambda: $0.62
API Gateway: $1.00
DynamoDB: $3.61
CloudWatch Log Groups: $0.53

**Total: $5.76**

Keep in mind that this estimation ignores the AWS Free Tier and is based on assumptions about the usage and storage requirements. Actual costs might differ based on various factors such as region, data transfer, and additional features.

## Resources

- FastAPI documentation
- Boto3 documentation
- Pytest documentation
- AWS CLI documentation
- Terraform documentation

## Closing Thoughts

Thank you for taking the time to explore this project! Your interest and support are greatly appreciated. If you have any questions or suggestions, please feel free to reach out. I'm always open to discussing ideas and improvements.

Happy coding!
