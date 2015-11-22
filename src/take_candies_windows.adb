with Giza.Colors; use Giza.Colors;
with Giza.Timers;
with Giza.GUI;
with Candy_Dispenser;

package body Take_Candies_Windows is

   -------------
   -- On_Init --
   -------------

   overriding procedure On_Init
     (This : in out Take_Candies_Window)
   is
   begin
      null;
   end On_Init;

   ------------------
   -- On_Displayed --
   ------------------

   overriding procedure On_Displayed
     (This : in out Take_Candies_Window)
   is
   begin
      This.Cnt := 10;
      --  Reset timer
      This.Repeat_Evt.Win := This'Unchecked_Access;
      Giza.Timers.Set_Timer (This.Repeat_Evt'Unchecked_Access,
                             Clock + This.Repeat_Time);
      Candy_Dispenser.Enable_Dispenser;
   end On_Displayed;

   ---------------
   -- On_Hidden --
   ---------------

   overriding procedure On_Hidden
     (This : in out Take_Candies_Window)
   is
   begin
      This.Repeat_Evt.Win := null;
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
        ((25, 0), (This.Get_Size.W - 50, This.Get_Size.H / 2));
   begin
      if Force then
         Ctx.Set_Color (White);
         Ctx.Fill_Rectangle (Ctx.Bounds);
         Ctx.Set_Color (Black);
         Ctx.Print_In_Rect ("Take your candies!", Text_Box);

         Ctx.Set_Color (Green);
         Ctx.Fill_Rectangle (((0, Text_Box.Size.H),
                             (This.Get_Size.W,
                              Text_Box.Size.W / 10)));
      end if;

      Ctx.Set_Color (White);
      Ctx.Fill_Rectangle ((((This.Get_Size.W / 10) * This.Cnt,
                          Text_Box.Size.H),
                          ((This.Get_Size.W / 10),
                           Text_Box.Size.W / 10)));
   end Draw;

   ---------------
   -- Triggered --
   ---------------

   overriding function Triggered
     (This : Repeat_Event)
      return Boolean
   is
   begin
      if This.Win /= null then
         if This.Win.Cnt = 0 then
            Candy_Dispenser.Disable_Dispenser;
            Giza.GUI.Pop;
         else
            This.Win.Cnt := This.Win.Cnt - 1;
            This.Win.Set_Dirty;

            --  Reset timer
            Giza.Timers.Set_Timer (This'Unchecked_Access,
                                   Clock + This.Win.Repeat_Time);
         end if;
         return True;
      else
         return False;
      end if;
   end Triggered;

end Take_Candies_Windows;
