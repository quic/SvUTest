// Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause-Clear

`include "svutest_defines.svh"

package floatmul_test_pkg;
    import svutest_pkg::*;
    import floatmul_pkg::*;
    
    /// Base class for all test-cases of floatmul
    class floatmul_utest extends test_case;
        typedef valid_ready_driver#(float32_t) T_a_driver;
        typedef valid_ready_driver#(float32_t) T_b_driver;
        typedef valid_ready_driver#(float32_t) T_o_driver;
        
        sender_agent#(T_a_driver) m_a_agent;
        sender_agent#(T_b_driver) m_b_agent;
        target_agent#(T_o_driver) m_o_agent;
        
        function new (
            virtual svutest_if_test_ctrl vif_test_ctrl,
            T_a_driver::T_vif vif_a,    // Driver class has a T_vif
            T_b_driver::T_vif vif_b,    // typedef for convenience
            T_o_driver::T_vif vif_o,
            string test_case_name
        );
            T_a_driver a_driver;
            T_b_driver b_driver;
            T_o_driver o_driver;
            
            super.new(vif_test_ctrl, $sformatf("fmul:%0s", test_case_name));
            
            a_driver = new(vif_a);
            b_driver = new(vif_b);
            o_driver = new(vif_o);
            
            m_a_agent = new(this, a_driver);
            m_b_agent = new(this, b_driver);
            m_o_agent = new(this, o_driver);
        endfunction
    endclass
    
    /// A = 0, B = 0
    class floatmul_test_0_0 extends floatmul_utest;
        function new (
            virtual svutest_if_test_ctrl vif_test_ctrl,
            T_a_driver::T_vif vif_a,
            T_b_driver::T_vif vif_b,
            T_o_driver::T_vif vif_o
        );
            super.new(vif_test_ctrl, vif_a, vif_b, vif_o, "0_0");
        endfunction
        
        function void inject ();
            m_a_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent: '0, mantissa: '0 } });
            m_b_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent: '0, mantissa: '0 } });
        endfunction
        
        function void check ();
            `UTEST_ASSERT_EQ($size(m_o_agent.m_mon_queue), 1)
            
            `UTEST_ASSERT_EQ(m_o_agent.m_mon_queue[0].payload, '0)
        endfunction
    endclass
    
    /// Sequence of 9 input pairs
    /// (A, B) =
    ///     (0, 0) => (0, 1) => (0, 2) =>
    ///     (1, 0) => (1, 1) => (1, 2) =>
    ///     (2, 0) => (2, 1) => (2, 2)
    class floatmul_test_012_012 extends floatmul_utest;
        function new (
            virtual svutest_if_test_ctrl vif_test_ctrl,
            T_a_driver::T_vif vif_a,
            T_b_driver::T_vif vif_b,
            T_o_driver::T_vif vif_o
        );
            super.new(vif_test_ctrl, vif_a, vif_b, vif_o, "012_012");
        endfunction
        
        function void inject ();
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
