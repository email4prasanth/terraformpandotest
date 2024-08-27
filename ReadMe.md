### Develop a Terraform script that performs the following tasks:
    - Create a VPC with both private and public subnets.

- Launch an ubuntu instance t2.micro `MyappServer`, use ipv4 and putty to login, Updated version by creating venv for non-debian packeged we need a virtual environment `myenv`
```
apt update 
sudo apt install python3-venv -y
python3 -m venv myenv
source myenv/bin/activate
pip install SQLAlchemy
python -c "import sqlalchemy; print(sqlalchemy.__version__)"
pip install pymysql
python -c "import pymysql; print(pymysql.__version__)"
nano app.py

import sqlalchemy
import pymysql
from sqlalchemy import create_engine, text
# Create an engine
cnx = create_engine('mysql+pymysql://admin:India123456@dkuttimsyql.cx66mmkusfga.us-east-1.rds.amazonaws.com/myflixdb')
# Use the engine to connect to the database
with cnx.connect() as conn:
    # Use the connection to execute a query
    data = conn.execute(text("select * from movies")).fetchall()
# Print the fetched data
for item in data:
    print(item)

watch python3 app.py
```