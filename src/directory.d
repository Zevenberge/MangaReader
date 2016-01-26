module mangareader.directory;

import dsfml.graphics;
import std.path;
import std.conv;
import std.file;
import mangareader.style;
import mangareader.helpers;
/**
  The directory class that is used for navigation to the directory that holds the images. It is self-aware, i.e. the controller does only need to worry about what to do and not how to do it.
*/
public class Directory
{
    private Directory _parentDirectory;
    private Directory[] _childDirectories;
    private int _childSelection = 0;
    private Directory _currentChild() { return _childDirectories[_childSelection];}
    private bool _isSelected = false; // FIXME: Is _isSelected merely a verification tool now that all the selections return the selected directory? No, also used to draw the selection.
    private string _path;

    private Text _text;
    private RectangleShape _selection = new RectangleShape; // Abuse the bug that causes this to create only one instance of RectangleShape.

    /**
      Constructor that wants the absolute path of the directory. Throws an assertion if the path is not rooted.
    */
    public this(string absolutePath, Directory parentDirectory)
    in
    {
       assert(isRooted(absolutePath));
    }
    body
    {
       _path = absolutePath;
       _parentDirectory = parentDirectory;
       SetupGraphics();
    }

    /**
      Draws itself onto the provided window.
    */
    public void Draw(RenderWindow window)
    {
       if(_isSelected) 
       {
         window.draw(_selection);
       }
       
       if(!(_childDirectories is null))
       {
         foreach(directory; _childDirectories)
             directory.Draw(window);
       }
    }

    /**
      Gets the absolute path as provided to the constructor.
    */
    public string AbsolutePath()
    {
       return _path;
    }

    /**
       Gets the global bounds of the text. 
    */
    public auto getGlobalBounds()
    {
       return _text.getGlobalBounds;
    }

    /**
      Return whether this directory has directories loaded in memory.
    */
    private bool HasChildren()
    {
       return !(_childDirectories is null) && _childDirectories.length > 0;
    }

    /**
       Return the name of the directory, i.e. last part of the path.
    */
    public string Name()
    {
       return baseName(AbsolutePath);
    }

    /**
      Fetches all dirEntries that this directory has.
    */
    private auto Subdirectories()
    {
       //auto subFiles = dirEntries(AbsolutePath, SpanMode.shallow).where(d => d.isDir);
       auto subFiles = dirEntries(AbsolutePath, SpanMode.shallow);
       DirEntry[] subDirs;
       foreach(subFile; subFiles)
       {
          if(subFile.isDir) subDirs ~= subFile;
       }
       return subDirs;
    }

    /**
      Aligns the children such that, if a new parent directory is selected (i.e. /home/user => /home), the old entries are nicely aligned.
    */
    private void AlignChildren()
    {
       foreach(child; _childDirectories)
       {
          child.MoveRelativeToParent;
       }
    }

    /**
      Try to load the children regardless of whether they are already loaded in memory.
    */
    public void ForceLoadChildren()
    {
       auto subDirs = Subdirectories;
       foreach(subDir; subDirs)
       {
         Directory newDir = new Directory(subDir.name ,this);
         _childDirectories ~= newDir;
       }
    }

    /**
      Fetches the parent directory of the current directory.
    */
    private void GetParent()
    {
       string parentPath = AbsolutePath.GetParentDirectory;
       if(AbsolutePath == parentPath) return;
       auto parent = new Directory(parentPath, null);
       parent.LoadChild();
       foreach(i, child; parent._childDirectories)
       {
         if(child.AbsolutePath != this.AbsolutePath) continue;
         parent._childDirectories[i] = this;
         parent._childSelection = i.to!int;
       }
    }

    /**
      Load the children if they are not already loaded.
    */
    private void LoadChild()
    {
       if(HasChildren) return;
       ForceLoadChildren();
    }

    /**
       Moves the text and selection (if selected) relative to the parent directory. If the location is changed, this propagates to the child directories as well.
    */
    public void MoveRelativeToParent()
    {
       auto parentBounds = _parentDirectory.getGlobalBounds;
       MoveRelativeToSomething(parentBounds, 1);  
    }

    /**
      Meant to be called when the child directory goes out of bounds. As soon as the text is aligned, chain is to the parent and other children. 
    */
    public void MoveRelativeToSelectedChild()
    {
        auto childBounds = _childDirectories[_childSelection].getGlobalBounds;
        MoveRelativeToSomething(childBounds, -1);
        AlignChildren();
        if(_parentDirectory !is null)
        {
          _parentDirectory.MoveRelativeToSelectedChild;
        }
    }

    /**
      Moves the text relative to the bounds specified multiplied with the multiplier.
    */
    private void MoveRelativeToSomething(FloatRect bounds, float multiplier)
    {
         _text.position = 
            Vector2f(bounds.left + multiplier * Style.TextTabWidth,
                     bounds.top +  multiplier * Style.TextReturnSpace); 
    }

    /**
       Moves to the next directory, if there is one.
    */
    public Directory Next()
    {
      if(_parentDirectory !is null)
      {
        return _parentDirectory.SelectNextChild();
      }
      return this;
    }

    /**
       Moves to the previous directory, if there is one.
    */
    public Directory Previous()
    {
      if(_parentDirectory !is null)
      {
        return _parentDirectory.SelectPreviousChild;
      }
      return this;
    }

    /**
      Select this entry and place the selection nicely. As there is only one 'selection' in the whole program, move it every selection.
    */
    private Directory Select()
    {
       _isSelected = true;
       FloatRect textBounds = _text.getGlobalBounds;
       _selection.position = Vector2f(textBounds.left - Style.SelectionMargin, textBounds.top - Style.SelectionMargin);
       _selection.size = Vector2f(textBounds.width + 2*Style.SelectionMargin, textBounds.height + 2*Style.SelectionMargin);
       return this;
    }

    /**
      Moves selection from this to children.
    */
    public Directory SelectChild()
    {
       LoadChild();
       if(HasChildren)
       {
          this._isSelected = false;
          return _currentChild.Select();
       }
       return this;
    }

    /**
      Transfer the selection from the current child to the next child.
    */
    private Directory SelectNextChild()
    {
       _currentChild._isSelected = false;
       _childSelection = CorrectBounds(_childSelection + 1, _childDirectories.length);
       return _currentChild.Select;
    }

    /**
      Selects the parent directory. If there is none, try to load it.
    */
    public Directory SelectParent()
    {
       if(AbsolutePath == "/") return this;
       if(_parentDirectory is null) GetParent;
       this._isSelected = false;
       return _parentDirectory.Select;
    }

    /**
      Transfer the selection from the current child to the previous child.
    */
    private Directory SelectPreviousChild()
    {
       _currentChild._isSelected = false;
       _childSelection = CorrectBounds(_childSelection - 1, _childDirectories.length);
       return _currentChild.Select;
    }

    /**
       Makes preparations for the graphics.
    */
    private void SetupGraphics()
    {
       _text = new Text();
       _text.setFont(Style.DirectoryFont);
       _text.setString(Name);
       _text.setCharacterSize(Style.DirectoryCharacterSize);
       _text.setColor(Style.DirectoryTextColor);
    }
}
