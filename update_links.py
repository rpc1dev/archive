#!/usr/bin/python
# Update all local href's from an HTML page into Google Drive links
# according to the content of an SQLite DB

import sys, sqlite3
from sqlite3 import Error
from bs4 import BeautifulSoup

#page = './index.html'
db   = r'./links.db'

def main(argv):
    try:
        connection = sqlite3.connect(db)
        cursor = connection.cursor()

        with open(argv[0]) as fp:
            soup = BeautifulSoup(fp, 'html.parser')
            for a in soup.find_all('a', href=True):
                h = a.get('href')
                if (not h.startswith('http') and not h.startswith('#') and not h.startswith('..') and not h.startswith('mailto')):
                    cursor.execute('SELECT url FROM links WHERE path LIKE "%%%s"' % h)
                    record = cursor.fetchone()
                    if record is None:
                        a['href'] = '!!BROKEN LINK!! (was \'%s\')' % h
                    else:
                        a['href'] = record[0]
            print(str(soup))

        cursor.close()

    except IndexError:
        print('You must supply an HTML input file as parameter')
    except sqlite3.Error as error:
        print('Error while connecting to sqlite', error)

    finally:
        if connection:
            connection.close()

if __name__ == "__main__":
   main(sys.argv[1:])