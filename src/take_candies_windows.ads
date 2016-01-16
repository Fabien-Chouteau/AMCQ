with Giza.Windows; use Giza.Windows;
with Giza.Graphics; use Giza.Graphics;
with Giza.Widgets.Button; use Giza.Widgets.Button;
with Giza.Events; use Giza.Events;
with STM32.Board; use STM32.Board;
with Ada.Real_Time; use Ada.Real_Time;

package Take_Candies_Windows is

   subtype Parent is Window;
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

   overriding
   function On_Position_Event
     (This : in out Take_Candies_Window;
      Evt  : Position_Event_Ref;
      Pos  : Point_T) return Boolean;

private
   type Repeat_Event is new Timer_Event with record
      Win : Take_Candies_Window_Ref;
      Repeat_Time : Time_Span := Milliseconds (200);
   end record;

   overriding
   function Triggered (This : Repeat_Event) return Boolean;

   type Take_Candies_Window is new Window with record
      Repeat_Evt  : aliased Repeat_Event;
      No_Thanks   : aliased Gbutton;
      Current_LED : User_LED := Blue;
   end record;
end Take_Candies_Windows;
