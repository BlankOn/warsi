using Gtk;

public class WarsiWindow () {

	private Database = new WarsiDatabase ();

	public WarsiWindow () {
		const string GLADE  =  "warsi.glade";
		public Gtk.Window	main_window	{get; set;}

        try
        {
            Gtk.Builder builder  =  new Gtk.Builder ();
                        
                builder.add_from_file (GLADE);
                
                main_window  =  builder.get_object ("window") as Gtk.Window;
                
				main_window.set_title ("Warung Aplikasi");
				main_window.set_default_size (700, 400);
                main_window.destroy.connect (Gtk.main_quit);
                builder.connect_signals (this);
        } catch (Error e) 
          {
              stderr.printf ("Could not load UI: %s\n", e.message);
          }
	}

	/*
		List widget create manual from here, like at glade file now.
	*/

	public ListItems (string category) {
	}

	public ListCategories () {

	}

	public ListPopular () {

	}

	public ListUpdates () {

	}

	public DisplayItem () {

	} 
}
