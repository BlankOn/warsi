using GLib;
using Sqlite;

public class WarsiDatabase : GLib.Object {

	const string WARSIDB = "warsi.db";
	private Database db;
	private Statement stmt;

	public WarsiDatabase () {

        int rc;

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

	public void GetLastest () {
		int rc;
		int col, cols;

		const string QUERY = "select CategoryName from categories";
		rc = db.prepare_v2(QUERY, -1, out stmt, null);
		
		if ( rc == 1 ) {
			stderr.printf ("SQL error: %d, %s\n", rc, db.errmsg ());
		} else {                        
			cols = stmt.column_count();
			do {
				rc = stmt.step();
				switch ( rc ) {
					case Sqlite.DONE:
						break;
					case Sqlite.ROW:
						for ( col = 0; col < cols; col++ ) {
							string txt = stmt.column_text(col);
                                                                
							stdout.printf("%s\n", txt);
						}
						break;
					default:
						stderr.printf("Error: %d, %s\n", rc, db.errmsg ());
						break;
				}
			} while ( rc == Sqlite.ROW );
		}
	}

//	public GetPopular () {
//		
//	}

	public void GetCategories () {
		int rc;
		int col, cols;

		const string QUERY = "select CategoryName from categories where Parrent_ID = '0'";
		rc = db.prepare_v2(QUERY, -1, out stmt, null);
		
		if ( rc == 1 ) {
			stderr.printf ("SQL error: %d, %s\n", rc, db.errmsg ());
		} else {                        
			cols = stmt.column_count();
			do {
				rc = stmt.step();
				switch ( rc ) {
					case Sqlite.DONE:
						break;
					case Sqlite.ROW:
						for ( col = 0; col < cols; col++ ) {
							string txt = stmt.column_text(col);
                                                                
							stdout.printf("%s\n", txt);
						}
						break;
					default:
						stderr.printf("Error: %d, %s\n", rc, db.errmsg ());
						break;
				}
			} while ( rc == Sqlite.ROW );
		}
	}

	public void GetSubCategory (int category) {
		int rc;
		int col, cols;

		// FIXME: replace '1' with category variable
		const string QUERY = "select CategoryName from categories where Parrent_ID = '1'";
		rc = db.prepare_v2(QUERY, -1, out stmt, null);
		
		if ( rc == 1 ) {
			stderr.printf ("SQL error: %d, %s\n", rc, db.errmsg ());
		} else {                        
			cols = stmt.column_count();
			do {
				rc = stmt.step();
				switch ( rc ) {
					case Sqlite.DONE:
						break;
					case Sqlite.ROW:
						for ( col = 0; col < cols; col++ ) {
							string txt = stmt.column_text(col);
                                                                
							stdout.printf("%s\n", txt);
						}
						break;
					default:
						stderr.printf("Error: %d, %s\n", rc, db.errmsg ());
						break;
				}
			} while ( rc == Sqlite.ROW );
		}
	}

//	public GetItemsByCategory () {

//	}

//	public GetUpdatable () {

//	}

	string[] array_sort_string (string[] array) {
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
