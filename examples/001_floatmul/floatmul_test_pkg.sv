// Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause-Clear

`include "svutest_defines.svh"

package floatmul_test_pkg;
    import svutest_injector_pkg::*;
    import svutest_extractor_pkg::*;
    import svutest_test_pkg::*;
    import svutest_pkg::*;
    import floatmul_pkg::*;
    
    /// Base class for all test-cases of floatmul
    virtual class floatmul_utest extends test_case;
        valid_data_ready_injector#(float32_t) m_a_injector;
        valid_data_ready_injector#(float32_t) m_b_injector;
        valid_data_ready_extractor#(float32_t) m_o_extractor;
        
        function new (
            virtual svutest_test_ctrl_if.target vif_test_ctrl,
            virtual svutest_dut_ctrl_if.driver vif_dut_ctrl,
            virtual svutest_req_payload_rsp_if#(float32_t).driver vif_a,
            virtual svutest_req_payload_rsp_if#(float32_t).driver vif_b,
            virtual svutest_req_payload_rsp_if#(float32_t).target vif_o,
            string test_case_name
        );
            super.new(vif_test_ctrl, vif_dut_ctrl, $sformatf("fmul:%0s", test_case_name));
            
            m_a_injector = new(vif_a);
            m_b_injector = new(vif_b);
            m_o_extractor = new(vif_o);
            
            this.add(m_a_injector);
            this.add(m_b_injector);
            this.add(m_o_extractor);
        endfunction
    endclass
    
    /// A = 0, B = 0
    class floatmul_test2_0_0 extends floatmul_utest;
        function new (
            virtual svutest_test_ctrl_if.target vif_test_ctrl,
            virtual svutest_dut_ctrl_if.driver vif_dut_ctrl,
            virtual svutest_req_payload_rsp_if#(float32_t).driver vif_a,
            virtual svutest_req_payload_rsp_if#(float32_t).driver vif_b,
            virtual svutest_req_payload_rsp_if#(float32_t).target vif_o
        );
            super.new(vif_test_ctrl, vif_dut_ctrl, vif_a, vif_b, vif_o, "0_0");
        endfunction
        
        function void populate ();
            m_a_injector.put('{ sign: 1'b0, exponent: '0, mantissa: '0 });
            m_b_injector.put('{ sign: 1'b0, exponent: '0, mantissa: '0 });
        endfunction
        
        function void check ();
            float32_t queue [$] = m_o_extractor.get_queue();
            
            `UTEST_ASSERT_EQ(queue.size(), 1)
            
            `UTEST_ASSERT_EQ(queue[0], '1)
        endfunction
    endclass
    
    /// Sequence of 9 input pairs
    /// (A, B) =
    ///     (0, 0) => (0, 1) => (0, 2) =>
    ///     (1, 0) => (1, 1) => (1, 2) =>
    ///     (2, 0) => (2, 1) => (2, 2)
    class floatmul_test2_012_012 extends floatmul_utest;
        function new (
            virtual svutest_test_ctrl_if.target vif_test_ctrl,
            virtual svutest_dut_ctrl_if.driver vif_dut_ctrl,
            virtual svutest_req_payload_rsp_if#(float32_t).driver vif_a,
            virtual svutest_req_payload_rsp_if#(float32_t).driver vif_b,
            virtual svutest_req_payload_rsp_if#(float32_t).target vif_o
        );
            super.new(vif_test_ctrl, vif_dut_ctrl, vif_a, vif_b, vif_o, "012_012");
        endfunction
        
        function void populate ();
            m_a_injector.put('{ sign: 1'b0, exponent:  '0, mantissa: '0 });
            m_a_injector.put('{ sign: 1'b0, exponent:  '0, mantissa: '0 });
            m_a_injector.put('{ sign: 1'b0, exponent:  '0, mantissa: '0 });
            m_a_injector.put('{ sign: 1'b0, exponent: 127, mantissa: '0 });
            m_a_injector.put('{ sign: 1'b0, exponent: 127, mantissa: '0 });
            m_a_injector.put('{ sign: 1'b0, exponent: 127, mantissa: '0 });
            m_a_injector.put('{ sign: 1'b0, exponent: 128, mantissa: '0 });
            m_a_injector.put('{ sign: 1'b0, exponent: 128, mantissa: '0 });
            m_a_injector.put('{ sign: 1'b0, exponent: 128, mantissa: '0 });
            
            m_b_injector.put('{ sign: 1'b0, exponent:  '0, mantissa: '0 });
            m_b_injector.put('{ sign: 1'b0, exponent: 127, mantissa: '0 });
            m_b_injector.put('{ sign: 1'b0, exponent: 128, mantissa: '0 });
            m_b_injector.put('{ sign: 1'b0, exponent:  '0, mantissa: '0 });
            m_b_injector.put('{ sign: 1'b0, exponent: 127, mantissa: '0 });
            m_b_injector.put('{ sign: 1'b0, exponent: 128, mantissa: '0 });
            m_b_injector.put('{ sign: 1'b0, exponent:  '0, mantissa: '0 });
            m_b_injector.put('{ sign: 1'b0, exponent: 127, mantissa: '0 });
            m_b_injector.put('{ sign: 1'b0, exponent: 128, mantissa: '0 });
        endfunction
        
        function void check ();
            float32_t queue [$] = m_o_extractor.get_queue();
            
            `UTEST_ASSERT_EQ(queue.size(), 9)
            
            `UTEST_ASSERT_EQ(queue[0], float32_t'{ sign: 0, exponent:   0, mantissa: 0 })
            `UTEST_ASSERT_EQ(queue[1], float32_t'{ sign: 0, exponent:   0, mantissa: 0 })
            `UTEST_ASSERT_EQ(queue[2], float32_t'{ sign: 0, exponent:   0, mantissa: 0 })
            `UTEST_ASSERT_EQ(queue[3], float32_t'{ sign: 0, exponent:   0, mantissa: 0 })
            `UTEST_ASSERT_EQ(queue[4], float32_t'{ sign: 0, exponent: 127, mantissa: 0 })
            `UTEST_ASSERT_EQ(queue[5], float32_t'{ sign: 0, exponent: 128, mantissa: 0 })
            `UTEST_ASSERT_EQ(queue[6], float32_t'{ sign: 0, exponent:   0, mantissa: 0 })
            `UTEST_ASSERT_EQ(queue[7], float32_t'{ sign: 0, exponent: 128, mantissa: 0 })
            `UTEST_ASSERT_EQ(queue[8], float32_t'{ sign: 0, exponent: 129, mantissa: 0 })
        endfunction
    endclass
endpackage
