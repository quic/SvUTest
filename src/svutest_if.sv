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


/// Request-payload-response interface
interface svutest_req_payload_if
#(
    type T_payload = logic
)(
    input logic clk,
    input logic rst
);
    logic       req;
    T_payload   req_payload;
    
    modport sender (
        input  clk,
        input  rst,
        output req,
        output req_payload
    );
    
    modport target (
        input  clk,
        input  rst,
        input  req,
        input  req_payload
    );
    
    modport snoop (
        input  clk,
        input  rst,
        input  req,
        input  req_payload
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
