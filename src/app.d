module mangareader.application;

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
}

string GlobalBookmarkLocation()
{
	return "~/.bookmarks".expandTilde;
}

GlobalBookmark GrandBookmark;

public Controller controller;

static this()
{
	info("Starting application.");
	GrandBookmark = new GlobalBookmark(GlobalBookmarkLocation);
}

static ~this()
{
	info("Shutting down application.");
	
}