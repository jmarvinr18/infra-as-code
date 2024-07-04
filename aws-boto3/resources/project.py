from flask import request
from flask.views import MethodView
from flask_smorest import Blueprint, abort
# from db import stores


blp = Blueprint("project", __name__, description="Operations on projects")

@blp.route("/api/project/<string:project_id>")
class Project(MethodView):

    def get(self, project_id):
         return f"Hello GET Project {project_id}"
    
    def put(self, project_id):
        return f"Hello PUT Project {project_id}"    

    def delete(self, project_id):
        return f"Hello DELETE Project {project_id}"
    

@blp.route("/api/project")
class ProjectList(MethodView):

    def get(self):
        return "Hello GET Project List"


    def post(self, data):
        return f"Hello POST Project List {data}"