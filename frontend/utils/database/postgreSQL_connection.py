import psycopg2
from typing import List, Tuple, Optional, Union

class DatabaseConnect:
    def __init__(self, connect_string: str, db_type: str = "postgresql"):
        self.connect_string = connect_string
        self.db_type = db_type.lower()

    def _connect(self):
        if self.db_type == "postgresql":
            return psycopg2.connect(self.connect_string)
        else:
            raise ValueError(f"Unsupported db_type: {self.db_type}")

    def execute_non_query(self, query: str, params: Optional[Union[Tuple, List]] = None) -> None:
        try:
            with self._connect() as conn:
                with conn.cursor() as cursor:
                    cursor.execute(query, params or ())
                    conn.commit()
        except Exception as e:
            print(f"[ERROR] execute_non_query failed: {e}")

    def data_query(self, query: str, params: Optional[Union[Tuple, List]] = None) -> List[Tuple]:
        try:
            with self._connect() as conn:
                with conn.cursor() as cursor:
                    cursor.execute(query, params or ())
                    return cursor.fetchall()
        except Exception as e:
            print(f"[ERROR] data_query failed: {e}")
            return []
