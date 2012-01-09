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

private const string WARSI_DB             = "/var/lib/warsi/warsi.db";

public class WarsiDatabase : GLib.Object {

    protected static Sqlite.Database db;
    protected static Sqlite.Statement stmt;

    public WarsiDatabase () {
        int res = db.open_v2(WARSI_DB, out db, Sqlite.OPEN_READWRITE | Sqlite.OPEN_CREATE, 
            null);

        if (res != Sqlite.OK) {
            stderr.printf ("Unable to open/create warsi database: %d, %s\n", res, db.errmsg ());
        }

        Sqlite.Statement stmt;
        int res2 = db.prepare_v2("CREATE TABLE IF NOT EXISTS Packages ("
                    + "name TEXT PRIMARY KEY, "
                    + "version TEXT "
                    + ")", -1, out stmt);
        assert(res2 == Sqlite.OK);

        res2 = stmt.step();
        if (res2 != Sqlite.DONE) {
            stderr.printf ("Unable to create database's structur: %s\n", db.errmsg ());
        }
    }

    public void insert (PackageRow? package) {
        int res = db.exec ("BEGIN TRANSACTION");

        res = db.prepare_v2 ("REPLACE INTO Packages (name, version) VALUES (?, ?)", -1, out stmt);
        assert(res == Sqlite.OK);
        
        res = stmt.bind_text (1, package.name);
        assert (res == Sqlite.OK);
        res = stmt.bind_text (2, package.version);
        assert (res == Sqlite.OK);
        
        res = stmt.step ();
        if (res != Sqlite.DONE) {
            stderr.printf ("Failed to insert data.");
        }        
    }

    public void save ()
    {
        res = db.exec ("COMMIT");
    }
}
