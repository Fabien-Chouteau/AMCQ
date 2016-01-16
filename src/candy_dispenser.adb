with Ada.Interrupts.Names;
with Ada.Real_Time; use Ada.Real_Time;
with STM32;       use STM32;
with STM32.GPIO;  use STM32.GPIO;
with Motor_Pulse; use Motor_Pulse;
with LED_Pulse;
with STM32.Board; use STM32.Board;
with STM32.Device; use STM32.Device;
with STM32.SYSCFG; use STM32.SYSCFG;
with Giza.GUI;
with Giza.Events; use Giza.Events;
with STM32.EXTI; use STM32.EXTI;

package body Candy_Dispenser is
   Sensor_Port : GPIO_Port renames STM32.Device.GPIO_A;
   Sensor_Pin  : constant GPIO_Pin  := Pin_2; --  D5 on the STM32F469-disco

   protected Sensor is
      pragma Interrupt_Priority;

      procedure Enable;
      procedure Disable;
   private
      procedure Interrupt_Handler;
      pragma Attach_Handler
         (Interrupt_Handler,
          Ada.Interrupts.Names.EXTI2_Interrupt);

      Enabled       : Boolean := False;
      Motor_Control : Motor_Pulse_Controller;
      LED_Control   : LED_Pulse.LED_Pulse_Controller (LED_Pulse.Red);
      Redraw_Evt    : aliased Redraw_Event;
   end Sensor;

   ------------
   -- Sensor --
   ------------

   protected body Sensor is

      ------------
      -- Enable --
      ------------

      procedure Enable is
      begin
         Enabled := True;
      end Enable;

      -------------
      -- Disable --
      -------------

      procedure Disable is
      begin
         Enabled := False;
      end Disable;

      -----------------------
      -- Interrupt_Handler --
      -----------------------

      procedure Interrupt_Handler is
         Start, Stop : Time;
         Now : Ada.Real_Time.Time := Ada.Real_Time.Time_First;
      begin
         Clear_External_Interrupt (Sensor_Pin);

         if Enabled then
            --  What time is it?
            Now := Clock;

            --  Convert to start and stop time
            Start := Now   + Milliseconds (50);
            Stop  := Start + Milliseconds (600);

            --  Send the pulse command
            Motor_Control.Pulse (Start, Stop);

            --  Also start a LED pulse for a visual indication that the motor is
            --  on.
            LED_Control.Pulse (Start, Stop);

            --  Pop take_candies_window
            Giza.GUI.Pop;
            --  And ask for redraw
            Giza.GUI.Emit (Redraw_Evt'Access);

            Enabled := False;
         end if;
      end Interrupt_Handler;
   end Sensor;

   ----------------------
   -- Enable_Dispenser --
   ----------------------

   procedure Enable_Dispenser is
   begin
      Sensor.Enable;
   end Enable_Dispenser;

   -----------------------
   -- Disable_Dispenser --
   -----------------------

   procedure Disable_Dispenser is
   begin
      Sensor.Disable;
   end Disable_Dispenser;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
      Config : GPIO_Port_Configuration;
   begin
      STM32.Board.Initialize_LEDs;
      STM32.Board.All_LEDs_Off;

      Motor_Pulse.Initialize;

      STM32.Device.Enable_Clock (Sensor_Port);

      Config.Mode := Mode_In;
      Config.Speed := Speed_100MHz;
      Config.Resistors := Floating;

      Configure_IO (Sensor_Port, Sensor_Pin, Config);

      Connect_External_Interrupt (Sensor_Port, Sensor_Pin);
      Configure_Trigger (Sensor_Port, Sensor_Pin, Interrupt_Rising_Edge);
   end Initialize;

end Candy_Dispenser;
