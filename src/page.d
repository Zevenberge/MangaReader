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

   private DTexture _texture;

   /**
     Fetches the currently loaded texture, if any. Else, it returns null.
   */
   public DTexture Texture()
   {
     return _texture;
   }

   /**
     Manually deletes the texture from the memory. Make sure no references are pointing to the texture to avoid segmentation faults.
   */
   public bool UnloadTexture()
   {
   	 info("Unloading texture from ", _filename);
     scope(failure) return false;
     destroy(_texture);
     return true;
   }

   /**
     Loads the texture from the file. Verboses if the file is not loaded. Returns whether the file is loaded.
   */
   public bool LoadTexture()
   {
   	  info("Loading texture from ", _filename);
      _texture = new DTexture();
      if(!_texture.loadFromFile(_filename))
      {
        error("File ", _filename, "not found.");
        return false;
      }
      trace("Succesfully loaded texture.");
      return true;
   }
}
