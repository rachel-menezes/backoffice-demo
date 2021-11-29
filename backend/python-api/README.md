# Formal demo api

Python api made to showcase how to use [formal-sqlcommenter library](https://github.com/formalco/sqlcommenter) in python.


## Setup environment variables locally

### Unix and MacOS
```shell
export DATABASE_URL = "..."
export DATABASE_NAME = "..."
export DATABASE_USER = "..."
export DATABASE_PASSWORD = "..."
```

### Windows
```shell
set DATABASE_URL = "..."
set DATABASE_NAME = "..."
set DATABASE_USER = "..."
set DATABASE_PASSWORD = "..."
```

## Usage

### Formal SQLCommenter

```python
import psycopg2
from formal.sqlcommenter.psycopg2.extension import CommenterCursorFactory
import os

host = os.getenv('DATABASE_URL')
dbName = os.getenv('DATABASE_NAME')
user = os.getenv('DATABASE_USER')
password = os.getenv('DATABASE_PASSWORD')

cursor_factory = CommenterCursorFactory()
conn = psycopg2.connect(
    host=host,
    database=dbName,
    user=user,
    password=password,
    cursor_factory=cursor_factory)
cursor = conn.cursor()

cursor.execute("select * from table;", "1234")

```

which will produce a backend log such as when viewed on Postgresql
```shell
2019-05-28 02:33:25.287 PDT [57302] LOG:  statement: SELECT * FROM
table *--formal_role_id: 1234 */
```

