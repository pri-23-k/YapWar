import os
from google.oauth2 import service_account
from google.auth.transport.requests import Request
import requests

# Path to your downloaded JSON key file
credentials_file = 'C:/Users/velma/Downloads/apt-entity-453013-s7-ff79cc3de467.json'

# Scopes needed for Fact Check Tools API
scopes = ['https://www.googleapis.com/auth/factchecktools']

# Load credentials from JSON file
credentials = service_account.Credentials.from_service_account_file(
    credentials_file, scopes=scopes)

# Refresh access token
credentials.refresh(Request())

# Get access token
access_token = credentials.token

print("Access Token:", access_token)

# Make a request to Fact Check Tools API
api_url = "https://factchecktools.googleapis.com/v1alpha1/claims:search"
params = {
    "query": "climate change",  # Replace with a meaningful search query (required)
    "languageCode": "en-US",  # Language code for English (optional but must be valid)
    "pageSize": 10  # Number of results per page (optional)
}
headers = {
    'Authorization': f'Bearer {access_token}'
}

# Make the API request
response = requests.get(api_url, headers=headers, params=params)

if response.status_code == 200:
    print("API Response:", response.json())
else:
    print(f"Error: {response.status_code}, {response.text}")
