from flask import Flask, request, jsonify
from transformers import pipeline

app = Flask(__name__)

# Load a toxicity detection pipeline using a public model.
toxicity_detector = pipeline(
    "text-classification",
    model="unitary/toxic-bert",
    return_all_scores=True  # Deprecated but still functional; see note below.
)

def detect_toxicity(text):
    """
    Given an input text, returns the toxicity score (probability for 'toxic' label).
    """
    text = str(text)  # Ensure input is a string.
    results = toxicity_detector(text)
    # The pipeline returns a list of dictionaries (one per label) for each input.
    # We look for the 'toxic' label.
    for entry in results[0]:
        if entry['label'].lower() == 'toxic':
            return entry['score']
    return 0.0

@app.route("/", methods=["GET"])
def index():
    return jsonify({"message": "Toxicity detection API is running."})

@app.route("/detect-toxicity", methods=["POST"])
def detect():
    data = request.get_json()
    if not data or "text" not in data:
        return jsonify({"error": "Please provide a 'text' field in the JSON payload."}), 400
    
    text = data["text"]
    score = detect_toxicity(text)
    return jsonify({"toxicity_score": score})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5004, debug=True)
