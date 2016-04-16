module mangareader.globalbookmark;

import mangareader.bookmark;
import std.file;
import std.path;
import std.experimental.logger;

public class GlobalBookmark : Bookmark
{
	private string _bookmarkFolder;
	
	public this(string folder)
	{
		_bookmarkFolder = folder;
		_bookmarkLocation = folder ~ "/lastread";
		if(!folder.exists)
		{
			info("Creating hidden bookmark folder in home folder.");
			scope(failure) error("Did not manage to create a folder.");
			mkdir(folder);
			assert(folder.exists);
		}
		else
		{
			if(!_bookmarkLocation.exists)
			{
				info("No global bookmarks found.");
			}
			else
			{
				loadBookmark;
			}
		}
		
	}
	
	public override string currentBookmark()
	{
		return _currentBookmark is null ? "~".expandTilde : _currentBookmark;
	}
}


public GlobalBookmark GrandBookmark;
