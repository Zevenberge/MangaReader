module mangareader.controller;

import std.experimental.logger;
import std.stdio;
import mangareader.manga;
import mangareader.helpers;
import mangareader.directory;
import dsfml.graphics;

public abstract class Controller
{
	protected RenderWindow _window;
	
	protected this(RenderWindow window)
	{
		_window = window;
	}
	
	~this()
	{
		debug writeln("Destroying ", this.classinfo);
	}
	
	public abstract bool HandleEvent(Event event);
	
	public abstract void Draw();
	
	public abstract void RoundUp();
}

public Controller controller;
