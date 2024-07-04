from flask import request
from flask.views import MethodView
from flask_smorest import Blueprint, abort
# from db import stores


blp = Blueprint("user", __name__, description="Operations on user")

@blp.route("/api/user/<string:user_id>")
class User(MethodView):

    def get(self):
        return "HELLOS"

    def delete(self):
        pass

@blp.route("/api/user")
class UserList(MethodView):

    def get(self):
        pass


    def post(self, data):
        pass