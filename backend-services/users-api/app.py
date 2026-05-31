from flask import Flask
import os

app = Flask(__name__)

ENV = os.getenv("APP_ENV", "dev")

@app.route(f"/{ENV}/")
@app.route(f"/{ENV}")
def home():
    return f"Backend API Running - Environment: {ENV}"

@app.route(f"/{ENV}/health")
def health():
    return "OK"

@app.route(f"/{ENV}/users")
def users():
    return {"env": ENV, "users": []}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
