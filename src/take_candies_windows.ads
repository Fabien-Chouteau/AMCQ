with Giza.Windows;
with Giza.Graphics; use Giza.Graphics;
with Giza.Events; use Giza.Events;
with Ada.Real_Time; use Ada.Real_Time;

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

   type Repeat_Event is new Timer_Event with record
      Win : Take_Candies_Window_Ref := null;
   end record;

   overriding
   function Triggered (This : Repeat_Event) return Boolean;

   type Take_Candies_Window is new Giza.Windows.Window with record
      Cnt : Integer := 0;
      Repeat_Time : Time_Span := Milliseconds (200);
      Repeat_Evt  : aliased Repeat_Event;
   end record;
end Take_Candies_Windows;
