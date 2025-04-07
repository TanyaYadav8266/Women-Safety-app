from flask import Flask, request, jsonify
import joblib
import numpy as np

app = Flask(__name__)

# Load the model and preprocessing objects
model = joblib.load('emotion_model.pkl')
vectorizer = joblib.load('tfidf_vectorizer.pkl')
label_encoder = joblib.load('label_encoder.pkl')

@app.route('/predict', methods=['POST'])
def predict():
    data = request.json
    text = data['text']
    
    # Preprocess and predict
    text_vectorized = vectorizer.transform([text])
    probabilities = model.predict_proba(text_vectorized)[0]
    
    # Get top 3 emotions
    top_3_indices = np.argsort(probabilities)[-3:][::-1]
    results = []
    for idx in top_3_indices:
        emotion = label_encoder.inverse_transform([idx])[0]
        prob = float(probabilities[idx])
        results.append({'emotion': emotion, 'probability': prob})
    
    return jsonify(results)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)