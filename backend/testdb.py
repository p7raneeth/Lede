# test_db.py
import asyncio
from database import get_pool, close_pool

async def main():
    pool = await get_pool()
    async with pool.acquire() as conn:
        result = await conn.fetchval("SELECT 1")
        print("Connection successful:", result)
    await close_pool()

asyncio.run(main())
