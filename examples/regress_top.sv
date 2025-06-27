// Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause-Clear

`include "svutest_defines.svh"

module regress_top;
    import svutest_pkg::*;
    import floatmul_test_pkg::*;
    
    svutest_test_ctrl_if i_floatmul_test2_0_0 ();
    floatmul_test_top#(floatmul_test2_0_0) u_floatmul_test2_0_0 (i_floatmul_test2_0_0);
    
    svutest_test_ctrl_if i_floatmul_test2_012_012 ();
    floatmul_test_top#(floatmul_test2_012_012) u_floatmul_test2_012_012 (i_floatmul_test2_012_012);
    
    initial begin
        test_list list = test_list::create();
        
        // Replace with your tool's wave-dumping commands
        if ($test$plusargs("wave")) begin
            $dumpfile("sim.vcd");
            $dumpvars(0, regress_top);
        end
        
        list.add(i_floatmul_test2_0_0);
        list.add(i_floatmul_test2_012_012);
        
        list.run();
    end
endmodule
