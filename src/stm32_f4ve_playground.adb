with A0B.ARMv7M.SysTick_Clock;
with A0B.Time; use A0B.Time;
with A0B.STM32F407.GPIO.PIOA;

procedure Stm32_F4ve_Playground is
   LED1 : A0B.STM32F407.GPIO.GPIO_Line renames A0B.STM32F407.GPIO.PIOA.PA6;
   LED2 : A0B.STM32F407.GPIO.GPIO_Line renames A0B.STM32F407.GPIO.PIOA.PA7;

   procedure Wait_for (Duration : Time_Span) is
      Target : constant Monotonic_Time :=
         A0B.ARMv7M.SysTick_Clock.Clock + Duration;

      Current : Monotonic_Time := To_Monotonic_Time (0);
   begin
      while Current < Target loop
         Current := A0B.ARMv7M.SysTick_Clock.Clock;
      end loop;
   end Wait_for;

begin
   A0B.ARMv7M.SysTick_Clock.Initialize
      (Use_Processor_Clock => True, Clock_Frequency => 84_000_000);

   LED1.Configure_Output;
   LED2.Configure_Output;

   loop
      LED1.Set (To => False);
      LED2.Set (To => True);
      Wait_for (Milliseconds (300));

      LED1.Set (To => True);
      LED2.Set (To => False);
      Wait_for (Milliseconds (300));

   end loop;
end Stm32_F4ve_Playground;
