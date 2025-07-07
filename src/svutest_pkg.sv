// Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause-Clear

package svutest_pkg;
    import svutest_injector_pkg::*;
    import svutest_extractor_pkg::*;
    import svutest_test_pkg::*;
    
    export svutest_injector_pkg::*;
    export svutest_extractor_pkg::*;
    export svutest_test_pkg::*;
    
    class test_list;
        local virtual svutest_test_ctrl_if.driver m_test_ctrl_queue [$];
        
        static function test_list create ();
            test_list l = new();
            
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
            string unresponsive_str;
            string complete_str;
            string timeout_str;
            string pass_str;
            string fail_str;
            string unchecked_str;
            
            string final_status_str;
            
            int unsigned num_unresponsive_tests;
            int unsigned num_timeout_tests;
            int unsigned num_unchecked_tests;
            int unsigned num_passing_tests;
            int unsigned num_failing_tests;
            
            num_unresponsive_tests = 0;
            num_timeout_tests = 0;
            num_unchecked_tests = 0;
            num_passing_tests = 0;
            num_failing_tests = 0;
            
            if ($test$plusargs("color")) begin
                unresponsive_str = "\033[0;35mUNRESPONSIVE\033[0m";
                timeout_str = "\033[0;35mTIMEOUT\033[0m";
                pass_str = "\033[0;32mPASS\033[0m";
                fail_str = "\033[0;31mFAIL\033[0m";
                unchecked_str = "\033[0;33mUNCHECKED\033[0m";
            end else begin
                unresponsive_str = "UNRESPONSIVE";
                timeout_str = "TIMEOUT";
                pass_str = "PASS";
                fail_str = "FAIL";
                unchecked_str = "UNCHECKED";
            end
            
            for (int unsigned i = 0 ; i < m_test_ctrl_queue.size() ; i++) begin
                if (!m_test_ctrl_queue[i].running) begin
                    num_unresponsive_tests++;
                end else if (m_test_ctrl_queue[i].timeout) begin
                    num_timeout_tests++;
                end else if (m_test_ctrl_queue[i].unchecked) begin
                    num_unchecked_tests++;
                end else if (m_test_ctrl_queue[i].pass) begin
                    num_passing_tests++;
                end else begin
                    num_failing_tests++;
                end
            end
            
            if (num_unresponsive_tests > 0) begin
                final_status_str = unresponsive_str;
            end else if (num_timeout_tests > 0) begin
                final_status_str = timeout_str;
            end else if (num_failing_tests > 0) begin
                final_status_str = fail_str;
            end else if (num_unchecked_tests > 0) begin
                final_status_str = unchecked_str;
            end else begin
                final_status_str = pass_str;
            end
            
            $write(
                "%12t | Status: %0s | Total: %0d, Unresponsive: %0d, Timeout: %0d, Unchecked: %0d, Fail: %0d, Pass: %0d\n",
                $time, final_status_str,
                m_test_ctrl_queue.size(),
                num_unresponsive_tests,
                num_timeout_tests,
                num_unchecked_tests,
                num_failing_tests,
                num_passing_tests
            );
        endfunction
        
        task automatic run ();
            for (int unsigned i = 0 ; i < m_test_ctrl_queue.size() ; i++) begin
                m_test_ctrl_queue[i].start <= 1'b0;
                
                fork
                    automatic int unsigned index = i;
                    
                    begin
                        m_test_ctrl_queue[index].start <= 1'b1;
                    end
                join_none
            end
            
            #1;
            
            for (int unsigned i = 0 ; i < m_test_ctrl_queue.size() ; i++) begin
                wait (!m_test_ctrl_queue[i].running || m_test_ctrl_queue[i].complete);
            end
            
            report();
        endtask
    endclass
endpackage
