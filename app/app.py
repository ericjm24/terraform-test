from flask import Flask
import os

app = Flask(__name__)
env = os.environ.get("ENV")
port = os.environ.get("PORT")

@app.route("/")
def index():
    return f"Hello World! This is the {env.lower()} environment!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=port)