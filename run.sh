python3 ./backend/python-api/wsgi.py & PIDIOS=$!
http-server ./frontend/build         & PIDMIX=$!
wait $PIDMIX
wait $PIDIOS