with Pulse_Control; use Pulse_Control;

package Motor_Pulse is
   type Motor_Pulse_Controller is new Pulse_Controller with null record;

   overriding
   procedure Start (Self : in out Motor_Pulse_Controller);
   overriding
   procedure Stop (Self : in out Motor_Pulse_Controller);

   procedure Initialize;

end Motor_Pulse;
