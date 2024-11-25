--
--  Copyright (C) 2024, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  pragma Restrictions (No_Elaboration_Code);

pragma Ada_2022;

with Ada.Unchecked_Conversion;

with A0B.ARMv7M.NVIC_Utilities; use A0B.ARMv7M.NVIC_Utilities;
with A0B.STM32F407.SVD.EXTI;    use A0B.STM32F407.SVD.EXTI;
with A0B.STM32F407.SVD.GPIO;    use A0B.STM32F407.SVD.GPIO;
with A0B.STM32F407.SVD.RCC;     use A0B.STM32F407.SVD.RCC;
with A0B.STM32F407.SVD.SYSCFG;  use A0B.STM32F407.SVD.SYSCFG;
with A0B.Types.GCC_Builtins;    use A0B.Types.GCC_Builtins;

package body A0B.STM32F407.GPIO is

   type GPIO_Line_Access is access all GPIO_Line'Class;

   type EXTI_Descriptor is limited record
      IO : GPIO_Line_Access;
      CB : A0B.Callbacks.Callback;
   end record;

   subtype EXTI_Line_Identifier is GPIO_Line_Identifier;

   EXTI0_Mask     : constant := 2#0000_0000_0000_0001#;
   EXTI1_Mask     : constant := 2#0000_0000_0000_0010#;
   EXTI2_Mask     : constant := 2#0000_0000_0000_0100#;
   EXTI3_Mask     : constant := 2#0000_0000_0000_1000#;
   EXTI4_Mask     : constant := 2#0000_0000_0001_0000#;
   EXTI9_5_Mask   : constant := 2#0000_0011_1110_0000#;
   EXTI15_10_Mask : constant := 2#1111_1100_0000_0000#;

   EXTI_Line : array (EXTI_Line_Identifier) of aliased EXTI_Descriptor;

   procedure EXTI0_Handler
     with Export, Convention => C, External_Name => "EXTI0_Handler";
   procedure EXTI1_Handler
     with Export, Convention => C, External_Name => "EXTI1_Handler";
   procedure EXTI2_Handler
     with Export, Convention => C, External_Name => "EXTI2_Handler";
   procedure EXTI3_Handler
     with Export, Convention => C, External_Name => "EXTI3_Handler";
   procedure EXTI4_Handler
     with Export, Convention => C, External_Name => "EXTI4_Handler";
   procedure EXTI9_5_Handler
     with Export, Convention => C, External_Name => "EXTI9_5_Handler";
   procedure EXTI15_10_Handler
     with Export, Convention => C, External_Name => "EXTI15_10_Handler";
   --  EXTI* interrupt handlers

   procedure EXTI_Handler (Pending_Mask : A0B.Types.Unsigned_32);

   procedure Enable_Clock (Self : in out GPIO_Controller);
   --  Enable clock of the given GPIO controller.

   procedure Set_Pull_Mode
     (Self : aliased in out GPIO_Line'Class;
      To   : Pull_Mode);

   procedure Set_Output_Speed
     (Self : aliased in out GPIO_Line'Class;
      To   : Output_Speed);

   procedure Set_Output_Mode
     (Self : aliased in out GPIO_Line'Class;
      To   : Output_Mode);

   ------------------------------------
   -- Configure_Alternative_Function --
   ------------------------------------

   procedure Configure_Alternative_Function
     (Self  : aliased in out GPIO_Line'Class;
      Line  : A0B.STM32F407.Function_Line_Descriptor;
      Mode  : Output_Mode  := Push_Pull;
      Speed : Output_Speed := Low;
      Pull  : Pull_Mode    := No) is
   begin
      Enable_Clock (Self.Controller.all);

      for Descriptor of Line loop
         if Descriptor.Controller = Self.Controller.Identifier
           and Descriptor.Line = Self.Identifier
         then
            Self.Set_Output_Speed (Speed);
            Self.Set_Output_Mode (Mode);
            Self.Set_Pull_Mode (Pull);

            if Self.Identifier < 8 then
               Self.Controller.Peripheral.AFRL.Arr
                 (Integer (Self.Identifier)) :=
                   A0B.STM32F407.SVD.GPIO.AFRL_Element
                     (Descriptor.Alternative_Function);

            else
               Self.Controller.Peripheral.AFRH.Arr
                 (Integer (Self.Identifier)) :=
                   A0B.STM32F407.SVD.GPIO.AFRL_Element
                     (Descriptor.Alternative_Function);
            end if;

            Self.Controller.Peripheral.MODER.Arr
              (Integer (Self.Identifier)) := 2#10#;
            --  Alternate function

            return;
         end if;
      end loop;

      raise Program_Error;
   end Configure_Alternative_Function;

   --------------------
   -- Configure_EXTI --
   --------------------

   procedure Configure_EXTI
     (Self : aliased in out GPIO_Line'Class;
      Mode : EXTI_Mode;
      Pull : Pull_Mode := No)
   is
      function To_EXTICR1_EXTI_Element is
        new Ada.Unchecked_Conversion
              (GPIO_Controller_Identifier, EXTICR1_EXTI_Element);

   begin
      pragma Assert
        (EXTI_Line (Self.Identifier).IO = null
           or EXTI_Line (Self.Identifier).IO = Self'Unchecked_Access);
      EXTI_Line (Self.Identifier).IO := Self'Unchecked_Access;
      --  Link EXTI line with GPIO line

      Self.Configure_Input (Pull);
      --  Configure IO line in input mode, it is required for EXTI, enable
      --  pull-up/pull-down when requested.

      RCC_Periph.APB2ENR.SYSCFGEN := True;
      --  Enable clock of the SYSCFG controller.

      --  Select GPIO controller to be used to generate external interrupt.

      case Self.Identifier is
         when 0 .. 3 =>
            SYSCFG_Periph.EXTICR1.EXTI.Arr (Integer (Self.Identifier)) :=
              To_EXTICR1_EXTI_Element (Self.Controller.Identifier);

         when 4 .. 7 =>
            SYSCFG_Periph.EXTICR2.EXTI.Arr (Integer (Self.Identifier)) :=
              To_EXTICR1_EXTI_Element (Self.Controller.Identifier);

         when 8 .. 11 =>
            SYSCFG_Periph.EXTICR3.EXTI.Arr (Integer (Self.Identifier)) :=
              To_EXTICR1_EXTI_Element (Self.Controller.Identifier);

         when 12 .. 15 =>
            SYSCFG_Periph.EXTICR4.EXTI.Arr (Integer (Self.Identifier)) :=
              To_EXTICR1_EXTI_Element (Self.Controller.Identifier);
      end case;

      --  Select which edge(s) generates interrupt.

      case Mode is
         when Both_Edge =>
            EXTI_Periph.RTSR.TR.Arr (Integer (Self.Identifier)) := True;
            EXTI_Periph.FTSR.TR.Arr (Integer (Self.Identifier)) := True;

         when Rising_Edge =>
            EXTI_Periph.RTSR.TR.Arr (Integer (Self.Identifier)) := True;
            EXTI_Periph.FTSR.TR.Arr (Integer (Self.Identifier)) := False;

         when Falling_Edge =>
            EXTI_Periph.RTSR.TR.Arr (Integer (Self.Identifier)) := False;
            EXTI_Periph.FTSR.TR.Arr (Integer (Self.Identifier)) := True;
      end case;
   end Configure_EXTI;

   ---------------------
   -- Configure_Input --
   ---------------------

   procedure Configure_Input
     (Self : aliased in out GPIO_Line'Class;
      Pull : Pull_Mode := No) is
   begin
      Enable_Clock (Self.Controller.all);

      Self.Set_Pull_Mode (Pull);

      Self.Controller.Peripheral.MODER.Arr
        (Integer (Self.Identifier)) := 2#00#;
      --  Input mode
   end Configure_Input;

   ----------------------
   -- Configure_Output --
   ----------------------

   procedure Configure_Output
     (Self  : aliased in out GPIO_Line'Class;
      Mode  : Output_Mode  := Push_Pull;
      Speed : Output_Speed := Low;
      Pull  : Pull_Mode    := No) is
   begin
      Enable_Clock (Self.Controller.all);

      Self.Set_Output_Mode (Mode);
      Self.Set_Output_Speed (Speed);
      Self.Set_Pull_Mode (Pull);

      Self.Controller.Peripheral.MODER.Arr
        (Integer (Self.Identifier)) := 2#01#;
      --  General purpose output mode
   end Configure_Output;

   -----------------------
   -- Disable_Interrupt --
   -----------------------

   overriding procedure Disable_Interrupt (Self : in out GPIO_Line) is

      use type A0B.Types.Unsigned_23;

      Old_IMR : constant A0B.Types.Unsigned_23 := EXTI_Periph.IMR.MR.Val;
      Mask    : constant A0B.Types.Unsigned_23 :=
        A0B.Types.Unsigned_23
          (A0B.Types.Shift_Left
             (A0B.Types.Unsigned_32 (1), Integer (Self.Identifier)));
      New_IMR : constant A0B.Types.Unsigned_23 := Old_IMR and not Mask;

   begin
      --  Disable external interrupt

      EXTI_Periph.IMR.MR.Val := New_IMR;

      --  Disable NVIC interrupt

      if (Old_IMR and EXTI0_Mask) /= 0
        and (New_IMR and EXTI0_Mask) = 0
      then
         Disable_Interrupt (EXTI0);
      end if;

      if (Old_IMR and EXTI1_Mask) /= 0
        and (New_IMR and EXTI1_Mask) = 0
      then
         Disable_Interrupt (EXTI1);
      end if;

      if (Old_IMR and EXTI2_Mask) /= 0
        and (New_IMR and EXTI2_Mask) = 0
      then
         Disable_Interrupt (EXTI2);
      end if;

      if (Old_IMR and EXTI3_Mask) /= 0
        and (New_IMR and EXTI3_Mask) = 0
      then
         Disable_Interrupt (EXTI3);
      end if;

      if (Old_IMR and EXTI4_Mask) /= 0
        and (New_IMR and EXTI4_Mask) = 0
      then
         Disable_Interrupt (EXTI4);
      end if;

      if (Old_IMR and EXTI9_5_Mask) /= 0
        and (New_IMR and EXTI9_5_Mask) = 0
      then
         Disable_Interrupt (EXTI9_5);
      end if;

      if (Old_IMR and EXTI15_10_Mask) /= 0
        and (New_IMR and EXTI15_10_Mask) = 0
      then
         Disable_Interrupt (EXTI15_10);
      end if;
   end Disable_Interrupt;

   ------------------
   -- Enable_Clock --
   ------------------

   procedure Enable_Clock (Self : in out GPIO_Controller) is
   begin
      case Self.Identifier is
         when A =>
            RCC_Periph.AHB1ENR.GPIOAEN := True;

         when B =>
            RCC_Periph.AHB1ENR.GPIOBEN := True;

         when C =>
            RCC_Periph.AHB1ENR.GPIOCEN := True;

         when D =>
            RCC_Periph.AHB1ENR.GPIODEN := True;

         when E =>
            RCC_Periph.AHB1ENR.GPIOEEN := True;

         when H =>
            RCC_Periph.AHB1ENR.GPIOHEN := True;
      end case;
   end Enable_Clock;

   ----------------------
   -- Enable_Interrupt --
   ----------------------

   overriding procedure Enable_Interrupt (Self : in out GPIO_Line) is

      use type A0B.Types.Unsigned_23;

      Old_IMR : constant A0B.Types.Unsigned_23 := EXTI_Periph.IMR.MR.Val;
      Mask    : constant A0B.Types.Unsigned_23 :=
        A0B.Types.Unsigned_23
          (A0B.Types.Shift_Left
             (A0B.Types.Unsigned_32 (1), Integer (Self.Identifier)));
      New_IMR : constant A0B.Types.Unsigned_23 := Old_IMR or Mask;

   begin
      --  Clear pending status and enable external interrupt

      EXTI_Periph.PR.PR.Val  := Mask;
      EXTI_Periph.IMR.MR.Val := New_IMR;

      --  Enable NVIC interrupt

      if (Old_IMR and EXTI0_Mask) = 0
        and (New_IMR and EXTI0_Mask) /= 0
      then
         Clear_Pending (EXTI0);
         Enable_Interrupt (EXTI0);
      end if;

      if (Old_IMR and EXTI1_Mask) = 0
        and (New_IMR and EXTI1_Mask) /= 0
      then
         Clear_Pending (EXTI1);
         Enable_Interrupt (EXTI1);
      end if;

      if (Old_IMR and EXTI2_Mask) = 0
        and (New_IMR and EXTI2_Mask) /= 0
      then
         Clear_Pending (EXTI2);
         Enable_Interrupt (EXTI2);
      end if;

      if (Old_IMR and EXTI3_Mask) = 0
        and (New_IMR and EXTI3_Mask) /= 0
      then
         Clear_Pending (EXTI3);
         Enable_Interrupt (EXTI3);
      end if;

      if (Old_IMR and EXTI4_Mask) = 0
        and (New_IMR and EXTI4_Mask) /= 0
      then
         Clear_Pending (EXTI4);
         Enable_Interrupt (EXTI4);
      end if;

      if (Old_IMR and EXTI9_5_Mask) = 0
        and (New_IMR and EXTI9_5_Mask) /= 0
      then
         Clear_Pending (EXTI9_5);
         Enable_Interrupt (EXTI9_5);
      end if;

      if (Old_IMR and EXTI15_10_Mask) = 0
        and (New_IMR and EXTI15_10_Mask) /= 0
      then
         Clear_Pending (EXTI15_10);
         Enable_Interrupt (EXTI15_10);
      end if;
   end Enable_Interrupt;

   -------------------
   -- EXTI0_Handler --
   -------------------

   procedure EXTI0_Handler is
   begin
      EXTI_Handler (EXTI0_Mask);
   end EXTI0_Handler;

   -----------------------
   -- EXTI15_10_Handler --
   -----------------------

   procedure EXTI15_10_Handler is
   begin
      EXTI_Handler (EXTI15_10_Mask);
   end EXTI15_10_Handler;

   -------------------
   -- EXTI1_Handler --
   -------------------

   procedure EXTI1_Handler is
   begin
      EXTI_Handler (EXTI1_Mask);
   end EXTI1_Handler;

   -------------------
   -- EXTI2_Handler --
   -------------------

   procedure EXTI2_Handler is
   begin
      EXTI_Handler (EXTI2_Mask);
   end EXTI2_Handler;

   -------------------
   -- EXTI3_Handler --
   -------------------

   procedure EXTI3_Handler is
   begin
      EXTI_Handler (EXTI3_Mask);
   end EXTI3_Handler;

   -------------------
   -- EXTI4_Handler --
   -------------------

   procedure EXTI4_Handler is
   begin
      EXTI_Handler (EXTI4_Mask);
   end EXTI4_Handler;

   ---------------------
   -- EXTI9_5_Handler --
   ---------------------

   procedure EXTI9_5_Handler is
   begin
      EXTI_Handler (EXTI9_5_Mask);
   end EXTI9_5_Handler;

   ------------------
   -- EXTI_Handler --
   ------------------

   procedure EXTI_Handler (Pending_Mask : A0B.Types.Unsigned_32) is

      use type A0B.Types.Unsigned_32;

      Status : A0B.Types.Unsigned_32 :=
        A0B.Types.Unsigned_32 (EXTI_Periph.PR.PR.Val) and Pending_Mask;
      Line   : Integer;
      Mask   : A0B.Types.Unsigned_32;

   begin
      while Status /= 0 loop
         Line   := Integer (ctz (Status));
         Mask   := A0B.Types.Shift_Left (1, Line);
         Status := @ and (not Mask);

         EXTI_Periph.PR.PR.Arr (Line) := True;
         --  Clear interrupt pending bit, it should be done by software.

         A0B.Callbacks.Emit (EXTI_Line (EXTI_Line_Identifier (Line)).CB);
      end loop;
   end EXTI_Handler;

   ---------
   -- Get --
   ---------

   overriding function Get (Self : GPIO_Line) return Boolean is
   begin
      return
        Self.Controller.Peripheral.IDR.IDR.Arr (Integer (Self.Identifier));
   end Get;

   ---------
   -- Set --
   ---------

   overriding procedure Set (Self : GPIO_Line; To : Boolean) is
      Aux : BSRR_Register;

   begin
      case To is
         when False =>
            Aux.BR.Arr (Integer (Self.Identifier)) := True;

         when True =>
            Aux.BS.Arr (Integer (Self.Identifier)) := True;
      end case;

      Self.Controller.Peripheral.BSRR := Aux;
   end Set;

   ------------------
   -- Set_Callback --
   ------------------

   overriding procedure Set_Callback
     (Self : in out GPIO_Line; Callback : A0B.Callbacks.Callback) is
   begin
      pragma Assert (EXTI_Line (Self.Identifier).IO = Self'Unchecked_Access);

      EXTI_Line (Self.Identifier).CB := Callback;
   end Set_Callback;

   ---------------------
   -- Set_Output_Mode --
   ---------------------

   procedure Set_Output_Mode
     (Self : aliased in out GPIO_Line'Class;
      To   : Output_Mode) is
   begin
      case To is
         when Push_Pull =>
            Self.Controller.Peripheral.OTYPER.OT.Arr
              (Integer (Self.Identifier)) := False;

         when Open_Drain =>
            Self.Controller.Peripheral.OTYPER.OT.Arr
              (Integer (Self.Identifier)) := True;
      end case;
   end Set_Output_Mode;

   ----------------------
   -- Set_Output_Speed --
   ----------------------

   procedure Set_Output_Speed
     (Self : aliased in out GPIO_Line'Class;
      To   : Output_Speed) is
   begin
      case To is
         when Low =>
            Self.Controller.Peripheral.OSPEEDR.Arr
              (Integer (Self.Identifier)) := 2#00#;

         when Medium =>
            Self.Controller.Peripheral.OSPEEDR.Arr
              (Integer (Self.Identifier)) := 2#01#;

         when High =>
            Self.Controller.Peripheral.OSPEEDR.Arr
              (Integer (Self.Identifier)) := 2#10#;

         when Very_High =>
            Self.Controller.Peripheral.OSPEEDR.Arr
              (Integer (Self.Identifier)) := 2#11#;
      end case;
   end Set_Output_Speed;

   -------------------
   -- Set_Pull_Mode --
   -------------------

   procedure Set_Pull_Mode
     (Self : aliased in out GPIO_Line'Class;
      To   : Pull_Mode) is
   begin
      case To is
         when No =>
            Self.Controller.Peripheral.PUPDR.Arr
              (Integer (Self.Identifier)) := 2#00#;

         when Pull_Up =>
            Self.Controller.Peripheral.PUPDR.Arr
              (Integer (Self.Identifier)) := 2#01#;

         when Pull_Down =>
            Self.Controller.Peripheral.PUPDR.Arr
              (Integer (Self.Identifier)) := 2#10#;
      end case;
   end Set_Pull_Mode;

end A0B.STM32F407.GPIO;
