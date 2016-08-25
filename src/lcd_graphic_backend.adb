with STM32; use STM32;
with STM32.Board; use STM32.Board;
with HAL.Bitmap; use HAL.Bitmap;
with HAL; use HAL;

package body LCD_Graphic_Backend is

   Initialized : Boolean := False;

   subtype Height is Integer range 0 .. 480 - 1;
   subtype Width is Integer range 0 .. 800 - 1;

   function Is_In_Screen (Pt : Point_T) return Boolean;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      if not Initialized then
         Initialized := True;

         --  Initialize LCD
         Display.Initialize;
         Display.Initialize_Layer (1, ARGB_8888);

         Display.Get_Hidden_Buffer (1).Fill ((Alpha => 255, others => 64));
         Display.Update_Layer (1, Copy_Back => True);
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
         Display.Get_Hidden_Buffer (1).Set_Pixel
           (X           => Pt.X,
            Y           => Pt.Y,
            Value       => This.RGB_Color);
      end if;
   end Set_Pixel;

   ---------------
   -- Set_Color --
   ---------------

   overriding procedure Set_Color (This : in out LCD_Backend; C : Giza.Colors.Color) is
   begin
      This.RGB_Color := (255, Byte (C.R), Byte (C.G), Byte (C.B));
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
      Display.Update_Layer (1, Copy_Back => False);
      Display.Get_Hidden_Buffer (1).Fill ((Alpha => 255, others => 64));
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
   begin
      if Is_In_Screen (Start) and then Is_In_Screen (Stop) then
         Display.Get_Hidden_Buffer (1).Draw_Rect (Color  => This.RGB_Color,
                                                  X      => X0,
                                                  Y      => Y0,
                                                  Width  => X1 - X0 + 1,
                                                  Height => Y1 - Y0 + 1);
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
         Display.Get_Hidden_Buffer (1).Fill_Rect (Color  => This.RGB_Color,
                                                  X      => X0,
                                                  Y      => Y0,
                                                  Width  => X1 - X0 + 1,
                                                  Height => Y1 - Y0 + 1);
      end if;
   end Fill_Rectangle;

end LCD_Graphic_Backend;
