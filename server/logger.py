from flask import Flask
from flask.templating import render_template
import os
from flask.wrappers import Response

# Initialize Flask App
app = Flask(__name__)
 
@app.route('/')
def create():
    return render_template("index.html")

@app.route('/data',methods = ['GET'])
def readData():
    f = open("static/log.txt", "r")
    data = str(f.read())
    res = Response(data,mimetype="text/xml")
    return res

port = int(os.environ.get('PORT', 8080))
if __name__ == '__main__':
    app.run(threaded=True, host='0.0.0.0', port=port)