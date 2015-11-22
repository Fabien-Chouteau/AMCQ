with STM32F4;       use STM32F4;
with STM32F4.GPIO;  use STM32F4.GPIO;
with STM32F429_Discovery;

package body Motor_Pulse is

   Motor_Port : GPIO_Port renames STM32F429_Discovery.GPIO_E;
   Motor_Pin  : constant GPIO_Pin := Pin_6;

   ----------------
   -- Initialize --
   ----------------

   procedure  Initialize is
      Config : GPIO_Port_Configuration;
   begin

      STM32F429_Discovery.Enable_Clock (Motor_Port);

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
