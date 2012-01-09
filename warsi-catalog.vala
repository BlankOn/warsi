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

private const string PACKAGES_DIR         = "/var/lib/apt/lists";
private const string STATUS_PACKAGES      = "/var/lib/dpkg/status";

public struct PackageRow {
    public string name;
    public string version;
}

public class WarsiCatalog : GLib.Object {

    public WarsiCatalog () {

    }

    public void synchronize () throws WarsiCatalogError {
            var directory     = File.new_for_path (PACKAGES_DIR);
            var enumerator     = directory.enumerate_children (FILE_ATTRIBUTE_STANDARD_NAME, 0);

            FileInfo file_info;
            while ((file_info = enumerator.next_file ()) != null) {
                if ("Packages" in file_info.get_name ()) {
                    var file = File.new_for_path ("%s/%s".printf (PACKAGES_DIR, file_info.get_name ()));
             
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

                            if (line.length == 0) {
                                if (row.name.length != 0 && row.version.length != 0) {
                                    db.insert (row);
                                }
                            }
                        }
                        db.save ();
                    } catch (WarsiCatalogError e) {
                        GLib.stderr.printf ("%s\n", e.message);
                    }
                }
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
