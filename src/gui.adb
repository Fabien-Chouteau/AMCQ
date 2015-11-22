with Screen_Interface; use Screen_Interface;
with LCD_Graphic_Backend;
with Giza.Colors;
with Giza.GUI;
with Giza.Graphics;
with STM32F4; use STM32F4;
with Hershey_Fonts.Rowmand;
with Ada.Synchronous_Task_Control;
with System;
with Giza.Events; use Giza.Events;
with Ada.Real_Time; use Ada.Real_Time;
with Question_Windows;
with STM32F4.RNG.Polling;

package body GUI is

   function As_Color (R, G, B : Giza.Colors.RGB_Component)
                      return Screen_Interface.Color;

   procedure Set_Pixel_Paysage (A, B : Natural; Col : Color);

      package LCD_Backend is new LCD_Graphic_Backend
     (Color => Screen_Interface.Color,
      Width => Screen_Interface.Height,
      Height => Screen_Interface.Width,
      Set_Pixel => Set_Pixel_Paysage,
      As_Color => As_Color);

   Backend : aliased LCD_Backend.LCD_Backend;
   Context : aliased Giza.Graphics.Context;
   Main_W  : aliased Question_Windows.Question_Window;

   Sync : Ada.Synchronous_Task_Control.Suspension_Object;

   ---------------
   -- Set_Pixel --
   ---------------

   procedure Set_Pixel_Paysage (A, B : Natural; Col : Color) is
   begin
        Screen_Interface.Set_Pixel (Width'Last - B, A, Col);
   end Set_Pixel_Paysage;

   --------------
   -- As_Color --
   --------------

   function As_Color (R, G, B : Giza.Colors.RGB_Component)
                      return Screen_Interface.Color
   is
      RF : constant Float := (Float (R) / 255.0) * 31.0;
      GF : constant Float := (Float (G) / 255.0) * 31.0;
      BF : constant Float := (Float (B) / 255.0) * 31.0;
   begin
      return 16#8000# or
        (Screen_Interface.Color (RF) * (2**10))
        or (Screen_Interface.Color (GF) * (2**5))
        or Screen_Interface.Color (BF);
   end As_Color;

   task Touch_Screen is
      pragma Priority (System.Default_Priority - 1);
   end Touch_Screen;

   task body Touch_Screen is
      TS, Prev : Touch_State;
      Click_Evt : constant Click_Event_Ref := new Click_Event;
      Release_Evt : constant  Click_Released_Event_Ref
        := new Click_Released_Event;
   begin
      Ada.Synchronous_Task_Control.Suspend_Until_True (Sync);

      Prev.Touch_Detected := False;
      loop
         --STM32F4.Touch_Panel.Wait_For_Touch_Detected;
         TS := Current_Touch_State;

         if TS.Touch_Detected /= Prev.Touch_Detected then

            if TS.Touch_Detected then
               Click_Evt.Pos.X := TS.Y;
               Click_Evt.Pos.Y := Screen_Interface.Width'Last - TS.X;
               Giza.GUI.Emit (Event_Not_Null_Ref (Click_Evt));
            else
               Giza.GUI.Emit (Event_Not_Null_Ref (Release_Evt));
            end if;
         end if;
         Prev := TS;
         delay until Clock + Milliseconds (50);
      end loop;
   end Touch_Screen;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      Screen_Interface.Initialize;
      Giza.GUI.Set_Backend (Backend'Access);

      Context.Set_Font (Hershey_Fonts.Rowmand.Font);
      Giza.GUI.Set_Context (Context'Access);
   end Initialize;

   -----------
   -- Start --
   -----------

   procedure Start is
   begin
      Giza.GUI.Push (Main_W'Access);

      Ada.Synchronous_Task_Control.Set_True (Sync);
      Giza.GUI.Event_Loop;
   end Start;

   ------------
   -- Random --
   ------------

   function Random (Modulo : Unsigned_32) return Unsigned_32 is
      Rand_Exess : constant Unsigned_32 := (Unsigned_32'Last mod Modulo) + 1;
      Rand_Linit : constant Unsigned_32 := Unsigned_32'Last - Rand_Exess;
      Ret : Unsigned_32;
   begin
      loop
         Ret := STM32F4.RNG.Polling.Random;
         exit when Ret <= Rand_Linit;
      end loop;
      return Ret mod Modulo;
   end Random;


end GUI;
