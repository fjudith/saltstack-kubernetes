import asyncio
from nats.aio.client import Client as NATS

async def example():

   # [begin connect_status]
   nc = NATS()

   await nc.connect(
      servers=["localhost:4222"],
      )

   # Do something with the connection.

   print("The connection is connected?", nc.is_connected)

   while True:
     if nc.is_reconnecting:
       print("Reconnecting to NATS...")
       break
     await asyncio.sleep(1)

   await nc.close()

   print("The connection is closed?", nc.is_closed)

   # [end connect_status]

loop = asyncio.get_event_loop()
loop.run_until_complete(example())
loop.close()