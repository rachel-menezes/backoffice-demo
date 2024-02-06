import psycopg2
from formal.sqlcommenter.psycopg2.extension import CommenterCursorFactory
import flask
import os
import json

from flask import request, jsonify
from flask_cors import CORS

app = flask.Flask(__name__)

cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'


host = os.getenv('DATABASE_URL')
dbName = os.getenv('DATABASE_NAME')
user = os.getenv('DATABASE_USER')
password = os.getenv('DATABASE_PASSWORD')

users_json = os.getenv('USERS')

if users_json:
    users = json.loads(users_json)
else:
    users = [] 


@app.route('/', methods=['GET'])
def home():
    return "<p>Hello World </p>"

@app.route('/healthcheck', methods=['GET'])
def healthcheck():
    return "<p>ok</p>"


@app.route('/api/v1/fetch-all', methods=["GET"])
def fetch():
    if 'endUserID' in request.args:
        endUserID = int(request.args['endUserID'])
    else:
        return "Error: No end user id field provided. Please specify an endUserID."
    try:
        cursor_factory = CommenterCursorFactory()
        conn = psycopg2.connect(
            host=host,
            database=dbName,
            user=user,
            password=password,
            cursor_factory=cursor_factory)
        cursor = conn.cursor()
        cursor.execute("select * from pii;", "mokhtar@maytana.com")
        return jsonify(cursor.fetchall())
    except Exception as e:
        print(e)
        return "Error: an error occured. Please try again."


@app.route('/api/v1/sign-in', methods=['POST'])
def login():
    email = request.get_json().get('email')
    password = request.get_json().get('password')
    if not email or not password:
        return "Error: No username or password field provided. Please specify both."
    try:
        res = [u for u in users if u['email'] ==
               email and u['password'] == password]

        return jsonify(res[0])
    except:
        return "Error: an error occured. Please try again."
