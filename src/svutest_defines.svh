// Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause-Clear

`ifndef UTEST_DEFINES_SVH
`define UTEST_DEFINES_SVH

/// Instantiate test_case for test_top
`define UTEST(test_top, test_case)                                          \
    test_top #(test_case) u_``test_top``_``test_case`` ();

/// Instantiate test_case for test_top
`define UTEST2(test_top, test_case)                                         \
    svutest_dut_ctrl_if i_``test_case`` ();                                 \
    test_top#(test_case) u_``test_top``_``test_case`` (i_``test_case``);

/// Instatiate test_case for test_top with param
/// test_top needs to support the extra compile-time param
`define UTEST_PARAM(test_top, test_case, param)                             \
    test_top #(test_case, param) u_``test_top``_``test_case`` ();

/// Generic assertion
`define UTEST_ASSERT(expr)                                                  \
    assert (expr) begin                                                     \
        this.m_pass_count++;                                                \
    end else begin                                                          \
        string msg_str;                                                     \
        if ($test$plusargs("color")) begin                                  \
            msg_str = "\033[0;31mUTEST_ASSERT failed\033[0m";               \
        end else begin                                                      \
            msg_str = "UTEST_ASSERT failed";                                \
        end                                                                 \
        $write("%12t | %0s. Test: %0s. Left == 0x%0h, right == 0x%0h\n",    \
            $time, msg_str, m_test_name, expr_lhs, expr_rhs);               \
        this.m_fail_count++;                                                \
    end

/// Assert if equality comparison fails
`define UTEST_ASSERT_EQ(expr_lhs, expr_rhs)                                 \
    assert (expr_lhs === expr_rhs) begin                                    \
        this.m_pass_count++;                                                \
    end else begin                                                          \
        string msg_str;                                                     \
        if ($test$plusargs("color")) begin                                  \
            msg_str = "\033[0;31mUTEST_ASSERT_EQ failed\033[0m";            \
        end else begin                                                      \
            msg_str = "UTEST_ASSERT_EQ failed";                             \
        end                                                                 \
        $write("%12t | %0s. Test: %0s. Left == 0x%0h, right == 0x%0h\n",    \
            $time, msg_str, m_test_name, (expr_lhs), (expr_rhs));           \
        this.m_fail_count++;                                                \
    end

`endif
