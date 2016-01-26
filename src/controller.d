module mangareader.controller;

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
	
	public abstract bool EventHandler(Event event);
	
	public abstract void DrawingLoop();
}


public class MangaController
{
    private Manga _manga;

    public void EventHandler(Event event)
    {

    }
}
