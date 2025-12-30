// Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
// SPDX-License-Identifier: BSD-3-Clause-Clear

/// Generates the first N fibonacci numbers
module fibonacci
(
    input  logic        clk,
    input  logic        rst,
    
    input  logic        in_valid,
    input  logic [7:0]  in_data,
    output logic        in_ready,
    
    output logic        out_valid,
    output logic [31:0] out_data,
    input  logic        out_ready
);
    logic [7:0] count;
    
    logic [31:0] prev;
    logic [31:0] cur;
    logic [31:0] nxt;
    
    // ---------------------------------------------------------------------- //
    
    always_comb begin
        if (out_ready) begin
            if (in_valid) begin
                in_ready = count + 1'b1 >= in_data;
            end else begin
                in_ready = 1'b1;
            end
        end else begin
            in_ready = 1'b0;
        end
    end
    
    // ---------------------------------------------------------------------- //
    
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= '0;
        end else if (in_valid & in_ready) begin
            count <= '0;
        end else if (out_valid & out_ready) begin
            count <= count + 1'b1;
        end
    end
    
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            cur <= '0;
            prev <= '0;
        end else if (in_valid & in_ready) begin
            cur <= '0;
            prev <= '0;
        end else if (out_valid & out_ready) begin
            cur <= nxt;
            prev <= cur;
        end
    end
    
    always_comb nxt = count == 0 ? 1 : cur + prev;
    
    // ---------------------------------------------------------------------- //
    
    always_comb out_valid = in_valid && (in_data > 0);
    always_comb out_data = cur;
endmodule
