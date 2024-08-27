### Develop a Terraform script that performs the following tasks:
    - Create a VPC with both private and public subnets.


#### Connecting application prespective using drivers
```
apt update 
sudo apt install python3-venv -y
python3 -m venv myenv
source myenv/bin/activate
pip install SQLAlchemy
python -c "import sqlalchemy; print(sqlalchemy.__version__)"
pip install psycopg2-binary
python -c "import psycopg2; print(psycopg2.__version__)"
nano app.py

import sqlalchemy
import psycopg2
from sqlalchemy import create_engine, text
# Create an engine
cnx = create_engine('postgresql+psycopg2://username:password@hostname:port/myflixdb')
# Use the engine to connect to the database
with cnx.connect() as conn:
    # Use the connection to execute a query
    data = conn.execute(text("SELECT * FROM categories")).fetchall()
# Print the fetched data
for item in data:
    print(item)

watch python3 app.py
```

