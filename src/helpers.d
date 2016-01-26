module mangareader.helpers;

import dsfml.graphics;
import dsfml.system;
import std.conv;
import std.stdio;
import std.path;
/**
  A function that corrects the bounds for the given index.
*/
public int CorrectBounds(int index, size_t length )
{
  if(index < 0) return 0;
  if(index >= length) return length.to!int-1;
  return index;
}

/**
  Calculates the texture rectangle that is needed to fill the window horizontally.
*/
public IntRect CalculateTextureRect(Vector2u windowBounds, int textureWidth)
{
  IntRect rekt;
  rekt.width = textureWidth;
  float scale = windowBounds.x/textureWidth;
  rekt.height = (scale * windowBounds.y).to!int;
  return rekt;
}

/**
   Generic loading function that loads an image/etc from a file.
*/
public void Load(T) (T loadable, string filename)
{
  if(!loadable.loadFromFile(filename))
  {
    writeln("File ", filename, "not found.");
  }
}

/**
   Returns the rooted path.
*/
public string GetRootPath(string path)
{
   return path.expandTilde.absolutePath;
}

/**
  Given the current path, fetches the directory just above it.
*/
public string GetParentDirectory(string path)
{
   int offset = 0;
   if(path[$-1] == '/') offset = 1;
   return path[0 .. $ - offset].dirName;
}

/**
   Determines whether the drawable of type T is out of the bounds of type R.
*/
public bool IsOutOfBounds(T, R) (T drawable, R bounds)
{ // FIXME: overbodig?
  // Check left.
  if(IsTooDown(drawable, bounds)) return true;
  // Check top.
  if(IsTooTop(drawable, bounds)) return true;
  // Check right.
  if(IsTooRight(drawable, bounds)) return true;
  // Check bottom.
  if(IsTooLeft(drawable, bounds)) return true;
  return false;
}

/**
  Determines whether the drawable is out of bounds on the bottom.
*/
public bool IsTooDown(T,R) (T drawable, R bounds)
{
  return localBounds.bottom > bounds.bottom;
}

/**
  Determines whether the drawable is out of bounds on the right.
*/
public bool IsTooRight(T,R) (T drawable, R bounds)
{
  return localBounds.right > bounds.right;
}

/**
  Determines whether the drawable is out of bounds on the top.
*/
public bool IsTooTop(T,R) (T drawable, R bounds)
{
  return localBounds.top > bounds.top;
}

/**
  Determines whether the drawable is out of bounds on the left.
*/
public bool IsTooLeft(T,R) (T drawable, R bounds)
{
  return localBounds.left > bounds.left;
}

/**
  Shortcut function that calculates the right side of a rectangle.
*/
public N right(N) (Rect!N rectangle)
{
   return rectangle.left + rectangle.width;
}

/**
   Shortcut function that calculates the bottom side of a rectangle.
*/
public N bottom(N) (Rect!N rectangle)
{
   return rectangle.top + rectangle.height;
}

/** FIXME: Is this function doomed to have no purpose? :(
   Shortcut function that calculates the floatrect of a given window.
*/
public FloatRect getGlobalBounds(Window window)
{
   auto size = window.size;
   return FloatRect(0, 0, size.x, size.y);
}
