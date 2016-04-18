module mangareader.app;

import mangareader.globalbookmark;
import mangareader.directorycontroller;
import mangareader.controller;
import mangareader.directory;
import mangareader.style;
import dsfml.graphics;
import std.experimental.logger;
import std.stdio;
import std.file;
import std.path;

void main() 
{
	assert(GrandBookmark !is null);
	auto window = new RenderWindow(VideoMode(Style.InitialWindowWidth, Style.InitialWindowHeight), "MangaReader");
	auto initialDirectory = new Directory(GrandBookmark.currentBookmark, null);
	controller = new DirectoryController(window, initialDirectory);

	try
	{
		windowLoop: while(window.isOpen)
		{
			Event event;
			while(window.pollEvent(event))
			{
				if(controller.HandleEvent(event))
				{ 
					info("Exiting ", controller.classinfo);
					break windowLoop;	
				}
				controller.Draw;
				window.display;
			}
			controller.Draw;
			window.display;
		}
		info("Application shut down normally.");
	}
	catch(Throwable t)
	{
		error("Application error");
		while(t !is null)
		{
			error(t.msg, "\n", t.file, " at ", t.line	);
			error("Stacktrace: \n", t.info);
			t = t.next;
		}
		throw t;
	}
}

string GlobalBookmarkLocation()
{
	return "~/.bookmarks".expandTilde;
}



static this()
{
	info("Starting application.");
	GrandBookmark = new GlobalBookmark(GlobalBookmarkLocation);
}

static ~this()
{
	info("Shutting down application.");
	trace("Rounding up controller");
	controller.RoundUp;
	trace("Saving global bookmark.");
	GrandBookmark.saveBookmark;
	
}