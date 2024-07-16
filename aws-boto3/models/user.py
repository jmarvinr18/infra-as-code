from db import db


class UserModel(db.Model):
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(80), nullable=False)
    email = db.Column(db.String(80), nullable=False)
    password = db.Column(db.String(80), nullable=False)
    projects = db.relationship("ProjectModel", back_populates="users", lazy="dynamic")


    def to_json(self):
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'password': self.password,
        }
