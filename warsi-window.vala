using Gtk;

public class WarsiWindow {
	
	public Gtk.Window	main_window	{get; set;}
	private Gtk.Builder builder  =  new Gtk.Builder ();

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

		var vbox_content = builder.get_object ("vbox_content") as Gtk.VBox;

		foreach ( CategoryRow? category in categories ) {
			var hbox = new HBox (false, 0);
			var hbox2 = new HBox (false, 0);

			var label_name = new Label (category.name);
			var label_comment = new Label (category.comment);

			hbox2.pack_start (label_name, false, true, 0);
			hbox2.pack_start (label_comment, false, true, 0);

			vbox_content.pack_start (hbox, false, true, 0);

			stdout.printf ("%s = %s", category.name, category.comment);
		}
	}

//	public ListPopular () {

//	}

//	public ListUpdates () {

//	}

//	public DisplayItem () {

//	} 
}
