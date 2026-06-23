# main.py
#
# This is what actually starts a running server.
# Without running this, nothing is listening for Flutter's requests.

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import chatbot

app = FastAPI(title="Smart Sewa API")

# CORS — without this, Flutter's requests get blocked
# by the browser/network layer before they even reach your routes
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register the chatbot route
app.include_router(chatbot.router)


@app.get("/")
def root():
    """
    Quick check: visit http://localhost:8000/ in a browser
    If you see this message, your server is running correctly.
    """
    return {"message": "Smart Sewa API is running. Visit /docs to test endpoints."}