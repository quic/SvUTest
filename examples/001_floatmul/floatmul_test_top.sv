// Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause-Clear

/// Test top for floatmul
/// Test case class passed through T_test_case. No ports
module floatmul_test_top
    import floatmul_pkg::*;
    import svutest_pkg::*;
#(
    type T_test_case = bit
);
    svutest_if_test_ctrl tc ();
    
    svutest_if_valid_ready#(float32_t) i_a (tc.clk, tc.rst);
    svutest_if_valid_ready#(float32_t) i_b (tc.clk, tc.rst);
    svutest_if_valid_ready#(float32_t) i_o (tc.clk, tc.rst);
    
    // ---------------------------------------------------------------------- //
    
    floatmul u_fmul (
        .clk        (tc.clk),
        .rst        (tc.rst),
        .busy       (tc.busy),
        
        .a_valid    (i_a.valid),
        .a_payload  (i_a.payload),
        .a_ready    (i_a.ready),
        
        .b_valid    (i_b.valid),
        .b_payload  (i_b.payload),
        .b_ready    (i_b.ready),
        
        .o_valid    (i_o.valid),
        .o_payload  (i_o.payload),
        .o_ready    (i_o.ready)
    );
    
    // ---------------------------------------------------------------------- //
    
    initial begin
        T_test_case test;
        test = new(tc, i_a, i_b, i_o);
    end
endmodule
