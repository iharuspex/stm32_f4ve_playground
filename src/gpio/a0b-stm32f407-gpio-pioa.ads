--
--  Copyright (C) 2024, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  GPIO A

--  pragma Restrictions (No_Elaboration_Code);

package A0B.STM32F407.GPIO.PIOA
  with Preelaborate
is

   GPIOA : aliased GPIO_Controller
     (Peripheral => A0B.STM32F407.SVD.GPIO.GPIOA_Periph'Access,
      Identifier => A);

   PA0  : aliased GPIO_Line (Controller => GPIOA'Access, Identifier => 0);
   PA1  : aliased GPIO_Line (Controller => GPIOA'Access, Identifier => 1);
   PA2  : aliased GPIO_Line (Controller => GPIOA'Access, Identifier => 2);
   PA3  : aliased GPIO_Line (Controller => GPIOA'Access, Identifier => 3);
   PA4  : aliased GPIO_Line (Controller => GPIOA'Access, Identifier => 4);
   PA5  : aliased GPIO_Line (Controller => GPIOA'Access, Identifier => 5);
   PA6  : aliased GPIO_Line (Controller => GPIOA'Access, Identifier => 6);
   PA7  : aliased GPIO_Line (Controller => GPIOA'Access, Identifier => 7);
   PA8  : aliased GPIO_Line (Controller => GPIOA'Access, Identifier => 8);
   PA9  : aliased GPIO_Line (Controller => GPIOA'Access, Identifier => 9);
   PA10 : aliased GPIO_Line (Controller => GPIOA'Access, Identifier => 10);
   PA11 : aliased GPIO_Line (Controller => GPIOA'Access, Identifier => 11);
   PA12 : aliased GPIO_Line (Controller => GPIOA'Access, Identifier => 12);
   PA13 : aliased GPIO_Line (Controller => GPIOA'Access, Identifier => 13);
   PA14 : aliased GPIO_Line (Controller => GPIOA'Access, Identifier => 14);
   PA15 : aliased GPIO_Line (Controller => GPIOA'Access, Identifier => 15);

end A0B.STM32F407.GPIO.PIOA;
