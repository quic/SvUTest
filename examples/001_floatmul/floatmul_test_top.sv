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
    
    svutest_req_payload_rsp_if#(float32_t) a (dc.clk, dc.rst);
    svutest_req_payload_rsp_if#(float32_t) b (dc.clk, dc.rst);
    svutest_req_payload_rsp_if#(float32_t) o (dc.clk, dc.rst);
    
    logic busy;
    
    // ---------------------------------------------------------------------- //
    
    floatmul u_fmul (
        .clk        (dc.clk),
        .rst        (dc.rst),
        .busy       (busy),
        
        .a_valid    (a.req),
        .a_data     (a.req_payload),
        .a_ready    (a.rsp),
        
        .b_valid    (b.req),
        .b_data     (b.req_payload),
        .b_ready    (b.rsp),
        
        .o_valid    (o.req),
        .o_data     (o.req_payload),
        .o_ready    (o.rsp)
    );
    
    always_comb dc.done = ~(a.req | b.req | o.req | busy);
    
    // ---------------------------------------------------------------------- //
    
    initial begin
        T_test_case test = new(tc, dc, a, b, o);
        test.run();
    end
endmodule
