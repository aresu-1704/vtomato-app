import asyncpg
from typing import List, Tuple, Optional, Union

class DatabaseConnect:
    def __init__(self, connect_string: str):
        self.connect_string = connect_string
        self.pool = None  # Sử dụng pool kết nối để tái sử dụng connection

    async def connect(self):
        if self.pool is None:
            self.pool = await asyncpg.create_pool(dsn=self.connect_string)

    async def execute_non_query(self, query: str, params: Optional[Union[Tuple, List]] = None) -> None:
        await self.connect()
        try:
            async with self.pool.acquire() as conn:
                async with conn.transaction():
                    await conn.execute(query, *(params or ()))
        except Exception as e:
            print(f"[ERROR] execute_non_query failed: {e}")

    async def data_query(self, query: str, params: Optional[Union[Tuple, List]] = None) -> List[Tuple]:
        await self.connect()
        try:
            async with self.pool.acquire() as conn:
                rows = await conn.fetch(query, *(params or ()))
                return [tuple(row) for row in rows]
        except Exception as e:
            print(f"[ERROR] data_query failed: {e}")
            return []
