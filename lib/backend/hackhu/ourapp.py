from flask import Flask, request, jsonify
import numpy as np
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity

# Initialize the Flask app
app = Flask(__name__)

# -------------------------------
# Load Saved Models and Parameters
# -------------------------------
model_name = 'all-mpnet-base-v2'
model = SentenceTransformer(model_name)

# Update file paths for centroids and scaling data
centroids_path = "centroids.npy"
scaling_data_path = "score_scaling.npz"

# Load the centroids from the clustering step
centroids = np.load(centroids_path)

# Load scaling parameters (min_score and max_score)
scaling_data = np.load(scaling_data_path)
min_score = float(scaling_data['min_score'])  # Convert to native Python float
max_score = float(scaling_data['max_score'])  # Convert to native Python float

# -------------------------------
# Define the Scoring Function
# -------------------------------
def score_debate_point(text, model, centroids, min_score, max_score):
    """
    Encode the input text, compute cosine similarity to each cluster centroid,
    and normalize the maximum similarity to a score between 1 and 100.
    """
    # Encode the text to get its embedding
    embedding = model.encode([text])[0]
    
    # Compute cosine similarity between the embedding and each centroid
    sims = cosine_similarity([embedding], centroids)
    raw_score = np.max(sims)
    
    # Normalize the raw score using min and max scaling
    if max_score == min_score:
        normalized = 100.0
    else:
        normalized = (raw_score - min_score) / (max_score - min_score) * 99 + 1
        normalized = max(1, min(100, normalized))
    
    return float(normalized)  # Ensure the returned value is a native Python float

# -------------------------------
# Define Flask Endpoints
# -------------------------------

@app.route('/', methods=['GET'])
def index():
    return "Debate Scoring API is up and running!"

@app.route('/score', methods=['POST'])
def get_score():
    """
    Accepts a JSON payload with a key 'text' and returns the debate score.
    Example input: { "text": "Your debate sentence here." }
    """
    data = request.get_json()
    if not data or 'text' not in data:
        return jsonify({"error": "Please provide a 'text' field in the JSON payload."}), 400

    sentence = data['text']
    try:
        score = score_debate_point(sentence, model, centroids, min_score, max_score)
        return jsonify({"score": round(score, 2)})  # Ensure response contains serializable data
    except Exception as e:
        return jsonify({"error": f"Error scoring the text: {str(e)}"}), 500

# -------------------------------
# Run the Flask Application
# -------------------------------
if __name__ == '__main__':
    # For production, set debug=False
    app.run(host="0.0.0.0", port=5001, debug=True)


