using GLib;
using Sqlite;

public class WarsiDatabase : GLib.Object {

	public WarsiDatabase () {

		const string WARSIDB = "warsi.db";

		Database db;
        int rc;

        if (!FileUtils.test (WARSIDB, FileTest.IS_REGULAR)) {
            stderr.printf ("Database %s does not exist or is directory\n", WARSIDB);
            return 1;
        }

        rc = Database.open (WARSIDB, out db);

        if (rc != Sqlite.OK) {
            stderr.printf ("Can't open database: %d, %s\n", rc, db.errmsg ());
            return 1;
        }
	}

	public GetLastest () {

	}

	public GetPopular () {
		
	}

	public GetCategories () {

	}

	public GetItemsByCategory () {

	}

	public GetUpdatable () {

	}
}
