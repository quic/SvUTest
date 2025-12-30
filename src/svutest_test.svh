// Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
// SPDX-License-Identifier: BSD-3-Clause-Clear

`ifndef SVUTEST_TEST_SVH
`define SVUTEST_TEST_SVH

`include "svutest_core.svh"

/// Test case base class
/// All test cases must derive from this class
virtual class test_case;
    virtual svutest_test_ctrl_if.target m_vif_test_ctrl;
    virtual svutest_dut_ctrl_if.driver m_vif_dut_ctrl;
    string m_test_name;
    int unsigned m_alive_cycles;
    int unsigned m_timeout_threshold;
    
    protocol m_protocol_queue [$];
    
    int unsigned m_pass_count;
    int unsigned m_fail_count;
    
    local bit m_clk_gen;
    
    function new (
        virtual svutest_test_ctrl_if.target vif_tc,
        virtual svutest_dut_ctrl_if.driver vif_dc,
        string test_name,
        int unsigned num_alive_cycles = 2,
        int unsigned timeout_threshold = 1000
    );
        m_vif_test_ctrl = vif_tc;
        m_vif_dut_ctrl = vif_dc;
        m_test_name = test_name;
        m_alive_cycles = num_alive_cycles;
        m_timeout_threshold = timeout_threshold;
        m_protocol_queue = {};
    endfunction
    
    function void add (protocol p);
        m_protocol_queue.push_back(p);
    endfunction
    
    pure virtual function void populate ();
    
    local task run_clk_gen (bit posedge_clk, bit async_rst);
        m_vif_dut_ctrl.clk <= !posedge_clk;
        
        if (async_rst) begin
            #3000;
        end else begin
            #1000;
        end
        
        repeat (m_alive_cycles) begin
            m_vif_dut_ctrl.clk <= posedge_clk;
            #500;
            
            m_vif_dut_ctrl.clk <= !posedge_clk;
            #500;
        end
        
        while (!m_vif_dut_ctrl.done) begin
            m_vif_dut_ctrl.clk <= posedge_clk;
            #500;
            
            m_vif_dut_ctrl.clk <= !posedge_clk;
            #500;
        end
        
        repeat (m_alive_cycles) begin
            m_vif_dut_ctrl.clk <= posedge_clk;
            #500;
            
            m_vif_dut_ctrl.clk <= !posedge_clk;
            #500;
        end
    endtask
    
    local task run_rst_gen (bit posedge_clk, bit async_rst, bit active_high_rst);
        m_vif_dut_ctrl.rst <= !active_high_rst;
        
        if (async_rst) begin
            #1000;
        end else begin
            if (posedge_clk) begin
                @(posedge m_vif_dut_ctrl.clk);
            end else begin
                @(negedge m_vif_dut_ctrl.clk);
            end
        end
        
        m_vif_dut_ctrl.rst <= active_high_rst;
        
        if (async_rst) begin
            #1000;
        end else begin
            if (posedge_clk) begin
                @(posedge m_vif_dut_ctrl.clk);
            end else begin
                @(negedge m_vif_dut_ctrl.clk);
            end
        end
        
        m_vif_dut_ctrl.rst <= !active_high_rst;
    endtask
    
    virtual function void check ();
        
    endfunction
    
    function void report (bit timed_out);
        int unsigned total_count;
        
        string complete_status_str;
        string pass_status_str;
        
        string complete_str;
        string timeout_str;
        string pass_str;
        string fail_str;
        string unknown_str;
        
        if ($test$plusargs("svutest_color")) begin
            complete_str = "\033[0;34mCOMPLETE\033[0m";
            timeout_str = "\033[0;35mTIMEOUT\033[0m";
            pass_str = "\033[0;32mPASS\033[0m";
            fail_str = "\033[0;31mFAIL\033[0m";
            unknown_str = "\033[0;33mUNKNOWN\033[0m";
        end else begin
            complete_str = "COMPLETE";
            timeout_str = "TIMEOUT";
            pass_str = "PASS";
            fail_str = "FAIL";
            unknown_str = "UNKNOWN";
        end
        
        total_count = m_pass_count + m_fail_count;
        
        if (timed_out) begin
            complete_status_str = timeout_str;
            m_vif_test_ctrl.timeout = 1'b1;
        end else begin
            complete_status_str = complete_str;
            m_vif_test_ctrl.timeout = 1'b0;
        end
        
        if (total_count == 0) begin
            pass_status_str = unknown_str;
            m_vif_test_ctrl.unchecked = 1'b1;
        end else if (m_pass_count == total_count) begin
            pass_status_str = pass_str;
            m_vif_test_ctrl.unchecked = 1'b0;
            m_vif_test_ctrl.pass = 1'b1;
        end else begin
            pass_status_str = fail_str;
            m_vif_test_ctrl.unchecked = 1'b0;
            m_vif_test_ctrl.pass = 1'b0;
        end
        
        $write("%12t | %0s> %0s. Assertions: %0d/%0d [%0s]\n",
            $time, m_test_name, complete_status_str,
            m_pass_count, total_count, pass_status_str);
    endfunction
    
    virtual task run ();
        process protocol_pid [] = new [m_protocol_queue.size()];
        process clk_pid = null;
        process rst_pid = null;
        process exit_pid = null;
        process timeout_pid = null;
        
        bit finished;
        bit timed_out;
        
        // -------------------------------------------------------------- //
        
        m_vif_test_ctrl.complete = 1'b0;
        
        wait (m_vif_test_ctrl.start === 1'b1);
        m_vif_test_ctrl.running = 1'b1;
        
        // Start protocols so that they can drive signals for time = 0
        for (int unsigned i = 0 ; i < m_protocol_queue.size() ; i++) begin
            fork
                automatic int unsigned index = i;
                
                begin
                    protocol_pid[index] = process::self();
                    m_protocol_queue[index].run();
                end
            join_none
        end
        for (int unsigned i = 0 ; i < m_protocol_queue.size() ; i++) begin
            wait (protocol_pid[i] != null);
        end
        
        // Start clock
        finished = 1'b0;
        fork
            begin
                clk_pid = process::self();
                run_clk_gen(.posedge_clk(1'b1), .async_rst(1'b1));
                
                finished = 1'b1;
            end
        join_none
        wait (clk_pid != null);
        
        // Assert reset and wait for it to complete
        fork
            begin
                rst_pid = process::self();
                run_rst_gen(.posedge_clk(1'b1), .async_rst(1'b1), .active_high_rst(1'b1));
                
                // @(posedge m_vif_dut_ctrl.clk iff !m_vif_dut_ctrl.rst);
            end
        join_none
        wait (rst_pid != null);
        
        rst_pid.await();
        
        populate();
        
        // Detect hang
        timed_out = 1'b0;
        fork
            begin
                timeout_pid = process::self();
                
                repeat (m_timeout_threshold) @(posedge m_vif_dut_ctrl.clk iff !m_vif_dut_ctrl.rst);
                
                timed_out = 1'b1;
            end
        join_none
        wait (timeout_pid != null);
        
        // Wait for graceful exit or timeout. Graceful exit also means
        // clock is shut down
        wait (finished || timed_out);
        
        // Kill all running threads
        if (clk_pid.status() != process::FINISHED) begin
            clk_pid.kill();
        end
        
        if (timeout_pid.status() != process::FINISHED) begin
            timeout_pid.kill();
        end
        
        for (int unsigned i = 0 ; i < protocol_pid.size() ; i++) begin
            if (protocol_pid[i].status() != process::FINISHED) begin
                protocol_pid[i].kill();
            end
        end
        
        check();
        report(timed_out);
        
        m_vif_test_ctrl.complete = 1'b1;
    endtask
endclass

`endif
