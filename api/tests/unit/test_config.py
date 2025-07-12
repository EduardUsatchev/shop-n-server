import os

class Config:
    @property
    def AWS_REGION(self):
        return os.getenv("AWS_REGION")

    @property
    def SQS_QUEUE_URL(self):
        return os.getenv("SQS_QUEUE_URL")

    @property
    def AWS_ENDPOINT_URL(self):
        return os.getenv("AWS_ENDPOINT_URL")

    @property
    def DB_HOST(self):
        return os.getenv("DB_HOST")

    @property
    def DB_USER(self):
        return os.getenv("DB_USER")

    @property
    def DB_PASS(self):
        return os.getenv("DB_PASS")
