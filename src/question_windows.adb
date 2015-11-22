with Ada.Real_Time; use Ada.Real_Time;
with Giza.Widgets; use Giza.Widgets;
with Giza.Windows; use Giza.Windows;
with Giza.Colors; use Giza.Colors;
with Giza.GUI;
with Giza.Timers;
with Questions_Database;

package body Question_Windows is

   Default_Fg : constant Color := Black;
   Default_Bg : constant Color := White;
   Success_Fg : constant Color := White;
   Success_Bg : constant Color := Forest_Green;
   Failure_Fg : constant Color := Black;
   Failure_Bg : constant Color := Red;

   procedure Set_Colors (This : in out Question_Window;
                         Answer : Answer_Type;
                         Fg, Bg : Color);

   ----------------
   -- Set_Colors --
   ----------------

   procedure Set_Colors (This : in out Question_Window;
                         Answer : Answer_Type;
                         Fg, Bg : Color)
   is
   begin
      This.Buttons (Answer).Set_Background (Bg);
      This.Buttons (Answer).Set_Foreground (Fg);
      This.Buttons (Answer).Set_Dirty;
   end Set_Colors;

   -------------
   -- On_Init --
   -------------

   overriding procedure On_Init
     (This : in out Question_Window)
   is
      Q_Size : constant Size_T := (This.Get_Size.W, This.Get_Size.H / 3);
      A_Size : constant Size_T := (This.Get_Size.W / 2,
                                   This.Get_Size.H / 3);
   begin
      This.Evt.Win := This'Unchecked_Access;

      This.Q_Text.Set_Size (Q_Size);
      This.Q_Text.Set_Text ("No Question...");
      This.Add_Child (This.Q_Text'Unchecked_Access, (0, 0));

      for Answer in Answer_Type loop

         This.Buttons (Answer).Set_Size (A_Size);
         This.Buttons (Answer).Set_Text ("");
      end loop;

      This.Add_Child (This.Buttons (Answer_A)'Unchecked_Access,
                      (0, Q_Size.H + 1));

      This.Add_Child (This.Buttons (Answer_B)'Unchecked_Access,
                      (A_Size.W + 1, Q_Size.H + 1));

      This.Add_Child (This.Buttons (Answer_C)'Unchecked_Access,
                      (0, Q_Size.H + A_Size.H + 2));

      This.Add_Child (This.Buttons (Answer_D)'Unchecked_Access,
                      (A_Size.W + 1, Q_Size.H + A_Size.H + 2));
   end On_Init;

   ------------------
   -- On_Displayed --
   ------------------

   overriding procedure On_Displayed
     (This : in out Question_Window)
   is
   begin
      Questions_Database.Set_New_Question (This);
   end On_Displayed;

   ---------------
   -- On_Hidden --
   ---------------

   overriding procedure On_Hidden
     (This : in out Question_Window)
   is
   begin
      null;
   end On_Hidden;

   -----------------------
   -- On_Position_Event --
   -----------------------

   overriding function On_Position_Event
     (This : in out Question_Window;
      Evt  : Position_Event_Ref;
      Pos  : Point_T)
      return Boolean
   is
   begin
      if This.State /= Waiting_For_Answer then
         return False;
      end if;

      if On_Position_Event (Parent (This), Evt, Pos) then
         for Answer in Answer_Type loop
            if This.Buttons (Answer).Active then
               This.Buttons (Answer).Set_Active (False);

               if Answer = This.Answer then
                  --  Correct answer
                  Set_Colors (This, Answer, Success_Fg, Success_Bg);

                  This.State := Showing_Success;
                  Giza.Timers.Set_Timer (This.Evt'Unchecked_Access,
                                         Clock + Milliseconds (500));
               else
                  --  Wrong answer
                  Set_Colors (This, Answer, Failure_Fg, Failure_Bg);

                  --  The correct answer was...
                  Set_Colors (This, This.Answer, Success_Fg, Success_Bg);
                  This.Buttons (This.Answer).Set_Dirty;

                  This.State := Showing_Failure;
                  Giza.Timers.Set_Timer (This.Evt'Unchecked_Access,
                                         Clock + Seconds (3));
               end if;
               return True;
            end if;
         end loop;
      end if;
      return False;
   end On_Position_Event;

   ------------------
   -- Set_Question --
   ------------------

   procedure Set_Question
     (This : in out Question_Window;
      Q, A, B, C, D : String;
      Answer : Answer_Type)
   is
   begin
      This.Answer := Answer;
      This.Q_Text.Set_Text (Q);
      This.Q_Text.Set_Dirty;

      This.Buttons (Answer_A).Set_Text (A);
      This.Buttons (Answer_B).Set_Text (B);
      This.Buttons (Answer_C).Set_Text (C);
      This.Buttons (Answer_D).Set_Text (D);

      for Answer in Answer_Type loop
         This.Buttons (Answer).Set_Active (False);
         Set_Colors (This, Answer, Default_Fg, Default_Bg);
      end loop;
      This.State := Waiting_For_Answer;
   end Set_Question;

   ---------------
   -- Triggered --
   ---------------

   overriding
   function Triggered (This : Timeout_Event) return Boolean is
   begin
      if This.Win /= null then
         if This.Win.State = Showing_Failure then
            --  New question...
            This.Win.On_Displayed;
            return True;
         elsif This.Win.State = Showing_Success then
            --  You can take candies!!!
            Giza.GUI.Push (This.Win.Take_Candies'Unchecked_Access);
         end if;
      end if;
      return False;
   end Triggered;

end Question_Windows;
