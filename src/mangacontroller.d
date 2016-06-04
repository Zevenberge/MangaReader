module mangareader.mangacontroller;

import std.experimental.logger;
import mangareader.controller;
import mangareader.directory;
import mangareader.directorycontroller;
import mangareader.manga;
import dsfml.graphics;

public class MangaController : Controller
{
	public this(RenderWindow window, Manga manga)
	in
	{
		assert(manga !is null);
		assert(window !is null);
	}
	body
	{
		trace("Creating mangacontroller.");
		_manga = manga;
		super(window);
	}
	
    private Manga _manga;

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
	if(event.key.control)
	{
    		switch(event.key.code) with (Keyboard.Key)
		{
				case R:
					if(event.key.control) _manga.Rewind;
					break;
				case E:
					if(event.key.control) _manga.End;
					break;
				case B:
					if(event.key.control) _manga.ReturnToBookmark;
					break;
				default:
		}
	}
	else
	{
		switch(event.key.code) with (Keyboard.Key)
		{
			case Escape:
				RoundUp;
				.controller = new DirectoryController(_window, new Directory(_manga.Directory, null));
				break;
				case Z:
					_manga.NextPage;
					break;
				case X:
					_manga.PreviousPage;
					break;
				case Up:
					_manga.MoveUp;
					break;
				case Down:
					_manga.MoveDown;
					break;
				default:
		}
	}
    	return false;
    }
    
    public override void RoundUp()
    {
    	_manga.SaveBookmark();
    }
    
    public override void Draw()
    {
    	_window.clear(Color.White);
    	_manga.Draw;
    }
}
