from flask import Flask, jsonify
from datetime import datetime
import socket

app = Flask(__name__)

@app.route("/")
def home():
    return f"""
    <html>
    <head>
        <title>CloudOps Health Monitor</title>
        <style>
            body {{
                font-family: Arial;
                background: #111827;
                color: white;
                text-align: center;
                padding: 80px;
            }}
            .card {{
                background: #1f2937;
                padding: 40px;
                border-radius: 15px;
                max-width: 600px;
                margin: auto;
            }}
            .status {{
                color: #22c55e;
                font-size: 28px;
                font-weight: bold;
            }}
        </style>
    </head>
    <body>
        <div class="card">
            <h1>CloudOps Service Health Monitor</h1>
            <p class="status">● Service Healthy</p>
            <p>Application is running successfully.</p>
            <p>Host: {socket.gethostname()}</p>
            <p>Checked: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}</p>
        </div>
    </body>
    </html>
    """

@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "service": "cloudops-health-monitor",
        "hostname": socket.gethostname()
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)