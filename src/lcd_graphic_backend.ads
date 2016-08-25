with Giza.Colors;
with HAL;
with HAL.Bitmap;
with Giza.Backends; use Giza.Backends;
with Giza.Types; use Giza.Types;

-------------------------
-- LCD_Graphic_Backend --
-------------------------

package LCD_Graphic_Backend is

   procedure Initialize;

   type LCD_Backend is new Backend with private;

   overriding
   procedure Set_Pixel (This : in out LCD_Backend; Pt : Point_T);

   overriding
   procedure Set_Color (This : in out LCD_Backend; C : Giza.Colors.Color);

   overriding
   function Size (This : LCD_Backend) return Size_T;

   overriding
   function Has_Double_Buffring (This : LCD_Backend) return Boolean;

   overriding
   procedure Swap_Buffers (This : in out LCD_Backend);

   overriding
   procedure Rectangle (This : in out LCD_Backend; Start, Stop : Point_T);

   overriding
   procedure Fill_Rectangle (This : in out LCD_Backend; Start, Stop : Point_T);


private
   type LCD_Backend is new Backend with record
      RGB_Color : HAL.Bitmap.Bitmap_Color;
   end record;
end LCD_Graphic_Backend;
