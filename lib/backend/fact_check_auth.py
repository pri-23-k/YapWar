from flask import Flask, request, jsonify
from google.oauth2 import service_account
from google.auth.transport.requests import Request
import requests

# Initialize Flask app
app = Flask(__name__)

# Path to your Google Cloud service account key
CREDENTIALS_FILE = "apt-entity-453013-s7-ff79cc3de467.json"
SCOPES = ["https://www.googleapis.com/auth/factchecktools"]

# Load and refresh credentials
credentials = service_account.Credentials.from_service_account_file(
    CREDENTIALS_FILE, scopes=SCOPES
)
credentials.refresh(Request())
ACCESS_TOKEN = credentials.token

# API URL for Fact Check Tools
API_URL = "https://factchecktools.googleapis.com/v1alpha1/claims:search"

@app.route("/fact-check", methods=["GET"])
def fact_check():
    query = request.args.get("query")
    language = request.args.get("language", "en-US")
    page_size = request.args.get("page_size", 10, type=int)
    
    if not query:
        return jsonify({"error": "Query parameter is required."}), 400
    
    headers = {"Authorization": f"Bearer {ACCESS_TOKEN}"}
    params = {"query": query, "languageCode": language, "pageSize": page_size}
    
    response = requests.get(API_URL, headers=headers, params=params)
    
    if response.status_code == 200:
        return jsonify(response.json())
    else:
        return jsonify({"error": response.text}), response.status_code

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5010, debug=True)
