from marshmallow import Schema, fields

class PlainProjectSchema(Schema):
    id = fields.Int(dump_only=True)
    project_name = fields.Str(required=True)
    url = fields.Str()
    created_by = fields.Int(required=True)


class PlainUserSchema(Schema):
    id = fields.Int(dump_only=True)
    name = fields.Str(required=True)
    email = fields.Str(required=True)
    password = fields.Str(required=True)
    created_at = fields.DateTime(format="iso")
    updated_at = fields.DateTime(format="iso")


class CloudServiceSchema(Schema):
    id = fields.Int(dump_only=True)
    service_id = fields.Str(required=True)
    service_name = fields.Str(required=True)
    provider = fields.Str(required=True)
    meta = fields.Str(required=True)


class PlainDeploymentSchema(Schema):
    id = fields.Int(dump_only=True)
    has_time_limit = fields.Boolean(required=True)
    start_time = fields.DateTime(format="iso")
    end_time = fields.DateTime(format="iso")
    cloud_service_id = fields.Int()
    created_at = fields.DateTime(format="iso")
    updated_at = fields.DateTime(format="iso")    



class ProjectSchema(PlainProjectSchema):
    created_by = fields.Int(required=True, load_only=True)
    user = fields.Nested(PlainUserSchema(), dump_only=True)

class DeploymentSchema(PlainDeploymentSchema):
    project_id = fields.Int(required=True, load_only=True)
    projects = fields.Nested(PlainProjectSchema(), dump_only=True)
    deployed_by = fields.Str(required=True, load_only=True)
    user = fields.Nested(PlainUserSchema(), dump_only=True)