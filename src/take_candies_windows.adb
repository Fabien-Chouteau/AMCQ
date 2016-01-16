with Giza.Colors; use Giza.Colors;
with Giza.GUI;
with hand;
with Candy_Dispenser;
with Giza.Timers;
with STM32.GPIO; use STM32.GPIO;

package body Take_Candies_Windows is

   -------------
   -- On_Init --
   -------------

   overriding procedure On_Init
     (This : in out Take_Candies_Window)
   is
      Bounds : constant Size_T := This.Get_Size;
   begin
      This.No_Thanks.Set_Text ("No, thanks!");
      This.No_Thanks.Set_Size (Bounds / 4);
      This.No_Thanks.Set_Background (White);
      This.No_Thanks.Set_Foreground (Black);
      This.Add_Child (This.No_Thanks'Unchecked_Access,
                      (Bounds.W - This.No_Thanks.Get_Size.W - 10,
                       Bounds.H - This.No_Thanks.Get_Size.H - 10));

      All_LEDs_Off;
   end On_Init;

   ------------------
   -- On_Displayed --
   ------------------

   overriding procedure On_Displayed
     (This : in out Take_Candies_Window)
   is
   begin
      This.No_Thanks.Set_Active (False);
      Candy_Dispenser.Enable_Dispenser;
      This.Repeat_Evt.Win := This'Unchecked_Access;
      Giza.Timers.Set_Timer (This.Repeat_Evt'Unchecked_Access,
                             Clock + This.Repeat_Evt.Repeat_Time);
   end On_Displayed;

   ---------------
   -- On_Hidden --
   ---------------

   overriding procedure On_Hidden
     (This : in out Take_Candies_Window)
   is
      pragma Unreferenced (This);
   begin
      This.Repeat_Evt.Win := null;
      All_LEDs_Off;
   end On_Hidden;

   ----------
   -- Draw --
   ----------

   overriding procedure Draw
     (This  : in out Take_Candies_Window;
      Ctx   : in out Context'Class;
      Force : Boolean := False)
   is
      Text_Box : constant Rect_T :=
        ((200, 10), (400, 200));
      Text_Box_2 : constant Rect_T :=
        ((200, 90), (400, 200));
   begin
      if Force then
         Ctx.Set_Color (White);
         Ctx.Fill_Rectangle (Ctx.Bounds);
         Ctx.Set_Color (Black);
         Ctx.Print_In_Rect ("Take your", Text_Box);
         Ctx.Print_In_Rect ("candies!", Text_Box_2);

         Ctx.Copy_Bitmap (hand.Data,
                          (0, This.Get_Size.H - hand.Data.H));
      end if;
      Draw (Parent (This), Ctx, Force);
   end Draw;

   -----------------------
   -- On_Position_Event --
   -----------------------

   overriding function On_Position_Event
     (This : in out Take_Candies_Window;
      Evt  : Position_Event_Ref;
      Pos  : Point_T) return Boolean
   is
   begin
      if On_Position_Event (Parent (This), Evt, Pos) then
         Giza.GUI.Pop;
         return True;
      else
         return False;
      end if;
   end On_Position_Event;

   ---------------
   -- Triggered --
   ---------------

   overriding function Triggered (This : Repeat_Event) return Boolean is
   begin
      if This.Win /= null then
         Turn_Off (This.Win.Current_LED);
         if This.Win.Current_LED = STM32.Board.Blue then
            This.Win.Current_LED := STM32.Board.Red;
         elsif This.Win.Current_LED = STM32.Board.Red then
            This.Win.Current_LED := STM32.Board.Orange;
         elsif This.Win.Current_LED = STM32.Board.Orange then
            This.Win.Current_LED := STM32.Board.Green;
         elsif This.Win.Current_LED = STM32.Board.Green then
            This.Win.Current_LED := STM32.Board.Blue;
         end if;
        Turn_On (This.Win.Current_LED);
         --  Reset timer
         Giza.Timers.Set_Timer (This'Unchecked_Access,
                                Clock + This.Repeat_Time);
      end if;
      return False;
   end Triggered;


end Take_Candies_Windows;
