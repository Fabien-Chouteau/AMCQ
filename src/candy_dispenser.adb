with Ada.Interrupts.Names;
with Ada.Real_Time; use Ada.Real_Time;
with STM32;       use STM32;
with STM32.GPIO;  use STM32.GPIO;
with Motor_Pulse; use Motor_Pulse;
with LED_Pulse;
with STM32.Board; use STM32.Board;
with STM32.Device; use STM32.Device;
with Giza.GUI;
with Giza.Events; use Giza.Events;
with STM32.EXTI; use STM32.EXTI;

package body Candy_Dispenser is
   Sensor_Pin : GPIO_Point renames PA2; --  D5 on the STM32F469-disco
   EXTI_Line : constant External_Line_Number :=
     Sensor_Pin.Get_Interrupt_Line_Number;

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
         Clear_External_Interrupt (EXTI_Line);

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
   begin
      STM32.Board.Initialize_LEDs;
      STM32.Board.All_LEDs_Off;

      Motor_Pulse.Initialize;

      Enable_Clock (Sensor_Pin);

      Sensor_Pin.Configure_IO
        ((Mode        => Mode_In,
          Output_Type => Open_Drain,
          Speed       => Speed_50MHz,
          Resistors   => Floating));

      --  Connect the button's pin to the External Interrupt Handler
      Sensor_Pin.Configure_Trigger (Interrupt_Rising_Edge);
   end Initialize;

end Candy_Dispenser;
