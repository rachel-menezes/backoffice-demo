import os
from api.api import app

if __name__ == "__main__":
    app.run(threaded=True, port=4000)
