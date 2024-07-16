from db import db


class ProjectModel(db.Model):

    __tablename__ = "projects"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    project_name = db.Column(db.String(80), nullable=False)
    url = db.Column(db.String(80), nullable=False)
    created_by = db.Column(db.Integer, db.ForeignKey(
        "users.id"), unique=False, nullable=False)
    users = db.relationship("UserModel", back_populates="projects")


    def to_json(self):
        return {
            'id': self.id,
            'project_name': self.project_name,
            'url': self.url,
            'created_by': self.created_by,
        }
