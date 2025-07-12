from flask import Flask
from .orders import orders_bp
from .metrics import register_metrics

app = Flask(__name__)
register_metrics(app)
app.register_blueprint(orders_bp)

@app.route("/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__" or __name__ == "app.main":
    app.run(host="0.0.0.0", port=5000,debug=True)
