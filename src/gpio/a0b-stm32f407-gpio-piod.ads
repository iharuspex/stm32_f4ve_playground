--
--  Copyright (C) 2024, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  GPIO D

--  pragma Restrictions (No_Elaboration_Code);

package A0B.STM32F407.GPIO.PIOD
  with Preelaborate
is

   GPIOD : aliased GPIO_Controller
     (Peripheral => A0B.STM32F407.SVD.GPIO.GPIOD_Periph'Access,
      Identifier => D);

   PD0  : aliased GPIO_Line (Controller => GPIOD'Access, Identifier => 0);
   PD1  : aliased GPIO_Line (Controller => GPIOD'Access, Identifier => 1);
   PD2  : aliased GPIO_Line (Controller => GPIOD'Access, Identifier => 2);
   PD3  : aliased GPIO_Line (Controller => GPIOD'Access, Identifier => 3);
   PD4  : aliased GPIO_Line (Controller => GPIOD'Access, Identifier => 4);
   PD5  : aliased GPIO_Line (Controller => GPIOD'Access, Identifier => 5);
   PD6  : aliased GPIO_Line (Controller => GPIOD'Access, Identifier => 6);
   PD7  : aliased GPIO_Line (Controller => GPIOD'Access, Identifier => 7);
   PD8  : aliased GPIO_Line (Controller => GPIOD'Access, Identifier => 8);
   PD9  : aliased GPIO_Line (Controller => GPIOD'Access, Identifier => 9);
   PD10 : aliased GPIO_Line (Controller => GPIOD'Access, Identifier => 10);
   PD11 : aliased GPIO_Line (Controller => GPIOD'Access, Identifier => 11);
   PD12 : aliased GPIO_Line (Controller => GPIOD'Access, Identifier => 12);
   PD13 : aliased GPIO_Line (Controller => GPIOD'Access, Identifier => 13);
   PD14 : aliased GPIO_Line (Controller => GPIOD'Access, Identifier => 14);
   PD15 : aliased GPIO_Line (Controller => GPIOD'Access, Identifier => 15);

end A0B.STM32F407.GPIO.PIOD;
