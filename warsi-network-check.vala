using Glib;

public class WarsiNetworkCheck () {
	public WarsiNetworkCheck () {
		
		var host = "warung.blankonlinux.or.id";
		
		try {
			// Resolve hostname to IP address
		    var resolver = Resolver.get_default ();
		    var addresses = resolver.lookup_by_name (host, null);
		    var address = addresses.nth_data (0);
		    stdout.printf ("Resolved %s to address\n", host);

		    // Connect
		    var client = new SocketClient ();
		    var conn = client.connect (new InetSocketAddress (address, 80));
		    stdout.printf ("Connected to %s\n", host);

			return 1;
		} catch (Error e) {
			stderr.printf ("%s\n", e.message);
			return 0;
		}
	}
}
