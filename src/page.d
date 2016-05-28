module mangareader.page;

import dsfml.graphics;
import std.stdio;
import std.experimental.logger;

public class Page
{
   alias DTexture = dsfml.graphics.Texture;
   private string _filename;

   public this(string filename)
   {
   	 _filename = filename;
   }
   /**
     Returns the filename of the manga.
   */
   public string Filename()
   {
      return _filename;
   }

   /**
     Loads the texture from the file. Verboses if the file is not loaded. Returns whether the file is loaded.
   */
   public bool LoadTexture(DTexture texture)
   {
   	  info("Loading texture from ", _filename);
      if(!texture.loadFromFile(_filename))
      {
        error("File ", _filename, "not found.");
        return false;
      }
      trace("Succesfully loaded texture.");
      return true;
   }
}
