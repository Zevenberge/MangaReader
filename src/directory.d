module mangareader.directory;

import dsfml.graphics;
import std.range;
import std.path;
import std.conv;
import std.algorithm.comparison;
import std.algorithm.iteration;
import std.algorithm.sorting;
import std.file;
import std.experimental.logger;
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
    private bool _isVisible = true;
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
    { // Draw Upwards
    	if(_parentDirectory !is null) _parentDirectory.Draw(window);
    	else DrawDownwards(window);
    }
    
    /**
      Draws itself and its children on the provided window.
    */
    protected void DrawDownwards(RenderWindow window)
    {
    	if(!_isVisible) return;
       if(_isSelected) 
       {
         window.draw(_selection);
       }
       
       if(!(_childDirectories is null))
       {
         foreach(directory; _childDirectories)
             directory.DrawDownwards(window);
       }
       window.draw(_text);
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
        get the position of the text.
    */
    public @property auto position()
    {
    	return _text.position;
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
       auto subFiles = dirEntries(AbsolutePath, SpanMode.shallow)
       						.filter!(d => d.isDir && d.baseName[0] != '.');
       DirEntry[] subDirs;
       foreach(subFile; subFiles)
       {
          subDirs ~= subFile;
       }
	   subDirs.sort!((dirA, dirB) => dirA < dirB, SwapStrategy.unstable);
       return subDirs;
    }


    /**
      Try to load the children regardless of whether they are already loaded in memory.
    */
    public void ForceLoadChildren()
    {
    	try
    	{
       		auto subDirs = Subdirectories;
		   foreach(subDir; subDirs)
		   {
			 Directory newDir = new Directory(subDir.name ,this);
			 _childDirectories ~= newDir;
		   }
       	}
    	catch(FileException e)
    	{
    		info("Could not load children:", e.msg);
    		return;
    	}
       
	   PlaceChildren;
    }
    
    /**
    	Place the children, recursively.
    */
    private void PlaceChildren()
    {
    	if(_childDirectories.length == 0) return;
    	_childDirectories[0].MoveRelativeToParent;
    	for(int i = 1; i < _childDirectories.length; ++i)
    	{
    		auto bounds = _childDirectories[i-1].getGlobalBounds;
    		_childDirectories[i].MoveRelativeToSomething(bounds, 0f, 1f);
    	}
    	foreach(child; _childDirectories)
    	{
    		child.PlaceChildren;
    	}
    }

    /**
      Fetches the parent directory of the current directory.
    */
    private Directory GetParent()
    {
    	if(_parentDirectory !is null) return _parentDirectory;
       string parentPath = AbsolutePath.GetParentDirectory;
       if(AbsolutePath == parentPath) return this;
       auto parent = new Directory(parentPath, null);
       parent.LoadChild();
       foreach(i, child; parent._childDirectories)
       {
         if(child.AbsolutePath != this.AbsolutePath) continue;
         _text.position = child.position;
         parent._childDirectories[i] = this;
         parent._childSelection = i.to!int;
       }
       PlaceChildren;
       return _parentDirectory = parent;
    }
    
    /**
       Returns the largest width of all children.
    */
    private float GetMaximumChildWidth()
    {
    	auto widths = _childDirectories.map!(cd => cd.getGlobalBounds.width);
    	float maxWidth = 0f;
    	foreach(width; widths)
    	{
    		if(width > maxWidth) maxWidth = width;
    	}
    	return maxWidth;
    }
    
    /**
    	Returns the largest width of the current column.
    */
    private float GetMaximumWidth()
    {
    	if(_parentDirectory is null) return getGlobalBounds.width;
    	return _parentDirectory.GetMaximumChildWidth();
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
       parentBounds.width = _parentDirectory.GetMaximumWidth();
       MoveRelativeToSomething(parentBounds, 1f, 1f);  
    }

    /**
      Meant to be called when the child directory goes out of bounds. As soon as the text is aligned, chain is to the parent and other children. 
    */
    public void MoveRelativeToSelectedChild()
    {
        auto childBounds = _childDirectories[_childSelection].getGlobalBounds;
        MoveRelativeToSomething(childBounds, -1f, -1f);
        PlaceChildren();
        if(_parentDirectory !is null)
        {
          _parentDirectory.MoveRelativeToSelectedChild;
        }
    }

    /**
      Moves the text relative to the bounds specified multiplied with the multiplier.
    */
    private void MoveRelativeToSomething(FloatRect bounds, float horizontalMultiplier, float verticalMultiplier)
    {
         _text.position = 
            Vector2f(bounds.left + horizontalMultiplier * (Style.TextTabWidth + bounds.width),
                     bounds.top +  verticalMultiplier * Style.TextReturnSpace); 
    }

    /**
       Moves to the next directory, if there is one.
    */
    public Directory SelectNext()
    {
      if(_parentDirectory !is null)
      {
      	HideChildren;
        return _parentDirectory.SelectNextChild();
      }
      return this;
    }

    /**
       Moves to the previous directory, if there is one.
    */
    public Directory SelectPrevious()
    {
      if(_parentDirectory !is null)
      {
      	HideChildren;
        return _parentDirectory.SelectPreviousChild;
      }
      return this;
    }

    /**
      Select this entry and place the selection nicely. As there is only one 'selection' in the whole program, move it every selection.
    */
    public Directory SelectDirectory()
    {
       _isSelected = true;
       ShowChildren;
       FloatRect textBounds = _text.getGlobalBounds;
       _selection.position = Vector2f(textBounds.left - Style.SelectionMargin, textBounds.top - Style.SelectionMargin);
       _selection.size = Vector2f(textBounds.width + 2*Style.SelectionMargin, textBounds.height + 2*Style.SelectionMargin);
       _text.setColor(Style.SelectedTextColor);
       return this;
    }
    
    /**
      Unselect this entry.
    */
    public void UnselectDirectory()
    {
    	_isSelected = false;
    	_text.setColor(Style.DirectoryTextColor);
    }

    /**
      Moves selection from this to children.
    */
    public Directory SelectChild()
    {
       LoadChild();
       if(HasChildren)
       {
          this.UnselectDirectory;
          return _currentChild.SelectDirectory();
       }
       return this;
    }

    /**
      Transfer the selection from the current child to the next child.
    */
    private Directory SelectNextChild()
    {
       _currentChild.UnselectDirectory;
       _childSelection = CorrectBounds(_childSelection + 1, _childDirectories.length);
       return _currentChild.SelectDirectory;
    }
    
    /**
      Selects the parent directory. If there is none, try to load it.
    */
    public Directory SelectParent()
    {
       if(AbsolutePath == "/") return this;
       if(_parentDirectory is null) GetParent;
       this.UnselectDirectory;
       return _parentDirectory.SelectDirectory;
    }

    /**
      Transfer the selection from the current child to the previous child.
    */
    private Directory SelectPreviousChild()
    {
       _currentChild.UnselectDirectory;
       _childSelection = CorrectBounds(_childSelection - 1, _childDirectories.length);
       return _currentChild.SelectDirectory;
    }

    /**
       Makes preparations for the graphics.
    */
    private void SetupGraphics()
    {
    	_selection.fillColor(Style.SelectionBackgroundColor);
       _text = new Text();
       _text.setFont(Style.DirectoryFont);
       _text.setString(Name);
       _text.setCharacterSize(Style.DirectoryCharacterSize);
       _text.setColor(Style.DirectoryTextColor);
    }
    
    /**
      Hides the children from view.
    */
    private void HideChildren()
    {
    	_childDirectories.each!(cd => cd.Hide);
    }
    
    /**
      Turn invisible.
    */
    private void Hide()
    {
    	_isVisible = false;
    }
    
    /**
      Display the children.
    */
    private void ShowChildren()
    {
    	_childDirectories.each!(cd => cd.Show);
    }
    
    /**
      Turn visible.
    */
    private void Show()
    {
    	_isVisible = true;
    }
}





