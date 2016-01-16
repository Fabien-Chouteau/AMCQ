with STM32;       use STM32;
with STM32.GPIO;  use STM32.GPIO;
with STM32.Device;

package body Motor_Pulse is

   Motor_Port : GPIO_Port renames STM32.Device.GPIO_G;
   Motor_Pin  : constant GPIO_Pin := Pin_10;  --  D8 on the STM32F469-disco

   ----------------
   -- Initialize --
   ----------------

   procedure  Initialize is
      Config : GPIO_Port_Configuration;
   begin

      STM32.Device.Enable_Clock (Motor_Port);

      Config.Mode := Mode_Out;
      Config.Speed := Speed_100MHz;
      Config.Resistors := Pull_Down;
      Config.Output_Type := Push_Pull;

      Configure_IO (Motor_Port, Motor_Pin, Config);

      Clear (Motor_Port, Motor_Pin);
   end Initialize;

   -----------
   -- Start --
   -----------

   overriding procedure Start (Self : in out Motor_Pulse_Controller)
   is
      pragma Unreferenced (Self);
   begin
      Set (Motor_Port, Motor_Pin);
   end Start;

   ----------
   -- Stop --
   ----------

   overriding procedure Stop (Self : in out Motor_Pulse_Controller)
   is
      pragma Unreferenced (Self);
   begin
      Clear (Motor_Port, Motor_Pin);
   end Stop;

end Motor_Pulse;
