// Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause-Clear

package floatmul_pkg;
    typedef struct packed {
        logic           sign;
        logic [7:0]     exponent;
        logic [23:0]    mantissa;
    } float32_t;
endpackage

module floatmul
    import floatmul_pkg::*;
(
    input  logic        clk,
    input  logic        rst,
    output logic        busy,
    
    input  logic        a_valid,
    input  float32_t    a_payload,
    output logic        a_ready,
    
    input  logic        b_valid,
    input  float32_t    b_payload,
    output logic        b_ready,
    
    output logic        o_valid,
    output float32_t    o_payload,
    input  logic        o_ready
);
    always_comb a_ready = o_ready & b_valid;
    always_comb b_ready = o_ready & a_valid;
    
    always_comb o_valid = a_valid & b_valid;
    // Deliberately left unimplemented
    always_comb o_payload = a_payload;
    
    always_comb busy = o_valid;
endmodule
