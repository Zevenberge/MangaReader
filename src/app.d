module mangareader.application;

import mangareader.globalbookmark;
import mangareader.directorycontroller;
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
	auto controller = new DirectoryController(window, initialDirectory);
	controller.DrawingLoop;
}

string GlobalBookmarkLocation()
{
	return "~/.bookmarks".expandTilde;
}

GlobalBookmark GrandBookmark;

static this()
{
	info("Starting application.");
	GrandBookmark = new GlobalBookmark(GlobalBookmarkLocation);
}

static ~this()
{
	info("Shutting down application.");
	
}