/* warsi-catalog.vala
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

using GLib;
using Gee;

private const string AVAILABLE_PACKAGES = "/var/lib/dpkg/available";
private const string STATUS_PACKAGES 	= "/var/lib/dpkg/status";

public struct PackageRow {
	public string name;
	public string version;
}

public class WarsiCatalog : GLib.Object {

	public WarsiCatalog () {

	}

	public void synchronize () {
			var file = File.new_for_path (AVAILABLE_PACKAGES);
	 
			if (!file.query_exists (null)) {
				throw new WarsiCatalogError.CATALOG_OPEN_AVAILABLE_ERROR ("File '%s' doesn't exist.\n", file.get_path ());
			}		

			try {
				var in_stream = new DataInputStream (file.read (null));
				string line;

				PackageRow row = PackageRow ();
				var db = new WarsiDatabase ();
				
				while ((line = in_stream.read_line (null, null)) != null) {
					if (line[0] != ' ') {
						var str = line.split(": ");

						switch (str[0]) {
							case "Package":
								row.name = str[1];
								break;
							case "Version":
								row.version = str[1];
								break;
						}
					}

					db.sync (row);
				}
			} catch (IOError e) {
				error ("%s", e.message);
			}
	}

	public status () {

	}

	public update_available () {

	}

	public update_status () {

	}

	public list_favorit () {

	}

	public list_available () {

	}
}
