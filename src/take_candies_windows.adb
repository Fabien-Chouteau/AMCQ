with Giza.Colors; use Giza.Colors;

with hand;
with Candy_Dispenser;

package body Take_Candies_Windows is

   -------------
   -- On_Init --
   -------------

   overriding procedure On_Init
     (This : in out Take_Candies_Window)
   is
      pragma Unreferenced (This);
   begin
      null;
   end On_Init;

   ------------------
   -- On_Displayed --
   ------------------

   overriding procedure On_Displayed
     (This : in out Take_Candies_Window)
   is
      pragma Unreferenced (This);
   begin
      Candy_Dispenser.Enable_Dispenser;
   end On_Displayed;

   ---------------
   -- On_Hidden --
   ---------------

   overriding procedure On_Hidden
     (This : in out Take_Candies_Window)
   is
   begin
      null;
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
        ((130, 60), (180, 80));
      Text_Box_2 : constant Rect_T :=
        ((130, 110), (180, 80));
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
   end Draw;

end Take_Candies_Windows;
