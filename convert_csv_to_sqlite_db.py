import sqlite3
import pandas as pd

# Load Data file
df = pd.read_csv("df.csv")

# Remove Claim_ID from csv
df = df.drop(columns = ['Claim_ID'])

# Create/connect to a SQLite database
connection = sqlite3.connect('database.db')
cursor = connection.cursor()
# Creating table in database
cursor.execute("""CREATE TABLE IF NOT EXISTS Food_Claims(
                  Claim_ID INTEGER PRIMARY KEY,
                  Receiver_Name TEXT,
                  Receiver_Type TEXT,
                  Receiver_City TEXT,
                  Receiver_Contact TEXT,
                  Provider_Name TEXT,
                  Provider_Type TEXT,
                  Provider_Address TEXT,
                  Provider_City TEXT,
                  Provider_Contact TEXT,
                  Food_Name TEXT,
                  Food_Quantity INTEGER,
                  Food_Type TEXT,
                  Meal_Type TEXT,
                  Expiry_Date DATE,
                  Claim_Status TEXT,
                  Claim_Datetime DATETIME,
                  Expiry_Status TEXT)""")

# Load Datafile to sqlite
df.to_sql('Food_Claims', connection, if_exists='append', index=False)
connection.commit()

# Close connection
connection.close()