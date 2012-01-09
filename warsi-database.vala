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

    public WarsiDatabase () throws WarsiDatabaseError {
        int res = db.open_v2(WARSI_DB, out db, Sqlite.OPEN_READWRITE | Sqlite.OPEN_CREATE, 
            null);

        if (res != Sqlite.OK) {
            throw new WarsiArchiveError.DATABASE_PREPARE_ERROR ("Unable to open/create warsi database: %d, %s\n", res, db.errmsg ());
        }
    }

    public void prepare () throws WarsiDatabaseError {
        int res = db.exec ("BEGIN TRANSACTION");

        res = db.prepare_v2("CREATE TABLE IF NOT EXISTS Packages ("
                    + "name TEXT PRIMARY KEY, "
                    + "version TEXT "
                    + ")", -1, out stmt);

        if (res != Sqlite.OK) {
            throw new WarsiArchiveError.DATABASE_PREPARE_ERROR ("Unable to create database structure: %s\n", db.errmsg ());
        }

        res = stmt.step();
        if (res != Sqlite.DONE) {
            throw new WarsiArchiveError.DATABASE_PREPARE_ERROR ("Unable to create database structure: %s\n", db.errmsg ());
        }

        prepared = true;
    }

    public void insert (PackageRow package) throws WarsiDatabaseError {
        if (!prepared) {
            prepare ();
        }

        int res = db.prepare_v2 ("REPLACE INTO Packages (name, version) VALUES (?, ?)", -1, out stmt);
        if (res != Sqlite.OK) {
            throw new WarsiArchiveError.DATABASE_INSERT_ERROR ("Unable to insert: %s\n", db.errmsg ());
        }
        
        res = stmt.bind_text (1, package.name);
        if (res != Sqlite.OK) {
            throw new WarsiArchiveError.DATABASE_INSERT_ERROR ("Unable to insert: %s\n", db.errmsg ());
        }

        res = stmt.bind_text (2, package.version);
        if (res != Sqlite.OK) {
            throw new WarsiArchiveError.DATABASE_INSERT_ERROR ("Unable to insert: %s\n", db.errmsg ());
        }
        
        res = stmt.step ();
        if (res != Sqlite.DONE) {
            throw new WarsiArchiveError.DATABASE_INSERT_ERROR ("Unable to insert: %s\n", db.errmsg ());
        }        
    }

    public void save ()
    {        
        if (prepared) {
            int res = db.exec ("COMMIT");
            prepared = false;
        }
    }
}
