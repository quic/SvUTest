// Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause-Clear

`include "svutest_defines.svh"

module regress_top;
    import svutest_pkg::*;
    import floatmul_test_pkg::*;
    
    // Instantiate test cases floatmul_test_0_0 and floatmul_test_012_012
    // for floatmul_test_top
    `UTEST(floatmul_test_top, floatmul_test_0_0)
    `UTEST(floatmul_test_top, floatmul_test_012_012)
    
    initial begin
        // Replace with your tool's wave-dumping commands
        if ($test$plusargs("wave")) begin
            $dumpfile("sim.vcd");
            $dumpvars(0, regress_top);
        end
        
        regress_suite::run_all_tests();
    end
endmodule
