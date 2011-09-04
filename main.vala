using Gtk;

int main (string[] args) 
{     
	Gtk.init (ref args);
    
	var app = new Unique.App ("id.or.blankonlinux.Warsi", null);
	if (app.is_running ()) {
		stdout.printf ("Warung Aplikasi is already running.\n");
		return 0;
	}

	var warsi  =  new WarsiWindow();
    
	warsi.main_window.show_all ();
	Gtk.main ();

	return 0;
}
