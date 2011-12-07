using Gee;

void main (string[] args) 
{   
	var metadata = new HashMap<string, string> ();
	
	metadata.set ("Name", "Audacity");
	metadata.set ("PackageName", "audacity");
	metadata.set ("Version", "1.3.13");
	metadata.set ("Architecture", "i386");
	metadata.set ("Description", "fast, cross-platform audio editor");
	metadata.set ("LongDescription", "Audacity is a multi-track audio editor for Linux/Unix, MacOS and\n Windows.  It is designed for easy recording, playing and editing of\n digital audio.  Audacity features digital effects and spectrum\n analysis tools.  Editing is very fast and provides unlimited\n undo/redo. \n Supported file formats include Ogg Vorbis, MP2, MP3, WAV, AIFF, and AU.");
	metadata.set ("Homepage" , "http://audacity.sourceforge.net/");
	metadata.set ("Rating", "212");

	var write = new WarsiArchiveWriter.from_file ("sample.on");
	write.create_metadata (metadata);
	write.add_deb ("coba.deb");
	write.close ();

	var read = new WarsiArchiveReader.from_file ("sample.on");
	var data = read.metadata ();
	foreach (var entry in data.entries) {
        stdout.printf ("%s => %s\n", entry.key, entry.value);
    }
	print ("%s", data.get ("LongDescription"));
	read.close ();
}
