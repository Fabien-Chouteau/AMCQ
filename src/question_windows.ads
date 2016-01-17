with Giza.Windows;
with Giza.Widgets.Text; use Giza.Widgets.Text;
with Giza.Widgets.Button; use Giza.Widgets.Button;
with Giza.Events; use Giza.Events;
with Giza.Types; use Giza.Types;
with Take_Candies_Windows; use Take_Candies_Windows;

package Question_Windows is

   subtype Parent is Giza.Windows.Window;
   type Question_Window is new Parent with private;
   type Question_Window_Ref is access all Question_Window;

   overriding
   procedure On_Init (This : in out Question_Window);
   overriding
   procedure On_Displayed (This : in out Question_Window);
   overriding
   procedure On_Hidden (This : in out Question_Window);

   overriding
   function On_Position_Event
     (This : in out Question_Window;
      Evt  : Position_Event_Ref;
      Pos  : Point_T) return Boolean;

   type Answer_Type is (Answer_A, Answer_B, Answer_C, Answer_D);

   procedure Set_Question (This : in out Question_Window;
                           Q, A, B, C, D : String;
                           Answer : Answer_Type);
private

   type Timeout_Event is new Timer_Event with record
      Win : Question_Window_Ref := null;
   end record;

   overriding
   function Triggered (This : Timeout_Event) return Boolean;

   type State_Type is (Waiting_For_Answer, Showing_Success, Showing_Failure);
   type Answer_Buttons is array (Answer_Type) of aliased Gbutton;

   type Question_Window is new Giza.Windows.Window with record
      Q_Text       : aliased Gtext;
      Buttons      : Answer_Buttons;
      Answer       : Answer_Type := Answer_A;
      State        : State_Type := Waiting_For_Answer;
      Take_Candies : aliased Take_Candies_Window;
      Evt          : aliased Timeout_Event;
   end record;
end Question_Windows;
