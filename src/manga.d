module mangareader.manga;

import std.algorithm.comparison;
import std.algorithm.iteration;
import std.algorithm.sorting;
import std.array;
import std.conv;
import std.experimental.logger;
import std.file;
import std.math;
import std.stdio;
import mangareader.globalbookmark;
import mangareader.page;
import mangareader.helpers;
import mangareader.filereader;
import mangareader.bookmark;
import mangareader.resizingsprite;
import mangareader.style;
import dsfml.graphics;

public class Manga
{
  alias DSprite = dsfml.graphics.Sprite;

  private ResizingSprite _sprite;
  private Texture _texture;
  private RenderWindow _window;
  private Page[] _pages;
  private int _currentPage;
  private Bookmark _bookmark;
  private string _directory;
 
  private Vector2u WindowSize()
  {
     return _window.size;
  }
  
  public @property string Directory()
  {
  	 return _directory;
  }
   
  /**
    Fetches the sprite that displays the page that is currently being read.
  */
  public ResizingSprite Sprite()
  {
     return _sprite;
  }

  /**
    Reads the pages from the given directory. Returns true if the loading succeeded and false if the loading did not succeed.
  */
  public bool LoadPages(string directory)
  in
  {
     assert(directory.isDir);
  }
  body
  {
  	 info("Reading directory ", directory, " for manga pages.");
  	 _directory = directory;
  	 scope(failure) return false;
  	 
  	 trace("Searching for files.");
  	 auto files = directory.dirEntries(SpanMode.shallow);
  	 trace("Mapping the files to Page[]");
  	 _pages = files.filter!(f => f.isImage).map!(i => new Page(i.name)).array
  	 	.sort!((x,y) => x.Filename < y.Filename).array;
  	 info("Found ", _pages.length, " pages in the directory.");
  	 auto hasPages = !_pages.empty;
  	 if(hasPages) 
  	 {
  	 	GrandBookmark.updateBookmark(directory);
	    trace("Updated global bookmark.");
  	    trace("Creating new bookmark in the local directory.");
  	    _bookmark = new Bookmark(directory);
  	 }
     return hasPages;
  }
  
  public void OpenManga(RenderWindow window)
  in
  {
  		assert(window !is null);
  }
  body
  {
     _window = window;
  	info("Opening the manga.");
  	if(_pages.empty) 
  	{
  		info("No pages found.");
  		return;
  	}
  	
  	 int index;
  	 if(!_bookmark.currentBookmark.isNullOrEmpty)
  	 {
  	 	foreach(i, page; _pages)
  	 	{
  	 		if(_bookmark.currentBookmark == page.Filename)
  	 		{
  	 			index = i.to!int;
  	 			break;
  	 		}
  	 	}
  	 }
  	 info("Opening at page ", index);
  	 NewPage(index);
  	 info("Opened the manga.");
  }

  /**
     Saves the window for future reference. This is forced by the constructor such that it can never be null.
  */
  public this()
  {
    debug trace("Creating manga"); 
  }
  
  /++
    Saves the bookmark.
  +/
  public void SaveBookmark()
  {
  	_bookmark.saveBookmark;
  }
  
  /++
  	Moves the texture rectangle upwards across the sprite. It will seem like the page is moving down.
  +/
  public void MoveUp()
  {
  	 auto rekt = _sprite.textureRect;
  	 MoveTextureRect(rekt.top - Style.ScrollSpeed);
  }
  
  /**
  	Moves the texture rectangle downwards across the sprite.
  */
  public void MoveDown()
  {
  	 auto rekt = _sprite.textureRect;
  	 MoveTextureRect(rekt.top + Style.ScrollSpeed);
  }

  /**
    Flips over to the next page.
  */
  public bool NextPage()
  {
    return NewPage(_currentPage+1);
  }

  /**
    Flips over to the previous page.
  */
  public bool PreviousPage()
  {
    return NewPage(_currentPage-1);  
  }

  /**
    Generic flip-to-other-page function.
  */
  private bool NewPage(int newPage)
  {
  	info("Fetching new page.");
    // Fetch the new page.
    int index = CorrectBounds(newPage, _pages.length);
    scope(success)
    {
       _currentPage = index;
       _bookmark.updateBookmark(_pages[index].Filename);
    }
  	trace("Loading page ", index);
    debug trace("Amount of pages is ", _pages.length);
    auto page = _pages[index];
    // Force a load of the texture if it is not already loaded.
    if(_texture is null) _texture = new Texture;
    //Claim the texture.
    page.LoadTexture(_texture);
    trace("Claimed the texture.");
    if(_sprite is null)
    {
    	InitializeSprite;
    }
    debug 
    {
    	trace("Setting the sprite's name");
    	_sprite.name = page.Filename;
   	}
    trace("Setting the sprite's texture.");
    _sprite.setTexture(_texture);

    //Grab the width of the original texture.
    Vector2u textureSize = _texture.getSize;   
 
    // Place the texture rectangle at height 0.
    ResetTextureRect;
    trace("Finished loading page ", index);
    return true;
  }
  
  private void InitializeSprite()
  {
  	info("Creating a new sprite");
    _sprite = new ResizingSprite(Style.InitialWindowSize, Style.InitialWindowSize);
  	_sprite.boundsCalculation = &CalculateTextureRectForManga;
  	
  }
  
  private void ResetTextureRect()
  {
  	trace("Resetting texture rectangle.");
  	auto rekt = _sprite.textureRect;
    rekt.top = 0;
    _sprite.textureRect = rekt;
  }
  
  /**
    If the window is larger vertically than the sprite, center the sprite vertically and resize it to the size of the texture.
  */
  private void MoveAndResizeSprite(Vector2u textureSize)
  {
     ResizeSprite(textureSize);
     MoveSprite();
  }

  private void ResizeSprite(Vector2u textureSize)
  {
     Vector2u windowBounds = _window.size;
     // Calculate the scale of the sprite.
     float scale = windowBounds.x / textureSize.x; // Stretch the sprite horizontally.
     _sprite.scale = Vector2f(scale, scale);
  }

  private void MoveSprite()
  {
     if(WindowSize.y < _sprite.getGlobalBounds.height) // If the window is smaller than the texture, the sprite should be set in the origin and the size of the sprite should be the size of the window.
          MoveToOrigin(_sprite);
      else
          Center(_sprite);
  }

  /**
    Moves the sprite to the origin of the window (x,y) = (0,0).
  */
  private void MoveToOrigin(DSprite sprite)
  {
    sprite.position = Vector2f(0,0); 
  }

  /**
    Centers the sprite in the center of the window.
  */
  private void Center(DSprite sprite)
  {
     // Calculate the total difference between the window size and the sprite size.
     auto yMargin = WindowSize.y - sprite.getGlobalBounds.height;
     // Place the sprite downwards by half of it.
     sprite.position = Vector2f(0,yMargin/2);
  }

  /**
     Moves the display rectangle instantly along a distance indicated by offset.
  */
  private void MoveTextureRect(int offSet)
  {
     IntRect textureRect = _sprite.textureRect;
     textureRect.top = max(0, min(offSet, _sprite.getTexture.getSize.y - textureRect.height));
     _sprite.textureRect = textureRect; 
  }

  /**
    Draws the page that is being read to the window.
  */
  public void Draw()
  {
  	 _sprite.draw(_window);
  }

}
