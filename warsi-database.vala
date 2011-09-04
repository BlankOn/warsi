using GLib;
using Gee;
using Sqlite;

public struct CategoryRow {
	public string name;
	public string comment;
}

public class WarsiDatabase : GLib.Object {

	const string WARSIDB = "warsi.db";
	private Database db;
	private Statement stmt;	
	int rc;

	public WarsiDatabase () {
        if (!FileUtils.test (WARSIDB, FileTest.IS_REGULAR)) {
            stderr.printf ("Database %s does not exist or is directory\n", WARSIDB);
        }

        rc = Database.open (WARSIDB, out db);

        if (rc != Sqlite.OK) {
            stderr.printf ("Can't open database: %d, %s\n", rc, db.errmsg ());
        }
	}

//	public boid Close () {
//		try {
//			Database.close (WARSIDB);
//			return 0;
//		} catch (Error e) {
//			stderr.printf ("Can't close database.\n");
//			return 1;
//		}
//	}

//	public void GetLastest () {

//	}

//	public GetPopular () {
//		
//	}

	public Gee.ArrayList<CategoryRow?> GetCategories () {

		const string QUERY = "select CategoryName, Comment from categories where Parrent_ID = '0'";
		rc = db.prepare_v2(QUERY, -1, out stmt, null);

		Gee.ArrayList<CategoryRow?> all = new Gee.ArrayList<CategoryRow?> ();

		if ( rc == 1 ) {
			stderr.printf ("SQL error: %d, %s\n", rc, db.errmsg ());
		} else {                        			
			while (( rc = stmt.step() ) == Sqlite.ROW) {
				CategoryRow row = CategoryRow ();
				row.name = stmt.column_text (0);
				row.comment = stmt.column_text (1);

				all.add (row);
			}
		}								
		return all;
	}

//	public void GetSubCategory (int category) {

//	}

//	public GetItemsByCategory () {

//	}

//	public GetUpdatable () {

//	}

	string[] SortStringArray (string[] array) {
		bool swapped = true;
		int j = 0;
		string tmp;

		while (swapped) {
			swapped = false;
			j++;
			for (int i = 0; i < array.length - j; i++) {
				if (array[i] > array[i + 1]) {
					tmp = array[i];
					array[i] = array[i + 1];
					array[i + 1] = tmp;
					swapped = true;
				}
			}
		}
    	return array;
	}
}
