// Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause-Clear

module fibonacci_utest_top
#(
    type T_test_case = bit
)(
    svutest_test_ctrl_if.target tc
);
    svutest_dut_ctrl_if dc ();
    
    svutest_req_payload_rsp_if#(logic[7:0]) in (dc.clk, dc.rst);
    svutest_req_payload_rsp_if#(logic[31:0]) out (dc.clk, dc.rst);
    
    // ---------------------------------------------------------------------- //
    
    fibonacci u_fib (
        .clk        (dc.clk),
        .rst        (dc.rst),
        
        .in_valid   (in.req),
        .in_data    (in.req_payload),
        .in_ready   (in.rsp),
        
        .out_valid  (out.req),
        .out_data   (out.req_payload),
        .out_ready  (out.rsp)
    );
    
    always_comb dc.done = ~(in.req | out.req);
    
    // ---------------------------------------------------------------------- //
    
    initial begin
        T_test_case test = new(tc, dc, in, out);
        test.run();
    end
endmodule
