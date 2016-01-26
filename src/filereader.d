module mangareader.filereader;

import std.stdio;
import std.path;
import std.file;
import std.experimental.logger;
import std.algorithm;

class FileReader
{
    private string[] _extentions;
    
    /**
      Returns the pointer to the current listed possible file extentions.
    */
    public ref string[] Extentions()
    {
       return _extentions;
    }

    /**
      Adds a file extention to the existing list of extentions. Returns true if added succesfully, returns false if the extention was already in the list.
    */
    public bool AddExtention(string extention)
    {
       //if(_extentions is null) _extentions = new [];
       foreach(ext; _extentions)
         if(ext == extention)
            return false;
       _extentions ~= extention;
       return true;
    }
    
    /**
      Gets all images in the given directory given the file extentions. Returns them in alfabetic order.
    */
    public string[] GetFiles(string directory)
    {
    	string[] images;
    	foreach(ext; _extentions)
    	{
    		//TODO
    	}
    	info("Found ", images.length, " files.");
    	return images;
    }
}
