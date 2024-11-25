--
--  Copyright (C) 2024, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  GPIO C

--  pragma Restrictions (No_Elaboration_Code);

package A0B.STM32F407.GPIO.PIOC
  with Preelaborate
is

   GPIOC : aliased GPIO_Controller
     (Peripheral => A0B.STM32F407.SVD.GPIO.GPIOC_Periph'Access,
      Identifier => C);

   PC0  : aliased GPIO_Line (Controller => GPIOC'Access, Identifier => 0);
   PC1  : aliased GPIO_Line (Controller => GPIOC'Access, Identifier => 1);
   PC2  : aliased GPIO_Line (Controller => GPIOC'Access, Identifier => 2);
   PC3  : aliased GPIO_Line (Controller => GPIOC'Access, Identifier => 3);
   PC4  : aliased GPIO_Line (Controller => GPIOC'Access, Identifier => 4);
   PC5  : aliased GPIO_Line (Controller => GPIOC'Access, Identifier => 5);
   PC6  : aliased GPIO_Line (Controller => GPIOC'Access, Identifier => 6);
   PC7  : aliased GPIO_Line (Controller => GPIOC'Access, Identifier => 7);
   PC8  : aliased GPIO_Line (Controller => GPIOC'Access, Identifier => 8);
   PC9  : aliased GPIO_Line (Controller => GPIOC'Access, Identifier => 9);
   PC10 : aliased GPIO_Line (Controller => GPIOC'Access, Identifier => 10);
   PC11 : aliased GPIO_Line (Controller => GPIOC'Access, Identifier => 11);
   PC12 : aliased GPIO_Line (Controller => GPIOC'Access, Identifier => 12);
   PC13 : aliased GPIO_Line (Controller => GPIOC'Access, Identifier => 13);
   PC14 : aliased GPIO_Line (Controller => GPIOC'Access, Identifier => 14);
   PC15 : aliased GPIO_Line (Controller => GPIOC'Access, Identifier => 15);

end A0B.STM32F407.GPIO.PIOC;
