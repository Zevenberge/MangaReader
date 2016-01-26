module mangareader.directorycontroller;

import mangareader.controller;
import mangareader.directory;
import dsfml.graphics;


public class DirectoryController : Controller
{
    private Directory _selectedDir;
    
    public this(RenderWindow window, Directory directory)
    in
    {
		assert(window !is null);
    	assert(directory !is null);
    }
    body
    {
    
    	super(window);
    	_selectedDir = directory;
    }

    public override bool EventHandler(Event event)
    {
       return false;
    }
    
    public override void DrawingLoop()
    {
    	windowLoop: while(_window.isOpen)
    	{
    		Event event;
    		while(_window.pollEvent(event))
    		{
    			if(EventHandler(event))
    			{
    				break windowLoop;	
    			}
    		}
    		_window.clear;
    		_selectedDir.Draw(_window);
    		_window.display;
    	}
    }
}