// Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
// SPDX-License-Identifier: BSD-3-Clause-Clear

`include "svutest_defines.svh"

module regress_top;
    import svutest_pkg::*;
    import floatmul_utest_pkg::*;
    import fibonacci_utest_pkg::*;
    
    svutest_test_ctrl_if i_floatmul_utest_0_0 ();
    floatmul_utest_top#(floatmul_utest_0_0) u_floatmul_utest2_0_0 (i_floatmul_utest_0_0);
    `SVUTEST(floatmul_utest_top, floatmul_utest_012_012)
    
    `SVUTEST(fibonacci_utest_top, fibonacci_utest_0)
    `SVUTEST(fibonacci_utest_top, fibonacci_utest_1)
    `SVUTEST(fibonacci_utest_top, fibonacci_utest_2)
    `SVUTEST(fibonacci_utest_top, fibonacci_utest_3)
    `SVUTEST(fibonacci_utest_top, fibonacci_utest_5)
    `SVUTEST(fibonacci_utest_top, fibonacci_utest_8)
    `SVUTEST(fibonacci_utest_top, fibonacci_utest_0_2)
    `SVUTEST(fibonacci_utest_top, fibonacci_utest_1_5)
    `SVUTEST(fibonacci_utest_top, fibonacci_utest_2_0_3)
    
    initial begin
        test_list list = new();
        
        // Replace with your tool's wave-dumping commands
        if ($test$plusargs("wave")) begin
            $dumpfile("sim.vcd");
            $dumpvars(0, regress_top);
        end
        
        list.add(i_floatmul_utest_0_0);
        list.add(i_floatmul_utest_012_012);
        list.add(i_fibonacci_utest_0);
        list.add(i_fibonacci_utest_1);
        list.add(i_fibonacci_utest_2);
        list.add(i_fibonacci_utest_3);
        list.add(i_fibonacci_utest_5);
        list.add(i_fibonacci_utest_8);
        list.add(i_fibonacci_utest_0_2);
        list.add(i_fibonacci_utest_1_5);
        list.add(i_fibonacci_utest_2_0_3);
        
        list.run();
    end
endmodule
