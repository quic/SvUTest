// Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause-Clear

`include "svutest_defines.svh"

package fibonacci_utest_pkg;
    import svutest_pkg::*;
    
    virtual class fibonacci_utest extends test_case;
        valid_data_ready_injector#(logic[7:0]) m_in_injector;
        valid_data_ready_extractor#(logic[31:0]) m_out_extractor;
        
        function new (
            virtual svutest_test_ctrl_if.target vif_test_ctrl,
            virtual svutest_dut_ctrl_if.driver vif_dut_ctrl,
            virtual svutest_req_payload_rsp_if#(logic[7:0]).driver vif_in,
            virtual svutest_req_payload_rsp_if#(logic[31:0]).target vif_out,
            string test_case_name
        );
            super.new(vif_test_ctrl, vif_dut_ctrl, $sformatf("fibonacci:%0s", test_case_name));
            
            m_in_injector = new(vif_in);
            m_out_extractor = new(vif_out);
            
            this.add(m_in_injector);
            this.add(m_out_extractor);
        endfunction
    endclass
    
    /// 0 numbers
    class fibonacci_utest_0 extends fibonacci_utest;
        function new (
            virtual svutest_test_ctrl_if.target vif_test_ctrl,
            virtual svutest_dut_ctrl_if.driver vif_dut_ctrl,
            virtual svutest_req_payload_rsp_if#(logic[7:0]).driver vif_in,
            virtual svutest_req_payload_rsp_if#(logic[31:0]).target vif_out
        );
            super.new(vif_test_ctrl, vif_dut_ctrl, vif_in, vif_out, "0");
        endfunction
        
        function void populate ();
            m_in_injector.put(0);
        endfunction
        
        function void check ();
            logic [31:0] out_queue [$] = m_out_extractor.get_queue();
            
            `SVUTEST_ASSERT_EQ(out_queue.size(), 0)
        endfunction
    endclass
    
    /// 1 number
    class fibonacci_utest_1 extends fibonacci_utest;
        function new (
            virtual svutest_test_ctrl_if.target vif_test_ctrl,
            virtual svutest_dut_ctrl_if.driver vif_dut_ctrl,
            virtual svutest_req_payload_rsp_if#(logic[7:0]).driver vif_in,
            virtual svutest_req_payload_rsp_if#(logic[31:0]).target vif_out
        );
            super.new(vif_test_ctrl, vif_dut_ctrl, vif_in, vif_out, "1");
        endfunction
        
        function void populate ();
            m_in_injector.put(1);
        endfunction
        
        function void check ();
            logic [31:0] out_queue [$] = m_out_extractor.get_queue();
            
            `SVUTEST_ASSERT_EQ(out_queue.size(), 1)
            
            `SVUTEST_ASSERT_EQ(out_queue[0], 0)
        endfunction
    endclass
    
    /// 2 numbers
    class fibonacci_utest_2 extends fibonacci_utest;
        function new (
            virtual svutest_test_ctrl_if.target vif_test_ctrl,
            virtual svutest_dut_ctrl_if.driver vif_dut_ctrl,
            virtual svutest_req_payload_rsp_if#(logic[7:0]).driver vif_in,
            virtual svutest_req_payload_rsp_if#(logic[31:0]).target vif_out
        );
            super.new(vif_test_ctrl, vif_dut_ctrl, vif_in, vif_out, "2");
        endfunction
        
        function void populate ();
            m_in_injector.put(2);
        endfunction
        
        function void check ();
            logic [31:0] out_queue [$] = m_out_extractor.get_queue();
            
            `SVUTEST_ASSERT_EQ(out_queue.size(), 2)
            
            `SVUTEST_ASSERT_EQ(out_queue[0], 0)
            `SVUTEST_ASSERT_EQ(out_queue[1], 1)
        endfunction
    endclass
    
    /// 3 number
    class fibonacci_utest_3 extends fibonacci_utest;
        function new (
            virtual svutest_test_ctrl_if.target vif_test_ctrl,
            virtual svutest_dut_ctrl_if.driver vif_dut_ctrl,
            virtual svutest_req_payload_rsp_if#(logic[7:0]).driver vif_in,
            virtual svutest_req_payload_rsp_if#(logic[31:0]).target vif_out
        );
            super.new(vif_test_ctrl, vif_dut_ctrl, vif_in, vif_out, "3");
        endfunction
        
        function void populate ();
            m_in_injector.put(3);
        endfunction
        
        function void check ();
            logic [31:0] out_queue [$] = m_out_extractor.get_queue();
            
            `SVUTEST_ASSERT_EQ(out_queue.size(), 3)
            
            `SVUTEST_ASSERT_EQ(out_queue[0], 0)
            `SVUTEST_ASSERT_EQ(out_queue[1], 1)
            `SVUTEST_ASSERT_EQ(out_queue[2], 1)
        endfunction
    endclass
    
    /// 5 numbers
    class fibonacci_utest_5 extends fibonacci_utest;
        function new (
            virtual svutest_test_ctrl_if.target vif_test_ctrl,
            virtual svutest_dut_ctrl_if.driver vif_dut_ctrl,
            virtual svutest_req_payload_rsp_if#(logic[7:0]).driver vif_in,
            virtual svutest_req_payload_rsp_if#(logic[31:0]).target vif_out
        );
            super.new(vif_test_ctrl, vif_dut_ctrl, vif_in, vif_out, "5");
        endfunction
        
        function void populate ();
            m_in_injector.put(5);
        endfunction
        
        function void check ();
            logic [31:0] out_queue [$] = m_out_extractor.get_queue();
            
            `SVUTEST_ASSERT_EQ(out_queue.size(), 5)
            
            `SVUTEST_ASSERT_EQ(out_queue[0], 0)
            `SVUTEST_ASSERT_EQ(out_queue[1], 1)
            `SVUTEST_ASSERT_EQ(out_queue[2], 1)
            `SVUTEST_ASSERT_EQ(out_queue[3], 2)
            `SVUTEST_ASSERT_EQ(out_queue[4], 3)
        endfunction
    endclass
    
    /// 8 numbers
    class fibonacci_utest_8 extends fibonacci_utest;
        function new (
            virtual svutest_test_ctrl_if.target vif_test_ctrl,
            virtual svutest_dut_ctrl_if.driver vif_dut_ctrl,
            virtual svutest_req_payload_rsp_if#(logic[7:0]).driver vif_in,
            virtual svutest_req_payload_rsp_if#(logic[31:0]).target vif_out
        );
            super.new(vif_test_ctrl, vif_dut_ctrl, vif_in, vif_out, "8");
        endfunction
        
        function void populate ();
            m_in_injector.put(8);
        endfunction
        
        function void check ();
            logic [31:0] out_queue [$] = m_out_extractor.get_queue();
            
            `SVUTEST_ASSERT_EQ(out_queue.size(), 8)
            
            `SVUTEST_ASSERT_EQ(out_queue[0], 0)
            `SVUTEST_ASSERT_EQ(out_queue[1], 1)
            `SVUTEST_ASSERT_EQ(out_queue[2], 1)
            `SVUTEST_ASSERT_EQ(out_queue[3], 2)
            `SVUTEST_ASSERT_EQ(out_queue[4], 3)
            `SVUTEST_ASSERT_EQ(out_queue[5], 5)
            `SVUTEST_ASSERT_EQ(out_queue[6], 8)
            `SVUTEST_ASSERT_EQ(out_queue[7], 13)
        endfunction
    endclass
    
    /// Sequence of 0 followed by 2
    class fibonacci_utest_0_2 extends fibonacci_utest;
        function new (
            virtual svutest_test_ctrl_if.target vif_test_ctrl,
            virtual svutest_dut_ctrl_if.driver vif_dut_ctrl,
            virtual svutest_req_payload_rsp_if#(logic[7:0]).driver vif_in,
            virtual svutest_req_payload_rsp_if#(logic[31:0]).target vif_out
        );
            super.new(vif_test_ctrl, vif_dut_ctrl, vif_in, vif_out, "0_2");
        endfunction
        
        function void populate ();
            m_in_injector.put(0);
            m_in_injector.put(2);
        endfunction
        
        function void check ();
            logic [31:0] out_queue [$] = m_out_extractor.get_queue();
            
            `SVUTEST_ASSERT_EQ(out_queue.size(), 2)
            
            `SVUTEST_ASSERT_EQ(out_queue[0], 0)
            `SVUTEST_ASSERT_EQ(out_queue[1], 1)
        endfunction
    endclass
    
    /// Sequence of 1 followed by 5
    class fibonacci_utest_1_5 extends fibonacci_utest;
        function new (
            virtual svutest_test_ctrl_if.target vif_test_ctrl,
            virtual svutest_dut_ctrl_if.driver vif_dut_ctrl,
            virtual svutest_req_payload_rsp_if#(logic[7:0]).driver vif_in,
            virtual svutest_req_payload_rsp_if#(logic[31:0]).target vif_out
        );
            super.new(vif_test_ctrl, vif_dut_ctrl, vif_in, vif_out, "1_5");
        endfunction
        
        function void populate ();
            m_in_injector.put(1);
            m_in_injector.put(5);
        endfunction
        
        function void check ();
            logic [31:0] out_queue [$] = m_out_extractor.get_queue();
            
            `SVUTEST_ASSERT_EQ(out_queue.size(), 6)
            
            `SVUTEST_ASSERT_EQ(out_queue[0], 0)
            `SVUTEST_ASSERT_EQ(out_queue[1], 0)
            `SVUTEST_ASSERT_EQ(out_queue[2], 1)
            `SVUTEST_ASSERT_EQ(out_queue[3], 1)
            `SVUTEST_ASSERT_EQ(out_queue[4], 2)
            `SVUTEST_ASSERT_EQ(out_queue[5], 3)
        endfunction
    endclass
    
    /// Sequence of 2 followed by 0 followed by 3
    class fibonacci_utest_2_0_3 extends fibonacci_utest;
        function new (
            virtual svutest_test_ctrl_if.target vif_test_ctrl,
            virtual svutest_dut_ctrl_if.driver vif_dut_ctrl,
            virtual svutest_req_payload_rsp_if#(logic[7:0]).driver vif_in,
            virtual svutest_req_payload_rsp_if#(logic[31:0]).target vif_out
        );
            super.new(vif_test_ctrl, vif_dut_ctrl, vif_in, vif_out, "2_0_3");
        endfunction
        
        function void populate ();
            m_in_injector.put(2);
            m_in_injector.put(0);
            m_in_injector.put(3);
        endfunction
        
        function void check ();
            logic [31:0] out_queue [$] = m_out_extractor.get_queue();
            
            `SVUTEST_ASSERT_EQ(out_queue.size(), 5)
            
            `SVUTEST_ASSERT_EQ(out_queue[0], 0)
            `SVUTEST_ASSERT_EQ(out_queue[1], 1)
            `SVUTEST_ASSERT_EQ(out_queue[2], 0)
            `SVUTEST_ASSERT_EQ(out_queue[3], 1)
            `SVUTEST_ASSERT_EQ(out_queue[4], 1)
        endfunction
    endclass
endpackage
