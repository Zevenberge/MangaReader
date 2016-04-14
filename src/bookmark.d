module mangareader.bookmark;

import std.path;
import std.experimental.logger;
import std.file;
import std.conv;

public class Bookmark
{
	protected string _bookmarkLocation = null;
	protected string _currentBookmark = null;
	
	protected this(){}
	
	public this(string folder)
	{
		if(!folder.isDir)
		{
			error("Given string was not a directory. Ignoring bookmarks.");
			return;
		}
		_bookmarkLocation = folder ~ "/.bookmarks";
		if(!_bookmarkLocation.exists)
		{
			info("No bookmarks found for " ~ folder);
		}
		else
		{
			loadBookmark();
		}
	}
	
	public ~this()
	{
		saveBookmark();
	}
	
	protected void loadBookmark()
	{
		if(_bookmarkLocation is null) return;
		_currentBookmark = std.file.read(_bookmarkLocation).to!string;
	}
	
	private void saveBookmark()
	{
		if(_bookmarkLocation is null)
		{
			info("Invalid directory, ignoring bookmark.");
		}
		scope(failure) error("Failed to succesfully save a bookmark.");
		scope(success) info("Saved the bookmark.");
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






