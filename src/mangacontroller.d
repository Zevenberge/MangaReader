module mangareader.mangacontroller;

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
    	switch(event.key.code) with (Keyboard.Key)
    	{
    		case Escape:
    			.controller = new DirectoryController(_window, new Directory(_manga.Directory, null));
    			break;
			case Left:
				_manga.NextPage;
				break;
			case Right:
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
    	return false;
    }
    
    public override void Draw()
    {
    	_window.clear(Color.White);
    	_manga.Draw;
    }
}