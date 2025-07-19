import os

class Config:
    AWS_REGION = os.environ.get("AWS_REGION")
    AWS_ACCESS_KEY_ID = os.environ.get("AWS_ACCESS_KEY_ID", "test")
    AWS_SECRET_ACCESS_KEY = os.environ.get("AWS_SECRET_ACCESS_KEY", "test")
    SQS_URL = os.environ.get("SQS_QUEUE_URL") or os.environ.get("SQS_URL")


    @property
    def AWS_REGION(self):
        return os.getenv("AWS_REGION")

    @property
    def SQS_URL(self):
        return os.getenv("SQS_QUEUE_URL")

    @property
    def DB_HOST(self):
        return os.getenv("DB_HOST")

    @property
    def DB_USER(self):
        return os.getenv("DB_USER")

    @property
    def DB_PASS(self):
        return os.getenv("DB_PASS")
