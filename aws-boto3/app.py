from flask import Flask
from flask_smorest import Api
from resources.project import blp as ProjectBlueprint
from resources.deployment import blp as DeploymentBlueprint
from resources.cloud_service import blp as CloudServiceBlueprint
from resources.user import blp as UserBlueprint
from db import db
import models
import os

API_VERSION = "1.1.0"

def create_app():
    app = Flask(__name__)
    project_dir = os.path.dirname(os.path.abspath(__file__))

    app.config["PROPAGATE_EXCEPTIONS"] = True
    app.config["API_TITLE"] = "Stores REST API"
    app.config["API_VERSION"] = "v1"
    app.config["OPENAPI_VERSION"] = "3.0.3"
    app.config["OPENAPI_URL_PREFIX"] = "/"
    app.config["OPENAPI_SWAGGER_UI_PATH"] = "/swagger-ui"
    app.config["OPENAPI_SWAGGER_UI_URL"] = "https://cdn.jsdelivr.net/npm/swagger-ui-dist/"
    app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///{}".format(os.path.join(project_dir, "app.db"))

    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    db.init_app(app)

    api = Api(app)

    api.register_blueprint(ProjectBlueprint)
    api.register_blueprint(DeploymentBlueprint)
    api.register_blueprint(CloudServiceBlueprint)
    api.register_blueprint(UserBlueprint)

    with app.app_context():
        db.create_all()


    return app
# app.run(host="127.0.0.1", port=5000, debug=True)

# if __name__ == "__main__":
    # create_app()
