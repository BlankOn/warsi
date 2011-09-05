using Gtk;

public class WarsiWindow {
	
	public Gtk.Window	main_window	{get; set;}
	private Gtk.Builder builder  =  new Gtk.Builder ();
	private Gtk.VBox	vbox_content {get; set;}

	public WarsiWindow () {
		const string GLADE  =  "warsi.glade";
	
        try
        {                        
                builder.add_from_file (GLADE);
                
                main_window  =  builder.get_object ("window") as Gtk.Window;
                
				main_window.set_title ("Warung Aplikasi");
				main_window.set_default_size (900, 500);
                main_window.destroy.connect (Gtk.main_quit);
                builder.connect_signals (this);

				ListCategories ();

        } catch (Error e) {
              	stderr.printf ("Could not load UI: %s\n", e.message);
        }
	}

	/*
		List widget create manual from here, like at glade file now.
	*/

//	public ListItems () {

//	}

	public void ListCategories () {
		var db = new WarsiDatabase ();
		var categories = db.GetCategories ();

		vbox_content = builder.get_object ("vbox_content") as Gtk.VBox;

		foreach ( CategoryRow? category in categories ) {
			CreateListCategories (category.name, category.comment);
		}
	}

	private void CreateListCategories (string name, string comment) {

		var hbox = new HBox (false, 0);
		var vbox = new VBox (false, 5);

		var label_name = new Label (name);
		var label_comment = new Label (comment);

		label_name.set_alignment ((float)0.05, (float)1.0);
		label_comment.set_alignment ((float)0.05, (float)1.0);

		vbox.pack_start (label_name, false, true, 0);
		vbox.pack_start (label_comment, false, true, 0);

		hbox.pack_start (vbox, false, true, 0);

		var hseparator = new HSeparator ();

		vbox_content.pack_start (hbox, false, true, 0);
		vbox_content.pack_start (hseparator, false, true, 0);
	}

	public void ListSubCategories (string Parrent_ID) {
		var db = new WarsiDatabase();
		var subcategories = db.GetSubCategory ((int)Parrent_ID);

		vbox_content = builder.get_object ("vbox_content") as Gtk.VBox;

		foreach ( CategoryRow? category in subcategories ) {
			CreateListCategories (category.name, category.comment);
		}
	}

//	public ListPopular () {

//	}

//	public ListUpdates () {

//	}

//	public DisplayItem () {

//	} 
}
