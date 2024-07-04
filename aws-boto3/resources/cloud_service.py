from flask import request
from flask.views import MethodView
from flask_smorest import Blueprint, abort
# from db import stores


blp = Blueprint("cloudservice", __name__, description="Operations on cloud service")

@blp.route("/api/cloud-service/<string:cloud_service_id>")
class CloudService(MethodView):

    def get(self):
        return "Hello GET CloudService"

    def delete(self):
        return "Hello DELETE CloudService"

@blp.route("/api/cloud-service")
class CloudServiceList(MethodView):

    def get(self):
        return "Hello GET CloudServiceList"


    def post(self, data):
        return "Hello POST CloudServiceList"