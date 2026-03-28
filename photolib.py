import subprocess
import sys
import psycopg2
from configparser import ConfigParser


def reset():
    command_string = 'rm -f photolib/view/*'
    result = subprocess.run(command_string, capture_output=True, text=True, shell=True)

    print("Clean up view folder:", result.stdout)

def load_config(filename='database.ini', section='postgresql'):
    """ Read configuration from a .ini file and return a dictionary """
    parser = ConfigParser()
    parser.read(filename)

    config = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            config[param[0]] = param[1]
    else:
        raise Exception(f'Section {section} not found in the {filename} file')

    return config

def get_connection():
    # Load configuration parameters from a file or environment variables
    config = load_config() 
    try:
        conn = psycopg2.connect(**config)
        return conn
    except psycopg2.DatabaseError as error:
        print(f"Connection error: {error}")
        return None

def run_query(query_string):
    conn = get_connection()
    if conn is None:
        return
    
    try:
        # Use context managers for automatic cursor and connection closing
        with conn:
            with conn.cursor() as cur:
                cur.execute(query_string)
                # Fetch results if it's a SELECT query
                if query_string.strip().upper().startswith('SELECT'):
                    records = cur.fetchall() # Fetch all rows
                    for row in records:
                        print(row)
                else:
                    # Commit changes for non-SELECT queries (INSERT, UPDATE, etc.)
                    # The 'with conn' context manager handles the commit/rollback
                    print(f"{cur.rowcount} rows affected.")

    except psycopg2.DatabaseError as error:
        print(f"Query error: {error}")


def main(args):
    reset()
    run_query("delete from photolib")

if __name__ == "__main__":
    # The code in this block runs when the file is executed directly
    exit_code = main(sys.argv[1:])
    sys.exit(exit_code)
