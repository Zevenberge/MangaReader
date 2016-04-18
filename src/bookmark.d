module mangareader.bookmark;

import std.path;
import std.experimental.logger;
import std.file;
import std.conv;
import std.stdio;

public class Bookmark
{
	protected string _bookmarkLocation = null;
	protected string _currentBookmark = null;
	
	protected this(){}
	
	public this(string folder)
	{
		info("Constructing bookmark.");
		if(!folder.isDir)
		{
			error("Given string was not a directory. Ignoring bookmarks.");
			return;
		}
		_bookmarkLocation = folder ~ "/lastread";
		if(!_bookmarkLocation.exists)
		{
			info("No bookmarks found for " ~ folder);
		}
		else
		{
			loadBookmark();
		}
	}
	/+
	public ~this()
	{
		debug writeln("Destroying ", this.classinfo, ", saving.");
		saveBookmark();
	}
	+/
	protected void loadBookmark()
	{
		info("Loading bookmark.");
		if(_bookmarkLocation is null) return;
		_currentBookmark = std.file.read(_bookmarkLocation).to!string;
		trace("Loaded bookmark.");
	}
	
	public void saveBookmark()
	{
		if(_bookmarkLocation is null)
		{
			info("Invalid directory, ignoring bookmark.");
		}
		scope(failure) error("Failed to succesfully save a bookmark.");
		scope(success) info("Saved the bookmark to ", _bookmarkLocation);
		std.file.write(_bookmarkLocation, _currentBookmark);
	}
	
	/++
	  Updates the bookmark with the given filename. The filename should be an absolute path.
	+/
	public void updateBookmark(string imageLocation)
	in
	{
		assert(imageLocation.isAbsolute);
	}
	body
	{
		_currentBookmark = imageLocation;
	}
	
	/++
	  Gets the current bookmark. Returns null if there is no bookmark.
	+/
	public string currentBookmark()
	{
		return _currentBookmark;
	}
}






