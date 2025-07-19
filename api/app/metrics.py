from flask import request, Response
from prometheus_client import Counter, Histogram, generate_latest
import time

REQUEST_COUNT = Counter('request_count', 'Total request count', ['method', 'endpoint'])
REQUEST_LATENCY = Histogram('request_latency_seconds', 'Request latency', ['endpoint'])

def register_metrics(app):
    @app.before_request
    def before():
        request._start_time = time.time()

    @app.after_request
    def after(response):
        print(f"Request path is: '{request.path}'")
        REQUEST_COUNT.labels(method=request.method, endpoint=request.path).inc()
        if hasattr(request, "_start_time"):
            duration = time.time() - request._start_time
            REQUEST_LATENCY.labels(endpoint=request.path).observe(duration)
        return response

    @app.route("/metrics")
    def metrics():
        return Response(generate_latest(), mimetype="text/plain")
