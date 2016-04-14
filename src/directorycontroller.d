module mangareader.directorycontroller;

import mangareader.controller;
import mangareader.directory;
import mangareader.helpers;
import mangareader.resources;
import mangareader.resizingsprite;
import mangareader.style;
import dsfml.graphics;
import std.experimental.logger;


public class DirectoryController : Controller
{
    private Directory _selectedDir;
    private ResizingSprite _background;
    
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
    	_selectedDir.SelectDirectory;
    	_background = new ResizingSprite(Style.InitialWindowSize, Style.InitialWindowSize);
    	debug {_background.name = "directory select background";}
    	_background.boundsCalculation = &CalculateTextureRectForDirectory;
    	_background.loadTextureFromFile(directoryBackground);
    }

    public override bool HandleEvent(Event event)
    {
    	if(event.type == event.EventType.Closed)
    	{
    		_window.close;
    		return true;
    	}
    	if(event.type == event.EventType.KeyReleased)
    	{
    		return KeyEventHandler(event);
    	}
       return false;
    }
    
    private bool KeyEventHandler(Event event)
    {
    	switch(event.key.code) with (Keyboard.Key)
    	{
    		case Escape:
    			return true;
			case Left:
				_selectedDir = _selectedDir.SelectParent;
				break;
			case Right:
				_selectedDir = _selectedDir.SelectChild;
				break;
			case Up:
				_selectedDir = _selectedDir.SelectPrevious;
				break;
			case Down:
				_selectedDir = _selectedDir.SelectNext;
				break;
			case Return:
				break;
			default:
    	}
    	return false;
    }
    
    public override void Draw()
    {
    		_window.clear;
 			DrawBackgroundLayer;
			DrawDirectoryLayer;   	
    }
    
    private void DrawBackgroundLayer()
    {
    	if(_background !is null)
    	{
    		_background.draw(_window);
    	}
    }
    
    private void DrawDirectoryLayer()
    {
    	_selectedDir.Draw(_window);
    }
}










