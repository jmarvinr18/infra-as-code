from flask import request
from flask.views import MethodView
from flask_smorest import Blueprint, abort
from sqlalchemy.exc import SQLAlchemyError, IntegrityError
from models import ProjectModel
from schemas import ProjectSchema
from db import db
# from db import stores


blp = Blueprint("project", __name__, description="Operations on projects")

@blp.route("/api/project/<string:project_id>")
class Project(MethodView):

    @blp.response(200, ProjectSchema)
    def get(self, project_id):
         project = ProjectModel.query.get_or_404(project_id)
         return project
    
    @blp.arguments(ProjectSchema)
    def put(self, data, project_id):
        project = ProjectModel.query.get_or_404(project_id)

        if project:
            project.name = data['project_name']

        db.session.add(project)
        db.session.commit()

        return "Updated"

    def delete(self, project_id):
        project = ProjectModel.query.get_or_404(project_id)
        db.session.delete(project)
        db.session.commit()        
        return f"Hello DELETE Project {project}"
    

@blp.route("/api/project")
class ProjectList(MethodView):

    @blp.response(200, ProjectSchema(many=True))
    def get(self):

        projects = ProjectModel.query.all()
        return projects



    @blp.arguments(ProjectSchema)
    @blp.response(200, ProjectSchema)
    def post(self, data):

        project = ProjectModel(**data)

        try:
            db.session.add(project)
            db.session.commit()

        except IntegrityError:
            abort(400, message="A store with that name already exists.")

        except SQLAlchemyError:
            abort(500, message="An error occured while inserting the items.")

        return project    