// Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause-Clear

/// Test top for floatmul
/// Test case class passed through T_test_case. No ports
module floatmul_test_top
    import floatmul_pkg::*;
#(
    type T_test_case = bit
)(
    svutest_test_ctrl_if.target tc
);
    svutest_dut_ctrl_if dc ();
    
    svutest_if_valid_ready#(float32_t) a (dc.clk, dc.rst);
    svutest_if_valid_ready#(float32_t) b (dc.clk, dc.rst);
    svutest_if_valid_ready#(float32_t) o (dc.clk, dc.rst);
    
    logic busy;
    
    // ---------------------------------------------------------------------- //
    
    floatmul u_fmul (
        .clk        (dc.clk),
        .rst        (dc.rst),
        .busy       (busy),
        
        .a_valid    (a.valid),
        .a_payload  (a.payload),
        .a_ready    (a.ready),
        
        .b_valid    (b.valid),
        .b_payload  (b.payload),
        .b_ready    (b.ready),
        
        .o_valid    (o.valid),
        .o_payload  (o.payload),
        .o_ready    (o.ready)
    );
    
    always_comb dc.done = ~(a.valid | b.valid | o.valid | busy);
    
    // ---------------------------------------------------------------------- //
    
    initial begin
        T_test_case test = new(tc, dc, a, b, o);
        test.run();
    end
endmodule
