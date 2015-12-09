with Giza.Windows;
with Giza.Graphics; use Giza.Graphics;

package Take_Candies_Windows is

   subtype Parent is Giza.Windows.Window;
   type Take_Candies_Window is new Parent with private;
   type Take_Candies_Window_Ref is access all Take_Candies_Window;
   overriding
   procedure On_Init (This : in out Take_Candies_Window);
   overriding
   procedure On_Displayed (This : in out Take_Candies_Window);
   overriding
   procedure On_Hidden (This : in out Take_Candies_Window);

   overriding
   procedure Draw (This  : in out Take_Candies_Window;
                   Ctx   : in out Context'Class;
                   Force : Boolean := False);
private
   type Take_Candies_Window is new Giza.Windows.Window with null record;
end Take_Candies_Windows;
