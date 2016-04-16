module mangareader.resizingsprite;

import dsfml.graphics;
import std.experimental.logger;
import std.conv;
import std.format;
import mangareader.helpers;

public class ResizingSprite : Sprite
{
	alias BoundsFunction = IntRect function (FloatRect, Vector2u);
	public BoundsFunction boundsCalculation;
	private Vector2i _initialWindowSize;
	private Vector2f _desiredSize;
	private FloatRect _previousSize;
	
	public this(Vector2i initialWindowSize, Vector2i desiredSize)
	{
		auto desiredSizeAsFloat = Vector2f(desiredSize.x, desiredSize.y);
		this(initialWindowSize, desiredSizeAsFloat);
	
	}
	
	public this(Vector2i initialWindowSize, Vector2f desiredSize)
	{
		_initialWindowSize = initialWindowSize;
		_desiredSize = desiredSize;
	}
	
	~this()
	{
		debug
		{
			trace("Destroying ", name);
		}
	}
	debug
	{
		public string name;
	}
	
	public void draw(RenderTarget target)
	{
		if(isResized(target))
		{
			info("Window is resized");
			onTargetResize(target.getGlobalBounds);
		}
		target.draw(this);
	}
	
	public void loadTextureFromFile(string filename)
	{
		Texture texture;
		LoadSpriteAndTexture(this, texture, filename);
	}
	
	private bool isResized(RenderTarget target)
	{
		if(_previousSize == target.getGlobalBounds) return false;
		_previousSize = target.getGlobalBounds;
		return true;
	}
	
	private void onSourceResize()
	{
		onTargetResize(_previousSize);
	}
	
	private void onTargetResize(FloatRect newTargetSize)
	{
		debug info("Attempting to resize ", name);
		if(boundsCalculation is null) 
		{
			info("ResizingSprite could not resize - transformation not given.");
			return;
		}
		trace("Resizing sprite.");
		textureRect = boundsCalculation(newTargetSize, getTexture.getSize);
		trace("New texture rectangle: L:%s | T:%s | W:%s | H:%s"
			.format(textureRect.left, textureRect.top, textureRect.width, textureRect.height));
		Vector2i newWindowSize;
		newWindowSize.x = newTargetSize.width.to!int;
		newWindowSize.y = newTargetSize.height.to!int;
		scale = pix2scale(textureRect.toVector, newWindowSize, _initialWindowSize, newWindowSize);
		trace("Scale is (", scale.x, ",", scale.y, ").");
	}
	
	public override void setTexture(const Texture texture, bool rectReset = false)
	{
		info("Texture changed.");
		super.setTexture(texture, rectReset);
		onSourceResize;
		trace("Finished changing and scaling texture.");
	}
}