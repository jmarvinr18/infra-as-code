from flask import request
from flask.views import MethodView
from flask_smorest import Blueprint, abort
# from db import stores


blp = Blueprint("deployment", __name__, description="Operations on projects")

@blp.route("/api/deployment/<string:deployment_id>")
class Deployment(MethodView):

    def get(self):
        return "Hello GET Deployment"

    def delete(self):
        return "Hello DELETE Deployment"

@blp.route("/api/deployment")
class DeploymentList(MethodView):

    def get(self):
        return "Hello GET Deployment LIST"


    def post(self, data):
        return "Hello POST Deployment LIST"