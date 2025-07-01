// Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause-Clear

`include "svutest_defines.svh"

package floatmul_test_pkg;
    import svutest_driver_pkg::*;
    import svutest_agent_pkg::*;
    import svutest_test_pkg::*;
    import svutest_pkg::*;
    import floatmul_pkg::*;
    
    /// Base class for all test-cases of floatmul
    class floatmul_utest extends test_case;
        typedef virtual svutest_if_valid_ready#(float32_t) T_vif;
        typedef valid_ready_driver#(float32_t) T_driver;
        
        typedef injector#(T_vif, T_driver) T_injector;
        typedef extractor#(float32_t, T_vif, T_driver) T_extractor;
        
        T_injector m_a_agent;
        T_injector m_b_agent;
        T_extractor m_o_agent;
        
        function new (
            virtual svutest_test_ctrl_if.target vif_test_ctrl,
            virtual svutest_dut_ctrl_if vif_dut_ctrl,
            T_vif vif_a,
            T_vif vif_b,
            T_vif vif_o,
            string test_case_name
        );
            super.new(vif_test_ctrl, vif_dut_ctrl, $sformatf("fmul:%0s", test_case_name));
            
            m_a_agent = T_injector::create(vif_a);
            m_b_agent = T_injector::create(vif_b);
            m_o_agent = T_extractor::create(vif_o);
            
            this.add_agent(m_a_agent);
            this.add_agent(m_b_agent);
            this.add_agent(m_o_agent);
        endfunction
    endclass
    
    /// A = 0, B = 0
    class floatmul_test2_0_0 extends floatmul_utest;
        function new (
            virtual svutest_test_ctrl_if.target vif_test_ctrl,
            virtual svutest_dut_ctrl_if vif_dut_ctrl,
            T_vif vif_a,
            T_vif vif_b,
            T_vif vif_o
        );
            super.new(vif_test_ctrl, vif_dut_ctrl, vif_a, vif_b, vif_o, "0_0");
        endfunction
        
        function void populate ();
            m_a_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent: '0, mantissa: '0 } });
            m_b_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent: '0, mantissa: '0 } });
        endfunction
        
        function void check ();
            `UTEST_ASSERT_EQ($size(m_o_agent.m_mon_queue), 1)
            
            `UTEST_ASSERT_EQ(m_o_agent.m_mon_queue[0].payload, '1)
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
            virtual svutest_dut_ctrl_if vif_dut_ctrl,
            T_vif vif_a,
            T_vif vif_b,
            T_vif vif_o
        );
            super.new(vif_test_ctrl, vif_dut_ctrl, vif_a, vif_b, vif_o, "012_012");
        endfunction
        
        function void populate ();
            m_a_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent:  '0, mantissa: '0 } });
            m_a_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent:  '0, mantissa: '0 } });
            m_a_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent:  '0, mantissa: '0 } });
            m_a_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent: 127, mantissa: '0 } });
            m_a_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent: 127, mantissa: '0 } });
            m_a_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent: 127, mantissa: '0 } });
            m_a_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent: 128, mantissa: '0 } });
            m_a_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent: 128, mantissa: '0 } });
            m_a_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent: 128, mantissa: '0 } });
            
            m_b_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent:  '0, mantissa: '0 } });
            m_b_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent: 127, mantissa: '0 } });
            m_b_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent: 128, mantissa: '0 } });
            m_b_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent:  '0, mantissa: '0 } });
            m_b_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent: 127, mantissa: '0 } });
            m_b_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent: 128, mantissa: '0 } });
            m_b_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent:  '0, mantissa: '0 } });
            m_b_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent: 127, mantissa: '0 } });
            m_b_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent: 128, mantissa: '0 } });
        endfunction
        
        function void check ();
            `UTEST_ASSERT_EQ($size(m_o_agent.m_mon_queue), 9)
            
            `UTEST_ASSERT_EQ(m_o_agent.m_mon_queue[0].payload, float32_t'{ sign: 0, exponent:   0, mantissa: 0 })
            `UTEST_ASSERT_EQ(m_o_agent.m_mon_queue[1].payload, float32_t'{ sign: 0, exponent:   0, mantissa: 0 })
            `UTEST_ASSERT_EQ(m_o_agent.m_mon_queue[2].payload, float32_t'{ sign: 0, exponent:   0, mantissa: 0 })
            `UTEST_ASSERT_EQ(m_o_agent.m_mon_queue[3].payload, float32_t'{ sign: 0, exponent:   0, mantissa: 0 })
            `UTEST_ASSERT_EQ(m_o_agent.m_mon_queue[4].payload, float32_t'{ sign: 0, exponent: 127, mantissa: 0 })
            `UTEST_ASSERT_EQ(m_o_agent.m_mon_queue[5].payload, float32_t'{ sign: 0, exponent: 128, mantissa: 0 })
            `UTEST_ASSERT_EQ(m_o_agent.m_mon_queue[6].payload, float32_t'{ sign: 0, exponent:   0, mantissa: 0 })
            `UTEST_ASSERT_EQ(m_o_agent.m_mon_queue[7].payload, float32_t'{ sign: 0, exponent: 128, mantissa: 0 })
            `UTEST_ASSERT_EQ(m_o_agent.m_mon_queue[8].payload, float32_t'{ sign: 0, exponent: 129, mantissa: 0 })
        endfunction
    endclass
endpackage
