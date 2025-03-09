from flask import Flask, request, jsonify
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch

# Initialize the Flask app
app = Flask(__name__)

# -------------------------------
# Load Model and Tokenizer
# -------------------------------
# Load the CoLA fine-tuned model and tokenizer once at startup
tokenizer = AutoTokenizer.from_pretrained("textattack/roberta-base-CoLA")
model = AutoModelForSequenceClassification.from_pretrained("textattack/roberta-base-CoLA")
model.eval()  # Set model to evaluation mode for inference

# -------------------------------
# Define the Scoring Function
# -------------------------------
def deep_grammar_score(sentence):
    """
    Evaluate a sentence's grammatical acceptability using a model fine-tuned on CoLA.
    Returns a score from 1 to 100.
    """
    inputs = tokenizer(sentence, return_tensors="pt", truncation=True, max_length=128)
    with torch.no_grad():
        outputs = model(**inputs)
    probs = torch.softmax(outputs.logits, dim=-1)
    acceptable_prob = probs[0, 1].item()  # index 1 represents 'acceptable'
    score = acceptable_prob * 100  # scale probability to [0, 100]
    return max(1, score)

# -------------------------------
# Define Flask Endpoints
# -------------------------------

@app.route('/', methods=['GET'])
def index():
    return "Grammar Scoring API is running!"

@app.route('/score', methods=['POST'])
def score():
    """
    Accepts a JSON payload with a key 'text' and returns the grammar score.
    Example input: { "text": "Your sentence here." }
    """
    data = request.get_json(force=True)
    if not data or "text" not in data:
        return jsonify({"error": "JSON payload must contain a 'text' field."}), 400
    
    sentence = data["text"]
    try:
        score_val = deep_grammar_score(sentence)
        return jsonify({"score": round(score_val, 2)})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# -------------------------------
# Run the Flask Application
# -------------------------------
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002,debug=True)
