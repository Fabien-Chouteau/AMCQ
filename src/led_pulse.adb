with Ada.Real_Time; use Ada.Real_Time;
with STM32.Board;

package body LED_Pulse is

   -----------
   -- Start --
   -----------

   overriding procedure Start (Self : in out LED_Pulse_Controller)
   is
   begin
      case Self.My_LED is
         when Red => STM32.Board.Turn_On (STM32.Board.Red);
         when Green => STM32.Board.Turn_On (STM32.Board.Green);
      end case;
   end Start;

   ----------
   -- Stop --
   ----------

   overriding procedure Stop (Self : in out LED_Pulse_Controller)
   is
   begin
      case Self.My_LED is
         when Red => STM32.Board.Turn_Off (STM32.Board.Red);
         when Green => STM32.Board.Turn_Off (STM32.Board.Green);
      end case;
   end Stop;

   -------------
   -- Example --
   -------------

   procedure Example is
      Green_Ctrl : LED_Pulse_Controller (Green);
      Red_Ctrl   : LED_Pulse_Controller (Red);
      Now        : Time;
   begin

      loop
         Now := Clock;
         Pulse (Green_Ctrl, Now + Seconds (1), Now + Seconds (2));
         Pulse (Red_Ctrl, Now + Seconds (1), Now + Seconds (3));

         delay until Now + Seconds (3);
      end loop;
   end Example;

end LED_Pulse;
