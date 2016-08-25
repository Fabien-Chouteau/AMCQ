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

end LED_Pulse;
