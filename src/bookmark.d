module mangareader.bookmark;

import std.path;
import std.experimental.logger;
import std.file;
import std.conv;

class Bookmark
{
	private string _bookmarkLocation = null;
	private string _currentBookmark = null;
	
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
	
	private void loadBookmark()
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
	
	public void updateBookmark(string imageLocation)
	{
		_currentBookmark = imageLocation;
	}
}