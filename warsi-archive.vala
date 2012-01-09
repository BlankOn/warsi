/* warsi-archive.vala
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
using Archive;
using Posix;
using Gee;

private const string METADATA = "METADATA";

public class WarsiArchiveWriter : GLib.Object {

    private Write archive;
    private uint8 buffer[4096];

    public WarsiArchiveWriter () {
        this.archive = new Write ();
    }

    public WarsiArchiveWriter.from_file (string fileobj) throws WarsiArchiveError {
        this.archive = new Write ();

        this.archive.set_compression_none();
        this.archive.set_format_ar_bsd ();

        if (this.archive.open_filename (fileobj) != Result.OK) {
            throw new WarsiArchiveError.ARCHIVE_OPEN_ERROR ("%s", this.archive.error_string ());
        }
    }

    public void add_deb (string debobj) {
        this.write_archive (debobj);
    }

    public void create_metadata (Gee.HashMap<string, string> metadata) throws WarsiArchiveError {
        try {
            var file = File.new_for_path (METADATA);
            
            if (file.query_exists ()) {
                file.delete ();
            }

            var dos = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));
            
            foreach ( var metaitem in metadata.entries ) {
                dos.put_string ("%s: %s\n".printf(metaitem.key, metaitem.value));
            }
        } catch (WarsiArchiveError e) {
            GLib.stderr.printf ("%s\n", e.message);
        }

        this.write_archive (METADATA);
    }

//    public void create_checksums (string temp_dir) {

//    }

//    public string md5_file(File file) throws WarsiArchiveError {
//        Checksum md5 = new Checksum(ChecksumType.MD5);
//        uint8[] buffer = new uint8[64 * 1024];
//        
//        FileInputStream fins = file.read(null);
//        for (;;) {
//            size_t bytes_read = fins.read(buffer, buffer.length, null);
//            if (bytes_read <= 0)
//                break;
//            
//            md5.update((uchar[]) buffer, bytes_read);
//        }
//        
//        try {
//            fins.close(null);
//        } catch (WarsiArchiveError err) {
//            warning("Unable to close MD5 input stream for %s: %s", file.get_path(), err.message);
//        }
//        
//        return md5.get_string();
//    }

    private void write_archive (string fileobj) throws WarsiArchiveError {
        var entry = new Entry ();
        entry.set_pathname (fileobj);
        Posix.Stat st;
        Posix.stat (fileobj, out st);
        entry.copy_stat (st);
        entry.set_size (st.st_size);

        if (this.archive.write_header (entry) != Result.OK) {
            throw new WarsiArchiveError.ARCHIVE_WRITE_HEADER_ERROR ("%s", this.archive.error_string ());
        }

        var file = File.new_for_path (fileobj);
        var reader = file.read ();
        var len = reader.read (this.buffer);

        while(len > 0)
        {
            this.archive.write_data(this.buffer, len);
            len = reader.read (this.buffer);
        }
    }

    public void close () throws WarsiArchiveError {
        if (this.archive.finish_entry () != Result.OK) {
            throw new WarsiArchiveError.ARCHIVE_FINISH_ERROR ("%s", this.archive.error_string ());
        }

        if (this.archive.close () != Result.OK) {
            throw new WarsiArchiveError.ARCHIVE_CLOSE_ERROR ("%s", this.archive.error_string ());
        }
     }
}

public class WarsiArchiveReader : GLib.Object {

    private Read archive;
    private uint8 buffer[4096];
    weak Entry e;

    public WarsiArchiveReader () {
        this.archive = new Read ();
    }

    public WarsiArchiveReader.from_file (string fileobj) throws WarsiArchiveError {
        this.archive = new Read ();

        this.archive.support_compression_all();
        this.archive.support_format_ar ();

        if (this.archive.open_filename (fileobj, 4096) != Result.OK) {
            throw new WarsiArchiveError.ARCHIVE_OPEN_ERROR ("%s", this.archive.error_string ());
        }
    }

    public Gee.HashMap<string, string> metadata () {
        var metadata = new HashMap<string, string> ();

        while(archive.next_header(out e) == Result.OK) {        
            if (e.pathname().has_suffix("METADATA")) {
                while (archive.read_data(this.buffer, 4096) != 0) {
                    var lines = (string)this.buffer;
                    var line = lines.split("\n");
                    foreach (var l in line) {
                        if (l[0] != ' ') {
                            var str = l.split(": ");
                            metadata.set ("%s".printf (str[0]), "%s".printf (str[1]));
                        } else {
                            var get_long_desc = metadata.get ("LongDescription");
                            var long_desc = "%s\n%s".printf (get_long_desc, l);
                            metadata.set ("LongDescription", "%s".printf (long_desc));
                        }
                    }
                }
            }
        }
        return metadata;
    }

    public void close () {
        if (this.archive.close () != Result.OK) throws WarsiArchiveError {
            throw new WarsiArchiveError.ARCHIVE_CLOSE_ERROR ("%s", this.archive.error_string ());
        }
    }
}
