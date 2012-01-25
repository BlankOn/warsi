/* warsi-database.vala
 *
 * Copyright (C) 2011  Aji Kisworo Mukti <adzy@di.blankon.in>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 */

using Sqlite;

private const string WARSI_DB   = "/var/lib/warsi/warsi.db";

public class WarsiDatabase : GLib.Object {

    private Sqlite.Database db;
    private Sqlite.Statement stmt;
    private bool prepared = false;

    static WarsiDatabase _instance = null;

    private WarsiDatabase () throws WarsiDatabaseError {
        int res = db.open_v2(WARSI_DB, out db, Sqlite.OPEN_READWRITE | Sqlite.OPEN_CREATE, 
            null);

        if (res != Sqlite.OK) {
            throw new WarsiDatabaseError.DATABASE_PREPARE_ERROR ("Unable to open/create warsi database: %d, %s\n", res, db.errmsg ());
        }
    }

    public static WarsiDatabase instance () {
        if (_instance == null) {
            _instance = new WarsiDatabase ();
        }

        return _instance;
    }

    public void prepare () throws WarsiDatabaseError {
        int res = db.exec ("BEGIN TRANSACTION");

        res = db.prepare_v2("CREATE TABLE IF NOT EXISTS Packages ("
                    + "name TEXT PRIMARY KEY, "
                    + "version TEXT, "
                    + "offset TEXT, "
                    + "repository INTEGER "
                    + ")", -1, out stmt);

        if (res != Sqlite.OK) {
            throw new WarsiDatabaseError.DATABASE_PREPARE_ERROR ("Unable to create database structure: %s\n", db.errmsg ());
        }

        res = stmt.step();
        if (res != Sqlite.DONE) {
            throw new WarsiDatabaseError.DATABASE_PREPARE_ERROR ("Unable to create database structure: %s\n", db.errmsg ());
        }

        res = db.prepare_v2("CREATE TABLE IF NOT EXISTS Repositories ("
                    + "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                    + "repository TEXT UNIQUE, "
                    + "timestamp TEXT "
                    + ")", -1, out stmt);

        if (res != Sqlite.OK) {
            throw new WarsiDatabaseError.DATABASE_PREPARE_ERROR ("Unable to create database structure: %s\n", db.errmsg ());
        }

        res = stmt.step();
        if (res != Sqlite.DONE) {
            throw new WarsiDatabaseError.DATABASE_PREPARE_ERROR ("Unable to create database structure: %s\n", db.errmsg ());
        }

        res = db.prepare_v2("DELETE FROM Packages", -1, out stmt);

        if (res != Sqlite.OK) {
            throw new WarsiDatabaseError.DATABASE_PREPARE_ERROR ("Unable to delete old record: %s\n", db.errmsg ());
        }

        res = stmt.step();
        if (res != Sqlite.DONE) {
            throw new WarsiDatabaseError.DATABASE_PREPARE_ERROR ("Unable to delete old record: %s\n", db.errmsg ());
        }

        res = db.prepare_v2("DELETE FROM Repositories", -1, out stmt);

        if (res != Sqlite.OK) {
            throw new WarsiDatabaseError.DATABASE_PREPARE_ERROR ("Unable to delete old record: %s\n", db.errmsg ());
        }

        res = stmt.step();
        if (res != Sqlite.DONE) {
            throw new WarsiDatabaseError.DATABASE_PREPARE_ERROR ("Unable to delete old record: %s\n", db.errmsg ());
        }

        prepared = true;
    }

