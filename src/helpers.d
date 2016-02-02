module mangareader.helpers;

import dsfml.graphics;
import dsfml.system;
import std.format;
import std.conv;
import std.algorithm.comparison;
import std.path;
import std.experimental.logger;
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
*/ // TODO: implement this in page self such that this can use the scrolling position
public IntRect CalculateTextureRectForManga(FloatRect windowBounds, Vector2u textureSize)
{
  IntRect rekt;
  rekt.width = textureSize.x;
  float scale = windowBounds.width/textureSize.x;
  rekt.height = (scale * windowBounds.height).to!int;
  return rekt;
}

/**
  Calculates the texture rectangle for the file menu.
*/
public IntRect CalculateTextureRectForDirectory(FloatRect windowBounds, Vector2u textureSize)
{
	float scale = 1f;
	if(textureSize.x < windowBounds.width || textureSize.y < windowBounds.height)
	{ // As the window is larger than the texture, we need to scale the texture.
		auto scaleX = textureSize.x / windowBounds.width;
		auto scaleY = textureSize.y / windowBounds.height;
		scale = min(scaleX, scaleY);
	} 
	IntRect rekt;
	with(rekt)
	{
		width = (scale * windowBounds.width).to!int;
		height = (scale * windowBounds.height).to!int;
		left = Center(width, textureSize.x).to!int;
		top = Center(height, textureSize.y).to!int;
	}
	return rekt;
}

unittest
{
	info("Starting a test that checks the resulting texture rectangle given a large texture.");
	auto windowBounds = Vector2f(200,400).toRect;
	auto textureSize = Vector2u(500,1000);
	auto textureRect = CalculateTextureRectForDirectory(windowBounds, textureSize);
	assert(windowBounds.width == textureRect.width);
	assert(textureRect.left == 150, "left = %s".format(textureRect.left));
	assert(textureRect.top == 300, "top = %s".format(textureRect.top));
	assert(windowBounds.height == textureRect.height);
	info("Finished the test that checks the large texture rect");
}

public float Center(float dX, float width)
{
	return (width - dX)/2;
}

unittest
{
	info("Starting the center test");
	assert(Center(10,10) == 0);
	assert(Center(8,10) == 1);
	assert(Center(4,5) == 0.5f);
	info("Finished the center test");
}

/**
   Generic loading function that loads an image/etc from a file.
*/
public bool Load(T) (T loadable, string filename)
{
  if(!loadable.loadFromFile(filename))
  {
	mixin(FILE_NOT_FOUND_ERROR_LOGGER);
    return false;
  }
  return true;
}
public bool Load(T) (T loadable, string filename, IntRect boundsToRead)
{
  if(!loadable.loadFromFile(filename, boundsToRead))
  {
	mixin(FILE_NOT_FOUND_ERROR_LOGGER);
    return false;
  }
  return true;
}

public void LoadSpriteAndTexture(TSprite)(ref TSprite sprite, ref Texture texture,
					string filename, IntRect boundsToRead)
{
	mixin(textureMixin!("filename, boundsToRead"));
}

public Vector2!T toVector(T)(Rect!T rectangle)
{
	return Vector2!T(rectangle.width, rectangle.height);
}

public Rect!T toRect(T)(Vector2!T vector)
{
	return Rect!T(0,0,vector.x, vector.y);
}

unittest
{
	info("Starting vector => rect conversion test");
	auto vector = Vector2f(42f, 121f);
	auto rekt = vector.toRect;
	assert(vector.x == rekt.width);
	assert(vector.y == rekt.height);
	info("Completed vector => rect conversion test");
}

public Vector2f pix2scale(T1,T2)(Vector2!T1 actualSize, Vector2!T2 desiredSize, Vector2i initialWindowSize, Vector2i actualWindowSize)
{
	Vector2f scale;
	Vector2f initialScale;
	initialScale.x = desiredSize.x.to!float / actualSize.x.to!float;
	initialScale.y = desiredSize.y.to!float / actualSize.y.to!float;
	scale.x = (initialScale.x * initialWindowSize.x.to!float / actualWindowSize.x.to!float).to!float;
	scale.y = (initialScale.y * initialWindowSize.y.to!float / actualWindowSize.y.to!float).to!float;
	return scale;
}

unittest
{
	info("Starting a basic pix2scale test.");
	auto actualSize = Vector2f(100,200);
	auto desiredSize = Vector2f(100,200);
	auto initialWindowSize = Vector2i(100,200);
	auto actualWindowSize = Vector2i(100,200);
	auto scale = pix2scale(actualSize, desiredSize, initialWindowSize, actualWindowSize);
	assert(scale.x == 1);
	assert(scale.y == 1);
	info("Completed the basic pix2scale test.");
}
unittest
{
	info("Starting a pix2scale test for window resizing.");
	auto actualSize = Vector2f(100,200);
	auto desiredSize = Vector2f(100,200);
	auto initialWindowSize = Vector2i(100,200);
	auto actualWindowSize = Vector2i(150,100);
	auto scale = pix2scale(actualSize, desiredSize, initialWindowSize, actualWindowSize);
	assert(scale.x == 2f/3f, "Scale x = " ~scale.x.to!string);
	assert(scale.y == 2f, "Scale y = " ~scale.y.to!string);
	info("Completed a pix2scale test for window resizing.");
}
unittest
{
	info("Starting a pix2scale test for the original resizing.");
	auto actualSize = Vector2f(100,200);
	auto desiredSize = Vector2f(150,400);
	auto initialWindowSize = Vector2i(100,200);
	auto actualWindowSize = Vector2i(100,200);
	auto scale = pix2scale(actualSize, desiredSize, initialWindowSize, actualWindowSize);
	assert(scale.x == 1.5f, "Scale x = " ~scale.x.to!string);
	assert(scale.y == 2f, "Scale y = " ~scale.y.to!string);
	info("Completed a pix2scale test for ordinary resizing.");
}

public void LoadSpriteAndTexture(TSprite)(ref TSprite sprite, ref Texture texture,
					string filename) 
{ 
	mixin(textureMixin!("filename"));
}

public void SetTextureToSprite(Sprite sprite, Texture texture)
{
	texture.setSmooth(true);
	sprite.setTexture(texture);
}

private template textureMixin(string arguments)
{
	const char[] textureMixin = 
	`if(texture is null) texture = new Texture;
	if(!texture.Load(` ~ arguments ~ `))
	{
		return;
	}
	SetTextureToSprite(sprite, texture);`;
}

private const string FILE_NOT_FOUND_ERROR_LOGGER = `error("File not found : ", filename);`;
private const string NEW_SPRITE_NEW_TEXTURE = `sprite = new Sprite; texture = new Texture;`;

/+unittest
{
	info("Starting check on reference influence.");
	Sprite sprite;
	Texture texture;
	assert(sprite is null);
	assert(texture is null);
	LoadSpriteAndTexture(sprite, texture, "");
	assert(sprite !is null);
	assert(texture !is null);
	info("Out can alter the actual pointer.");
}
unittest
{
	import mangareader.resizingsprite;
	info("Check templates for subclasses");
	ResizingSprite sprite;
	Texture texture;
	LoadSpriteAndTexture(sprite, texture, "");
	assert(sprite !is null);
	info("Template succesfully fills subclasses");
}+/

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
public FloatRect getGlobalBounds(RenderTarget window)
{
   auto size = window.getSize;
   return FloatRect(0, 0, size.x, size.y);
}
