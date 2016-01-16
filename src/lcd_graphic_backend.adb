with STM32.DMA2D.Polling; use STM32.DMA2D;
with STM32; use STM32;
with Double_Buffer;         use Double_Buffer;
with STM32.LCD; use STM32.LCD;

package body LCD_Graphic_Backend is

   Initialized : Boolean := False;

   Current_Buffer : DMA2D_Buffer;

   subtype Height is Integer range 0 .. STM32.LCD.Pixel_Height - 1;
   subtype Width is Integer range 0 .. STM32.LCD.Pixel_Width - 1;

   function Is_In_Screen (Pt : Point_T) return Boolean;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      if not Initialized then
         Initialized := True;

         STM32.LCD.Initialize;
         STM32.LCD.Set_Orientation (Landscape);
         STM32.DMA2D.Polling.Initialize;
         Double_Buffer.Initialize
           (Layer_Background => Layer_Single_Buffer,
            Layer_Foreground => Layer_Inactive);

         --  At init the draw layer is the one displayed, this will keep
         --  compatibility with projects not doing double buffering.
         Current_Buffer := Double_Buffer.Get_Visible_Buffer (Layer1);
      end if;
   end Initialize;

   ------------------
   -- Is_In_Screen --
   ------------------

   function Is_In_Screen (Pt : Point_T) return Boolean is
   begin
      return Pt.X in Dim (Width'First) .. Dim (Width'Last)
        and then
          Pt.Y in Dim (Height'First) .. Dim (Height'Last);
   end Is_In_Screen;

   ---------------
   -- Set_Pixel --
   ---------------

   overriding procedure Set_Pixel (This : in out LCD_Backend; Pt : Point_T) is
   begin
      if Is_In_Screen (Pt) then
         DMA2D_Set_Pixel (Buffer      => Current_Buffer,
                          X           => Pt.X,
                          Y           => Pt.Y,
                          Color       => This.Raw_Color);
      end if;
   end Set_Pixel;

   ---------------
   -- Set_Color --
   ---------------

   overriding procedure Set_Color (This : in out LCD_Backend; C : Giza.Colors.Color) is
   begin
      This.RGB_Color := (255, Byte (C.R), Byte (C.G), Byte (C.B));
      This.Raw_Color := DMA2D_Color_To_Word (Current_Buffer, This.RGB_Color);
   end Set_Color;

   ----------
   -- Size --
   ----------

   overriding function Size (This : LCD_Backend) return Size_T is
      pragma Unreferenced (This);
   begin
      return (Dim (Width'Last), Dim (Height'Last));
   end Size;

   -------------------------
   -- Has_Double_Buffring --
   -------------------------

   overriding function Has_Double_Buffring
     (This : LCD_Backend) return Boolean
   is
      pragma Unreferenced (This);
   begin
      return True;
   end Has_Double_Buffring;

   ------------------
   -- Swap_Buffers --
   ------------------

   overriding procedure Swap_Buffers (This : in out LCD_Backend) is
      pragma Unreferenced (This);
   begin
      Double_Buffer.Swap_Buffers (VSync => True);
      Current_Buffer := Double_Buffer.Get_Hidden_Buffer;
   end Swap_Buffers;

   ---------------
   -- Rectangle --
   ---------------

   overriding procedure Rectangle (This : in out LCD_Backend;
                                   Start, Stop : Point_T) is
      X0 : constant Integer := Start.X;
      Y0 : constant Integer := Start.Y;
      X1 : constant Integer := Stop.X;
      Y1 : constant Integer := Stop.Y;
      Thickness : constant Integer := 1;
   begin
      if Is_In_Screen (Start) and then Is_In_Screen (Stop) then
      DMA2D_Fill_Rect
        (Current_Buffer, This.RGB_Color,
         X0 - Thickness / 2, Y0,
         Thickness, Y1 - Y0);
      DMA2D_Fill_Rect
        (Current_Buffer, This.RGB_Color,
         X1 - Thickness / 2, Y0,
         Thickness, Y1 - Y0);
      DMA2D_Fill_Rect
        (Current_Buffer, This.RGB_Color,
         X0, Y0 - Thickness / 2,
         X1 - X0, Thickness);
      DMA2D_Fill_Rect
        (Current_Buffer, This.RGB_Color,
         X0, Y1 - Thickness / 2,
         X1 - X0, Thickness);
      end if;
   end Rectangle;

   --------------------
   -- Fill_Rectangle --
   --------------------

   overriding procedure Fill_Rectangle (This : in out LCD_Backend;
                                        Start, Stop : Point_T) is
      X0 : constant Integer := Dim'Min (Start.X, Stop.X);
      Y0 : constant Integer := Dim'Min (Start.Y, Stop.Y);
      X1 : constant Integer := Dim'Max (Start.X, Stop.X);
      Y1 : constant Integer := Dim'Max (Start.Y, Stop.Y);
   begin
      if Is_In_Screen (Start) and then Is_In_Screen (Stop) then
         DMA2D_Fill_Rect (Current_Buffer, This.RGB_Color,
                          X0, Y0, X1 - X0 + 1, Y1 - Y0 + 1);

      end if;
   end Fill_Rectangle;

end LCD_Graphic_Backend;
