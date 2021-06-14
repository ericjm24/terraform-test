from flask import Flask
import sys

app = Flask(__name__)
env = sys.env['ENV']

@app.route("/")
def index():
    return f"Hello World! This is the {env.lower()} environment!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)