    public void insert (PackageRow package) throws WarsiDatabaseError {
        if (!prepared) {
            prepare ();
        }

        int res = db.prepare_v2 ("REPLACE INTO Packages (name, version, offset, repository) VALUES (?, ?, ?, ?)", -1, out stmt);
        if (res != Sqlite.OK) {
            throw new WarsiDatabaseError.DATABASE_INSERT_ERROR ("Unable to insert: %s\n", db.errmsg ());
        }
        
        res = stmt.bind_text (1, package.name);
        if (res != Sqlite.OK) {
            throw new WarsiDatabaseError.DATABASE_INSERT_ERROR ("Unable to insert: %s\n", db.errmsg ());
        }

        res = stmt.bind_text (2, package.version);
        if (res != Sqlite.OK) {
            throw new WarsiDatabaseError.DATABASE_INSERT_ERROR ("Unable to insert: %s\n", db.errmsg ());
        }

        res = stmt.bind_text (3, package.offset);
        if (res != Sqlite.OK) {
            throw new WarsiDatabaseError.DATABASE_INSERT_ERROR ("Unable to insert: %s\n", db.errmsg ());
        }

        res = stmt.bind_int64 (4, package.repository);
        if (res != Sqlite.OK) {
            throw new WarsiDatabaseError.DATABASE_INSERT_ERROR ("Unable to insert: %s\n", db.errmsg ());
        }
        
        res = stmt.step ();
        if (res != Sqlite.DONE) {
            throw new WarsiDatabaseError.DATABASE_INSERT_ERROR ("Unable to insert: %s\n", db.errmsg ());
        }        
    }

    public int64 insert_repository (string repository, string timestamp) throws WarsiDatabaseError {
         if (!prepared) {
            prepare ();
        }

        int res = db.prepare_v2 ("REPLACE INTO Repositories (id, repository, timestamp) VALUES (NULL, ?, ?)", -1, out stmt);
        if (res != Sqlite.OK) {
            throw new WarsiDatabaseError.DATABASE_INSERT_ERROR ("Unable to insert: %s\n", db.errmsg ());
        }
        
        res = stmt.bind_text (1, repository);
        if (res != Sqlite.OK) {
            throw new WarsiDatabaseError.DATABASE_INSERT_ERROR ("Unable to insert: %s\n", db.errmsg ());
        }

        res = stmt.bind_text (2, timestamp);
        if (res != Sqlite.OK) {
            throw new WarsiDatabaseError.DATABASE_INSERT_ERROR ("Unable to insert: %s\n", db.errmsg ());
        }
        
        res = stmt.step ();
        if (res != Sqlite.DONE) {
            throw new WarsiDatabaseError.DATABASE_INSERT_ERROR ("Unable to insert: %s\n", db.errmsg ());
        }

        return db.last_insert_rowid();    
    }

    public void save ()
    {        
        if (prepared) {
            int res = db.exec ("COMMIT");
            prepared = false;
        }
    }

    public Gee.ArrayList<PackageList?> list (string package = "", long start, long length) {
        int res;

        if (package != "") {
            res = db.prepare_v2 ("SELECT name, version, offset, Repositories.repository as repository FROM Packages INNER JOIN Repositories ON Repositories.id=Packages.repository WHERE name LIKE ?% LIMIT ? OFFSET ?", -1, out stmt);
		    res = stmt.bind_text (1, package);
            res = stmt.bind_int64 (2, length);
            res = stmt.bind_int64 (3, start);   
        } else {
            res = db.prepare_v2 ("SELECT name, version, offset, Repositories.repository as repository FROM Packages INNER JOIN Repositories ON Repositories.id=Packages.repository LIMIT ? OFFSET ?", -1, out stmt);
            res = stmt.bind_int64 (1, length);
            res = stmt.bind_int64 (2, start);
        }

		Gee.ArrayList<PackageList?> all = new Gee.ArrayList<PackageList?> ();

		if ( res == 1 ) {
            throw new WarsiDatabaseError.DATABASE_LIST_ERROR ("Unable to list packages: %s\n", db.errmsg ());
		} else {
			while (( res = stmt.step() ) == Sqlite.ROW) {
				PackageList row = PackageList ();
				row.name = stmt.column_text (0);
				row.version = stmt.column_text (1);
                row.offset = stmt.column_text (2);
                row.repository = stmt.column_text (3);

				all.add (row);
			}
		}
		return all;
    }

    public long get_list_size (string package = "%") {
        int res;

        res = db.prepare_v2 ("SELECT COUNT(name) FROM Packages WHERE name LIKE ?%", -1, out stmt);
        res = stmt.bind_text (1, package);
        
        res = stmt.step();
        if (res != Sqlite.ROW) {
            throw new WarsiDatabaseError.DATABASE_LIST_ERROR ("Unable to retrieve row count on Packages: (%d) %s\n", res, db.errmsg());
            
            return 0;
        }
        
        return stmt.column_int(0);
    }
}
