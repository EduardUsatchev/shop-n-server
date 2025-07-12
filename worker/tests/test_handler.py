from handler import handler, DBClient
import json

class DummyDB:
    def __init__(self): self.writes = []
    def write_order(self, order): self.writes.append(order)

def test_handler_writes():
    db = DummyDB()
    event = {"Records": [{"body": json.dumps({"id": "1"})}]}
    handler(event, None, db_client=db)
    assert db.writes and db.writes[0]["id"] == "1"
