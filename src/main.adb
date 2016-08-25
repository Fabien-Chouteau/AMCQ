with Ada.Real_Time; use Ada.Real_Time;

--  with STM32F4.RCC; use STM32F4.RCC;
with GUI;
with Candy_Dispenser;
with STM32.RNG.Polling;

with Interfaces;

procedure Main is
   Unused : Interfaces.Unsigned_32;
begin
   STM32.RNG.Polling.Initialize_RNG;

   for Index in 1 .. 10 loop
      Unused := STM32.RNG.Polling.Random;
   end loop;

   Candy_Dispenser.Initialize;
   GUI.Initialize;

   GUI.Start;

   --  The controller is all interrupt driven, we can set this task to sleep
   --  forever.
   delay until Ada.Real_Time.Time_Last;
end Main;
