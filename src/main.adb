with Ada.Real_Time;

with STM32F4.RCC; use STM32F4.RCC;
with GUI;
with Candy_Dispenser;
with STM32F4.RNG.Polling;

pragma Warnings (Off);
with Last_Chance_Handler;
pragma Warnings (On);

procedure Main is
begin
   STM32F4.RNG.Polling.Initialize_RNG;
   Candy_Dispenser.Initialize;
   GUI.Initialize;
   GUI.Start;

   --  The controller is all interrupt driven, we can set this task to sleep
   --  forever.
   delay until Ada.Real_Time.Time_Last;
end Main;
