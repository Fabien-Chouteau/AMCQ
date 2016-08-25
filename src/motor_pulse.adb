with STM32;       use STM32;
with STM32.GPIO;  use STM32.GPIO;
with STM32.Device;
use STM32.Device;

package body Motor_Pulse is

   Motor_Pin  : GPIO_Point renames PG10;  --  D8 on the STM32F469-disco

   ----------------
   -- Initialize --
   ----------------

   procedure  Initialize is
      Config : GPIO_Port_Configuration;
   begin

      Enable_Clock (Motor_Pin);

      Config.Mode := Mode_Out;
      Config.Speed := Speed_100MHz;
      Config.Resistors := Pull_Down;
      Config.Output_Type := Push_Pull;

      Motor_Pin.Configure_IO (Config);

      Motor_Pin.Clear;
   end Initialize;

   -----------
   -- Start --
   -----------

   overriding procedure Start (Self : in out Motor_Pulse_Controller)
   is
      pragma Unreferenced (Self);
   begin
      Motor_Pin.Set;
   end Start;

   ----------
   -- Stop --
   ----------

   overriding procedure Stop (Self : in out Motor_Pulse_Controller)
   is
      pragma Unreferenced (Self);
   begin
      Motor_Pin.Clear;
   end Stop;

end Motor_Pulse;
