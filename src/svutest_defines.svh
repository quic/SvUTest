// Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
// SPDX-License-Identifier: BSD-3-Clause-Clear

`ifndef SVUTEST_DEFINES_SVH
`define SVUTEST_DEFINES_SVH

/// Instantiate test_case for test_top
`define SVUTEST(test_top, test_case)                                        \
    svutest_test_ctrl_if i_``test_case`` ();                                \
    test_top#(test_case) u_``test_top``_``test_case`` (i_``test_case``);

/// Instatiate test_case for test_top with a param
/// test_top needs to support the extra compile-time param
`define SVUTEST_PARAM(test_top, test_case, param)                           \
    svutest_test_ctrl_if i_``test_case``_``param`` ();                      \
    test_top#(test_case, param) u_``test_top``_``test_case`` (i_``test_case``_``param``);

/// Generic assertion
`define SVUTEST_ASSERT(expr)                                                \
    if (expr) begin                                                         \
        this.m_pass_count++;                                                \
    end else begin                                                          \
        string msg_str;                                                     \
        if ($test$plusargs("svutest_color")) begin                          \
            msg_str = "\033[0;31mSVUTEST_ASSERT failed\033[0m";             \
        end else begin                                                      \
            msg_str = "SVUTEST_ASSERT failed";                              \
        end                                                                 \
        $write("%12t | %0s> %0s: %0s,%0d: Expr == 0x%0h\n",                 \
            $time, m_test_name, msg_str, `__FILE__, `__LINE__,              \
            (expr));                                                        \
        this.m_fail_count++;                                                \
    end

/// Assert if equality comparison fails
`define SVUTEST_ASSERT_EQ(expr_expected, expr_actual)                               \
    if ((expr_expected) === (expr_actual)) begin                                    \
        this.m_pass_count++;                                                        \
    end else begin                                                                  \
        string msg_str;                                                             \
        if ($test$plusargs("svutest_color")) begin                                  \
            msg_str = "\033[0;31mSVUTEST_ASSERT_EQ failed\033[0m";                  \
        end else begin                                                              \
            msg_str = "SVUTEST_ASSERT_EQ failed";                                   \
        end                                                                         \
        $write("%12t | %0s> %0s: %0s,%0d: Expected == 0x%0h, actual == 0x%0h\n",    \
            $time, m_test_name, msg_str, `__FILE__, `__LINE__,                      \
            (expr_expected), (expr_actual));                                        \
        this.m_fail_count++;                                                        \
    end

`endif
