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
    input  float32_t    a_data,
    output logic        a_ready,
    
    input  logic        b_valid,
    input  float32_t    b_data,
    output logic        b_ready,
    
    output logic        o_valid,
    output float32_t    o_data,
    input  logic        o_ready
);
    logic c_valid;
    float32_t c_data;
    logic c_ready;
    
    logic d_valid;
    float32_t d_data;
    logic d_ready;
    
    // ---------------------------------------------------------------------- //
    
    // Pipeline a
    always_comb a_ready = ~c_valid | c_ready;
    
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            c_valid <= 1'b0;
        end else if (a_valid) begin
            c_valid <= 1'b1;
        end else if (c_ready) begin
            c_valid <= 1'b0;
        end
    end
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            c_data <= '0;
        end else if (a_valid & a_ready) begin
            c_data <= a_data;
        end
    end
    
    // Pipeline b
    always_comb b_ready = ~d_valid | d_ready;
    
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            d_valid <= 1'b0;
        end else if (a_valid) begin
            d_valid <= 1'b1;
        end else if (d_ready) begin
            d_valid <= 1'b0;
        end
    end
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            d_data <= '0;
        end else if (a_valid & b_ready) begin
            d_data <= a_data;
        end
    end
    
    // ---------------------------------------------------------------------- //
    
    always_comb c_ready = o_ready & d_valid;
    always_comb d_ready = o_ready & c_valid;
    
    always_comb o_valid = c_valid & d_valid;
    always_comb o_data = c_data;  // Deliberately left unimplemented
    
    // ---------------------------------------------------------------------- //
    
    always_comb busy = c_valid | d_valid;
endmodule
