// Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause-Clear

/// Test control interface
interface svutest_test_ctrl_if;
    bit start;
    bit done;
    
    bit timeout;
    bit unknown;
    bit pass;
    
    modport driver (
        output start,
        input done,
        input timeout,
        input unknown,
        input pass
    );
    
    modport target (
        input start,
        output done,
        output timeout,
        output unknown,
        output pass
    );
    
    modport monitor (
        input start,
        input done,
        input timeout,
        input unknown,
        input pass
    );
endinterface

/// DUT control interface
/// Instantiate this interface inside the test top and pass to the test_case
/// Use clk, rst and done to connect to DUT
interface svutest_dut_ctrl_if;
    logic clk;
    logic rst;
    logic done;
    
    modport driver (
        output clk,
        output rst,
        input done
    );
    
    modport target (
        input clk,
        input rst,
        output done
    );
    
    modport monitor (
        input clk,
        input rst,
        input done
    );
endinterface

/// Continously driven data
interface svutest_if_data
#(
    type T_payload = logic
)(
    input  logic    clk,
    input  logic    rst
);
    T_payload   payload;
    
    task automatic sender_clear();
        payload <= 'x;
    endtask
    
    task automatic sender_drive (T_payload p);
        payload <= p;
        
        @(posedge clk iff !rst);
    endtask
    
    task automatic target_clear();
        
    endtask
    
    task automatic target_monitor (output T_payload p);
        @(posedge clk iff !rst);
        
        p = payload;
    endtask
    
    modport sender (
        input  clk,
        input  rst,
        output payload,
        import sender_clear,
        import sender_drive
    );
    
    modport target (
        input  clk,
        input  rst,
        input  payload,
        import target_clear,
        import target_monitor
    );
    
    modport snoop (
        input  clk,
        input  rst,
        input  payload
    );
endinterface

/// Payload qualified with valid
interface svutest_if_valid_data
#(
    type T_payload = logic
)(
    input  logic    clk,
    input  logic    rst
);
    logic       valid;
    T_payload   payload;
    
    modport sender (
        input  clk,
        input  rst,
        output valid,
        output payload
    );
    
    modport target (
        input  clk,
        input  rst,
        input  valid,
        input  payload
    );
    
    modport snoop (
        input  clk,
        input  rst,
        input  valid,
        input  payload
    );
endinterface

/// Request-payload-response interface
interface svutest_req_payload_rsp_if
#(
    type T_payload = logic
)(
    input logic clk,
    input logic rst
);
    logic       req;
    T_payload   req_payload;
    
    logic       rsp;
    
    modport sender (
        input  clk,
        input  rst,
        output req,
        output req_payload,
        input  rsp
    );
    
    modport target (
        input  clk,
        input  rst,
        input  req,
        input  req_payload,
        output rsp
    );
    
    modport snoop (
        input  clk,
        input  rst,
        input  req,
        input  req_payload,
        input  rsp
    );
endinterface

/// Valid-data-ready protocol
interface svutest_if_valid_ready
#(
    type T_payload       = logic,
    bit  ACTIVE_HIGH_RST = 1'b1
)(
    input logic clk,
    input logic rst
);
    logic       valid;
    T_payload   payload;
    
    logic       ready;
    
    task automatic delay ();
        if (ACTIVE_HIGH_RST) begin
            @(posedge clk iff !rst);
        end else begin
            @(posedge clk iff rst);
        end
    endtask
    
    task automatic sender_clear();
        valid <= 1'b0;
        payload <= 'x;
    endtask
    
    task automatic sender_drive (T_payload p);
        valid <= 1'b1;
        payload <= p;
        
        if (ACTIVE_HIGH_RST) begin
            @(posedge clk iff (!rst && ready));
        end else begin
            @(posedge clk iff (rst && ready));
        end
        
        sender_clear();
    endtask
    
    task automatic target_clear();
        ready <= 1'b1;
    endtask
    
    task automatic target_monitor (output T_payload p);
        if (ACTIVE_HIGH_RST) begin
            @(posedge clk iff (!rst && valid && ready));
        end else begin
            @(posedge clk iff (rst && valid && ready));
        end
        
        p = payload;
    endtask
    
    modport sender (
        input  clk,
        input  rst,
        output valid,
        output payload,
        input  ready,
        import sender_clear,
        import sender_drive
    );
    
    modport target (
        input  clk,
        input  rst,
        input  valid,
        input  payload,
        output ready,
        import target_clear,
        import target_monitor
    );
    
    modport snoop (
        input  clk,
        input  rst,
        input  valid,
        input  payload,
        input  ready
    );
endinterface

/// Valid_count, ready_count and payload_vector
/// Number of transactions = min(valid_count, ready_count)
/// Payload vector needs to have entries right-aligned
interface svutest_if_validcount_readycount
#(
    int unsigned MAX_COUNT = 1,
    type T_payload = logic
)(
    input  logic    clk,
    input  logic    rst
);
    localparam int unsigned COUNT_WIDTH = $clog2(MAX_COUNT + 1);
    
    logic [COUNT_WIDTH-1:0]     valid_count;
    T_payload                   payload [MAX_COUNT-1:0];
    
    logic [COUNT_WIDTH-1:0]     ready_count;
    
    task automatic sender_clear();
        valid_count <= '0;
        payload <= '{ default: 'x };
    endtask
    
    task automatic sender_drive (T_payload p [MAX_COUNT-1:0]);
        valid_count <= '0;
        payload <= p;
        
        @(posedge clk iff (!rst && (ready_count != '0)));
        
        sender_clear();
    endtask
    
    task automatic target_clear();
        ready_count <= MAX_COUNT;
    endtask
    
    task automatic target_monitor (output T_payload p [MAX_COUNT-1:0]);
        @(posedge clk iff (!rst && (valid_count != '0) && (ready_count != '0)));
        
        p = payload;
    endtask
    
    modport sender (
        input  clk,
        input  rst,
        output valid_count,
        output payload,
        input  ready_count,
        import sender_clear,
        import sender_drive
    );
    
    modport target (
        input  clk,
        input  rst,
        input  valid_count,
        input  payload,
        output ready_count,
        import target_clear,
        import target_monitor
    );
    
    modport snoop (
        input  clk,
        input  rst,
        input  valid_count,
        input  payload,
        input  ready_count
    );
endinterface
