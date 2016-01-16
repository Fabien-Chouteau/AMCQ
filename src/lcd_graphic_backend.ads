with Giza.Graphics; use Giza.Graphics;
with Giza.Colors;
with STM32;
with STM32.DMA2D;

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
      Raw_Color : STM32.Word;
      RGB_Color : STM32.DMA2D.DMA2D_Color;
   end record;
end LCD_Graphic_Backend;
