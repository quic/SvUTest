// Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause-Clear

package svutest_pkg;
    import svutest_agent_pkg::*;
    import svutest_test_pkg::*;
    
    export svutest_agent_pkg::*;
    export svutest_test_pkg::*;
    
    class test_list;
        local virtual svutest_test_ctrl_if.driver m_test_ctrl_queue [$];
        
        static function test_list create ();
            test_list l;
            
            l = new();
            
            return l;
        endfunction
        
        function automatic void add (virtual svutest_test_ctrl_if.driver tc);
            m_test_ctrl_queue.push_back(tc);
        endfunction
        
        function automatic void append (test_list l);
            for (int unsigned i = 0 ; i < l.m_test_ctrl_queue.size() ; i++) begin
                m_test_ctrl_queue.push_back(l.m_test_ctrl_queue[i]);
            end
        endfunction
        
        local function automatic void report ();
            string done_str;
            string timeout_str;
            string pass_str;
            string fail_str;
            string unknown_str;
            
            string final_done_status_str;
            string final_pass_status_str;
            
            int unsigned num_timeout_tests;
            int unsigned num_unknown_tests;
            int unsigned num_passing_tests;
            int unsigned num_failing_tests;
            
            num_timeout_tests = 0;
            num_unknown_tests = 0;
            num_passing_tests = 0;
            num_failing_tests = 0;
            
            if ($test$plusargs("color")) begin
                done_str = "\033[0;34mDONE\033[0m";
                timeout_str = "\033[0;35mTIMEOUT\033[0m";
                pass_str = "\033[0;32mPASS\033[0m";
                fail_str = "\033[0;31mFAIL\033[0m";
                unknown_str = "\033[0;33mUNKNOWN\033[0m";
            end else begin
                done_str = "DONE";
                timeout_str = "TIMEOUT";
                pass_str = "PASS";
                fail_str = "FAIL";
                unknown_str = "UNKNOWN";
            end
            
            for (int unsigned i = 0 ; i < m_test_ctrl_queue.size() ; i++) begin
                if (m_test_ctrl_queue[i].timeout) begin
                    num_timeout_tests++;
                end else begin
                    if (m_test_ctrl_queue[i].unknown) begin
                        num_unknown_tests++;
                    end else if (m_test_ctrl_queue[i].pass) begin
                        num_passing_tests++;
                    end else begin
                        num_failing_tests++;
                    end
                end
            end
            
            if (num_timeout_tests > 0) begin
                final_done_status_str = timeout_str;
            end else begin
                final_done_status_str = done_str;
            end
            
            if (num_failing_tests > 0) begin
                final_pass_status_str = fail_str;
            end else if (num_unknown_tests > 0) begin
                final_pass_status_str = unknown_str;
            end else begin
                final_pass_status_str = pass_str;
            end
            
            $write(
                "%12t | Status: %0s, %0s | (Done: %0d, Timeout: %0d), (Pass: %0d, Fail: %0d, Unknown: %0d)\n",
                $time, final_done_status_str, final_pass_status_str,
                m_test_ctrl_queue.size(),
                num_timeout_tests,
                num_passing_tests,
                num_failing_tests,
                num_unknown_tests
            );
        endfunction
        
        task automatic run ();
            for (int unsigned i = 0 ; i < $size(m_test_ctrl_queue) ; i++) begin
                m_test_ctrl_queue[i].start <= 1'b0;
                
                fork
                    automatic int unsigned index = i;
                    
                    m_test_ctrl_queue[index].start <= 1'b1;
                join_none
            end
            
            for (int unsigned i = 0 ; i < $size(m_test_ctrl_queue) ; i++) begin
                wait (m_test_ctrl_queue[i].done === 1'b1);
            end
            
            report();
        endtask
    endclass
endpackage
