from flask import Flask

app = Flask(__name__)
env = 'Dev'

@app.route("/")
def index():
    return f"Hello World! This is the {env.lower()} environment!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)