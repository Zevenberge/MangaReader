module mangareader.style;
import dsfml.graphics;
import mangareader.helpers;
public static class Style
{
	public static const int InitialWindowWidth = 1800;
	public static const int InitialWindowHeight = 900;
	
   public static const int SelectionMargin = 5;
   public static const int TextTabWidth = 20;
   public static const int TextReturnSpace = 18;

   private static const string _fontFile = "res/LiberationSans-Regular.ttf";
   private static Font _regularFont;
   public static Font RegularFont()
   {
     if(!(_regularFont is null))
        return _regularFont;
     _regularFont = new Font;
     Load(_regularFont,_fontFile);
     return _regularFont;
   }

   public static Font DirectoryFont()
   {
      return RegularFont;
   }
   public static const int DirectoryCharacterSize = 14;
   public static Color DirectoryTextColor()
   {
      return TextColor;
   }

   public static const Color TextColor = Color.Black;
   public static const Color SelectedTextColor = Color(126,255,255,255);
   public static const Color SelectionBackgroundColor = Color.Red;
   public static const Color BackgroundColor = Color.White;
}
