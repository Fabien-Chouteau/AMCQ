with LCD_Graphic_Backend;
with Giza.GUI;
with Giza.Graphics;
with Giza.Bitmap_Fonts.FreeSerifItalic18pt7b;
with Ada.Synchronous_Task_Control;
with Question_Windows;
with STM32.RNG.Polling;
with System;
with Giza.Events; use Giza.Events;
with Ada.Real_Time; use Ada.Real_Time;
with STM32.Touch_Panel;
with STM32.GPIO; use STM32.GPIO;
with STM32.Board;
with Test_Main_Window;

package body GUI is

   Backend : aliased LCD_Graphic_Backend.LCD_Backend;
   Context : aliased Giza.Graphics.Context;
   Main_W  : aliased Question_Windows.Question_Window;
   Main_W_2  : aliased Test_Main_Window.Main_Window;

   Sync : Ada.Synchronous_Task_Control.Suspension_Object;

   type Touch_State is record
      Touch_Detected : Boolean;
      X : Natural;
      Y : Natural;
   end record;

   function Current_Touch_State return Touch_State;

   -------------------------
   -- Current_Touch_State --
   -------------------------

   function Current_Touch_State return Touch_State is
      TS    : Touch_State;
      ST_TS : constant STM32.Touch_Panel.TP_State :=
                STM32.Touch_Panel.Get_State;
   begin
      TS.Touch_Detected := ST_TS'Length > 0;

      if TS.Touch_Detected then
         TS.X := ST_TS (1).X;
         TS.Y := ST_TS (1).Y;
      else
         TS.X := 0;
         TS.Y := 0;
      end if;

      return TS;
   end Current_Touch_State;

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
               Click_Evt.Pos.X := TS.X;
               Click_Evt.Pos.Y := TS.Y;
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
      LCD_Graphic_Backend.Initialize;
      Giza.GUI.Set_Backend (Backend'Access);
      STM32.Touch_Panel.Initialize;
      Context.Set_Font (Giza.Bitmap_Fonts.FreeSerifItalic18pt7b.Font);
      Giza.GUI.Set_Context (Context'Access);
   end Initialize;

   -----------
   -- Start --
   -----------

   procedure Start is
   begin
      STM32.Board.Configure_User_Button_GPIO;

      --  Show the Giza Test window if the used button is pressed at init
      if Set (STM32.Board.User_Button_Point) then
         Giza.GUI.Push (Main_W_2'Access);
      else
         Giza.GUI.Push (Main_W'Access);
      end if;

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
         Ret := STM32.RNG.Polling.Random;
         exit when Ret <= Rand_Linit;
      end loop;
      return Ret mod Modulo;
   end Random;


end GUI;
