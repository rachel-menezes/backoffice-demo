import psycopg2
from formal.sqlcommenter.psycopg2.extension import CommenterCursorFactory
import flask
import os
import json
import logging
logger = logging.getLogger()
logger.setLevel("INFO")

from flask import request, jsonify
from flask_cors import CORS

app = flask.Flask(__name__)

cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'


# host = os.getenv('DATABASE_URL')
# dbName = os.getenv('DATABASE_NAME')
# user = os.getenv('DATABASE_USER')
# password = os.getenv('DATABASE_PASSWORD')

# users_json = os.getenv('USERS')
# if users_json:
#     app.logger.info('Loading users...')
#     users = json.loads(users_json)
# else:
#     app.logger.info('No USERS set as environment variable...')
#     users = [] 


@app.route('/', methods=['GET'])
def home():
    app.logger.info('Display line {i} of application log')
    return "<p>Hello World Dummy Commit </p>"

# @app.route('/healthcheck', methods=['GET'])
# def healthcheck():
#     return "<p>ok</p>"


# @app.route('/api/v1/fetch-all', methods=["GET"])
# def fetch():
#     if 'endUserID' in request.args:
#         endUserID = int(request.args['endUserID'])
#     else:
#         return "Error: No end user id field provided. Please specify an endUserID."
#     try:
#         cursor_factory = CommenterCursorFactory()
#         conn = psycopg2.connect(
#             host=host,
#             database=dbName,
#             user=user,
#             password=password,
#             cursor_factory=cursor_factory)
#         cursor = conn.cursor()
#         cursor.execute("select * from pii;", "mokhtar@maytana.com")
#         return jsonify(cursor.fetchall())
#     except Exception as e:
#         print(e)
#         return "Error: an error occured. Please try again."


# @app.route('/api/v1/sign-in', methods=['POST'])
# def login():
#     email = request.get_json().get('email')
#     password = request.get_json().get('password')
#     app.logger.info("Trying to log user %s with password %s into the app", email, password)
#     if not email or not password:
#         return "Error: No username or password field provided. Please specify both."
#     try:
#         app.logger.info(users)
#         app.logger.info(type(users))
#         res = [u for u in users if u['email'] ==
#                email and u['password'] == password]

#         return jsonify(res[0])
#     except:
#         return "Error: an error occured. Please try again."
