module mangareader.manga;

import std.conv;
import std.math;
import mangareader.page;
import mangareader.helpers;
import mangareader.filereader;
import mangareader.bookmark;
import mangareader.resizingsprite;
import dsfml.graphics;

public class Manga
{
  alias DSprite = dsfml.graphics.Sprite;

  private ResizingSprite _sprite;
  private RenderWindow _window;
  private Page[] _pages;
  private int _currentPage;
  private Bookmark _bookmark;
 
  private Vector2u WindowSize()
  {
     return _window.size;
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
  	 import std.file;
     assert(directory.isDir);
  }
  body
  {
  	 scope(failure) return false;
  	 _bookmark = new Bookmark(directory);
  	 //TODO : actually load the pages.
     return true;
  }

  /**
     Saves the window for future reference. This is forced by the constructor such that it can never be null.
  */
  public this(RenderWindow window)
  in
  {
     assert(!(window is null));
  }
  body
  {
     _window = window;
     
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
    // Fetch the new page.
    int index = CorrectBounds(newPage, _pages.length);
    Page page = _pages[index];
    // Force a load of the texture if it is not already loaded.
    if(page.Texture is null) page.LoadTexture;
    //Claim the texture.
    auto texture = page.Texture; // Notational convinience.
    _sprite.setTexture(texture);

    //Grab the width of the original texture.
    Vector2u textureSize = texture.getSize;   
 
    // Resize the selection.
    // FIXME: should be implemented by resizingSprite.
    //ResizeTextureRect(textureSize);

    return true;
  }

  /+/**
    Resizes the area of the texture that is being read based on the width of the texture and the off-set from the top of the page.
  */
  private void ResizeTextureRect(Vector2u textureSize, int offSet=0)
  {
     Vector2u windowBounds = WindowSize;
     int textureWidth = textureSize.x; 
     IntRect textureRect = CalculateTextureRect(WindowSize, textureWidth);
     _sprite.textureRect(textureRect);
     MoveAndResizeSprite(textureSize);
     MoveTextureRect(offSet);
  }+/

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
     textureRect.top = offSet;
     _sprite.textureRect = textureRect; 
  }

  /**
    Draws the page that is being read to the window.
  */
  public void Draw()
  {
     _window.draw(_sprite);
  }

}
