import psycopg2
from formal.sqlcommenter.psycopg2.extension import CommenterCursorFactory
import flask
import os

from flask import request, jsonify
from flask_cors import CORS

app = flask.Flask(__name__)

cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'

host = os.getenv('DATABASE_URL')
dbName = os.getenv('DATABASE_NAME')
user = os.getenv('DATABASE_USER')
password = os.getenv('DATABASE_PASSWORD')

cursor_factory = CommenterCursorFactory()
conn = psycopg2.connect(
    host=host,
    database=dbName,
    user=user,
    password=password,
    cursor_factory=cursor_factory)
cursor = conn.cursor()


users = [{
    'id': 0,
    'name': 'John Doe',
    'email': 'john@headway.co',
    'firstName': 'John',
    'lastName': 'Doe',
    'password': 'johndoe',
},
    {
    'id': 1,
    'name': 'Ada Lovelayce',
    'email': 'ada@headway.co',
    'firstName': 'Ada',
    'lastName': 'Lovelayce',
    'password': 'adalovelayce',
}
]

companiesCfg = [{
    'name': 'headway',
    'logoUrl': 'https://enduser-demo.s3.amazonaws.com/headway_logo.png',
    'primaryColor': '#13d183',
    'secondaryColor': '#fff'
}]


@app.route('/', methods=['GET'])
def home():
    return "<p>Hello World </p>"


@app.route('/api/v1/fetch-all', methods=["GET"])
def fetch():
    if 'endUserID' in request.args:
        endUserID = int(request.args['endUserID'])
    else:
        return "Error: No end user id field provided. Please specify an endUserID."
    try:
        cursor.execute("select * from pii;", endUserID)
        return jsonify(cursor.fetchall())
    except:
        return "Error: an error occured. Please try again."


@app.route('/api/v1/company-cfg', methods=["GET"])
def getDemoConfig():
    if 'companyName' in request.args:
        companyName = str(request.args['companyName'])
    else:
        return "Error: no company name field provided. Please specify a company name"

    try:
        return jsonify([c for c in companiesCfg if c['name'] == companyName][0])
    except:
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
