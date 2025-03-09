from flask import Flask, jsonify, request
from flask_cors import CORS
import requests
import json
import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase Admin SDK
cred = credentials.Certificate(r"C:\Users\SUMATHI KALIRAJ\Downloads\backend\hackhu\debate-royal-firebase-adminsdk-fbsvc-c96f4a4d62.json")
firebase_admin.initialize_app(cred)

# Initialize Firestore database
db = firestore.client()

app = Flask(__name__)
CORS(app, resources={r"/": {"origins": ""}})

# Replace with your actual OpenRouter.ai API key
OPENROUTER_API_KEY = "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"
# OpenRouter.ai chat completions endpoint
ENDPOINT = "https://openrouter.ai/api/v1/chat/completions"

# Store conversations by session ID
debate_sessions = {}

@app.route('/')
def home():
    return jsonify({"message": "Debate Royale Analysis Backend is running!"})

@app.route('/start-debate', methods=['POST'])
def start_debate():
    session_id = request.json.get('session_id', str(len(debate_sessions) + 1))
    
    # Initialize a new conversation with the system message
    debate_sessions[session_id] = [
        {"role": "system", "content": (
            "You are a debate analysis assistant. "
            "For each new debate message, extract atomic claims and assign each a truth score (a decimal between 0 and 1). "
            "Output each atomic claim on a new line in the format: 'Claim: <atomic claim> | Truth: <score>'. "
            "Do not include any explanations. "
            "When asked, output only the average truth score (as a decimal) across all claims."
        )}
    ]
    
    # Save session data to Firestore
    db.collection('debate_sessions').document(session_id).set({
        'session_id': session_id,
        'conversation': debate_sessions[session_id]
    })
    
    return jsonify({
        "message": "Debate session started",
        "session_id": session_id
    })

@app.route('/process-message', methods=['POST'])
def process_message_endpoint():
    data = request.json
    session_id = data.get('session_id')
    message = data.get('message')
    
    if not session_id or not message:
        return jsonify({"error": "Missing session_id or message"}), 400
    
    if session_id not in debate_sessions:
        return jsonify({"error": "Session not found"}), 404
    
    result = process_message(session_id, message)
    
    if result:
        return jsonify({"result": result})
    else:
        return jsonify({"error": "Failed to process message"}), 500

@app.route('/end-debate', methods=['POST'])
def end_debate_endpoint():
    session_id = request.json.get('session_id')
    
    if not session_id:
        return jsonify({"error": "Missing session_id"}), 400
    
    if session_id not in debate_sessions:
        return jsonify({"error": "Session not found"}), 404
    
    avg_truth = get_average_truth(session_id)
    
    # Reset the conversation history but keep the session
    system_message = debate_sessions[session_id][0]
    debate_sessions[session_id] = [system_message]
    
    return jsonify({
        "average_truth_score": avg_truth
    })

def process_message(session_id, new_message):
    conversation_history = debate_sessions[session_id]
    conversation_history.append({"role": "user", "content": new_message})
    
    payload = {
        "model": "openai/gpt-4o",
        "messages": conversation_history,
        "temperature": 0.3,
        "max_tokens": 400
    }
    
    headers = {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json"
    }
    
    try:
        response = requests.post(url=ENDPOINT, headers=headers, data=json.dumps(payload))
        response.raise_for_status()  # Raise an exception for HTTP errors
        
        output = response.json()["choices"][0]["message"]["content"]
        conversation_history.append({"role": "assistant", "content": output})
        
        # Update Firestore with the latest conversation history
        db.collection('debate_sessions').document(session_id).update({
            'conversation': conversation_history
        })
        
        return output
    except Exception as e:
        print(f"API error: {str(e)}")
        return None

def get_average_truth(session_id):
    conversation_history = debate_sessions[session_id]
    final_instruction = "Output only the average truth score for this debate as a decimal."
    conversation_history.append({"role": "user", "content": final_instruction})
    
    payload = {
        "model": "openai/gpt-4o",
        "messages": conversation_history,
        "temperature": 0.3,
        "max_tokens": 100
    }
    
    headers = {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json"
    }
    
    try:
        response = requests.post(url=ENDPOINT, headers=headers, data=json.dumps(payload))
        response.raise_for_status()
        
        output = response.json()["choices"][0]["message"]["content"]
        conversation_history.append({"role": "assistant", "content": output})
        
        # Update Firestore with the latest conversation history
        db.collection('debate_sessions').document(session_id).update({
            'conversation': conversation_history
        })
        
        return output
    except Exception as e:
        print(f"API error: {str(e)}")
        return None

if __name__ == '__main__':
    # Listen on all network interfaces and port 5000 (or change as needed)
    app.run(host='0.0.0.0', port=5000, debug=True)
