using Gtk;

int main (string[] args) 
{     
    Gtk.init (ref args);
    
    WarungAplikasi app  =  new WarsiWindow();
    
	app.main_window.show_all ();
    Gtk.main ();

    return 0;
}
