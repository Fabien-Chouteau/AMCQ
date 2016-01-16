with Pulse_Control; use Pulse_Control;

--  This package provides an example of pulse controller

package LED_Pulse is

   type LED_Type is (Red, Green);

   type LED_Pulse_Controller (My_LED : LED_Type) is
     new Pulse_Controller with null record;

   overriding
   procedure Start (Self : in out LED_Pulse_Controller);
   overriding
   procedure Stop (Self : in out LED_Pulse_Controller);

   procedure Example with No_Return;
   --  Runs an example of pulse controller with LEDs

end LED_Pulse;
