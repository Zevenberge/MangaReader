module mangareader.resizingsprite;

import dsfml.graphics;
import std.experimental.logger;
import mangareader.helpers;

public class ResizingSprite : Sprite
{
	alias BoundsFunction = IntRect function (FloatRect);
	public BoundsFunction boundsCalculation;
	
	public void draw(RenderTarget target)
	{
		if(isResized(target))
		{
			onTargetResize;
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
		return false;
	}
	
	private void onTargetResize()
	{
		if(boundsCalculation is null) 
		{
			info("ResizingSprite could not resize - transformation not given.");
			return;
		}
		
	}
}