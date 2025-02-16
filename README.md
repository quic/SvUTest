# SvUTest: A Unit Testing Framework in System Verilog

System Verilog Unit Testing Framework (SvUTest) is an open source framework for performing unit testing of lightweight hardware modules written in System Verilog. This project is inspired by [CppUTest](https://cpputest.github.io/), [Google Test](https://google.github.io/googletest) and UVM.

## Introduction

Large digital designs often contain hundreds of blocks organized into clusters, with verification done typically done at block, cluster and top levels, generally using UVM. A single block, can itself be quite large, consisting of anywhere between a handful to a hundred modules. Testing of these lower level modules is sometimes left to the block-level (or higher) verification environment, which results in a longer turnaround and higher risk. Building UVM testbenches for each lower-level module is quite cumbersome and generally not practical. While possible, this approach has issues that a UVM testbench can only run one test at a time and there's no inbuilt mechanism to consolidate results of multiple runs.

SvUTest is an attempt at a tool that helps designers write basic sanity checks on their building blocks with minimal overhead. With support for concurrent regressions and inbuilt consolidation of results, the framework enables quicker design sign-off.

## Target Audience

SvUTest is meant to be used by RTL design engineers to ensure the correctness of their designs across a known set of input patterns. This framework not meant to be a replacement for UVM and is only recommended for small designs with a handful of input/output interfaces and a set of input workloads whose output is known. UVM would still be the go-to solution for large designs with complex stimuli.

## Building a simple test case

Let's take a look at the floating-point multiplier block in examples/001_floatmul that we need to unit-test. This block, or the Design Under Test, has two input channels and an output channel, all following the valid-data-ready protocol:
```
input  logic        a_valid,
input  float32_t    a_payload,
output logic        a_ready,

input  logic        b_valid,
input  float32_t    b_payload,
output logic        b_ready,

output logic        o_valid,
output float32_t    o_payload,
input  logic        o_ready,
```
The valid on the output interface shall be asserted if and only if both the inputs' valids a_valid and b_valid are high.

In order to unit test this block, we need to build a test_top. The test_top is a System Verilog module with no ports and a single type parameter that accepts a test_case class that we'll build later as the parameter argument:
```
module floatmul_test_top
    // import any other packages needed by the DUT
    import svutest_pkg::*;
#(
    type T_test_case = bit  // Need to be overriden during instantiation
);
    ...
endmodule
```

In addition to the test_case parameter, the test top needs to instantiate the following items:
* A ``busy`` signal to indicate that the DUT is operational. This signal may be driven by the DUT or may be generated by the test top. In this example, busy is driven from the DUT.
* An instance of ``svutest_if_test_ctrl``. This interface supplies the clock and reset to the interior of the test top and collects the busy signal.
* An instance of ``svutest_if_valid_ready`` interface for each channel on the DUT. These interfaces supply the input transactions to the DUT as well as collect the output transactions from the DUT. ``svutest_if_valid_ready`` need to be replaced with the right interface in case the protocol is different from valid-data-ready.
* An instance of the DUT, with the ports on the DUT hooked to the signals from the svutest_if_test_ctrl and svutest_if_valid_ready interfaces.
* Finally, an ``initial .. begin`` block where the T_test_case parameter is instantiated. ``T_test_case`` can have it's own constructor and may take any number of arguments. The arguments typically pass the interfaces declared in the test top to the test case.

With the above instantiations in place, the test top is now complete:
```
module floatmul_test_top
    import floatmul_pkg::*;
    import svutest_pkg::*;
#(
    type T_test_case = bit
);
    svutest_if_test_ctrl tc ();
    
    svutest_if_valid_ready#(float32_t) i_a (tc.clk, tc.rst);
    svutest_if_valid_ready#(float32_t) i_b (tc.clk, tc.rst);
    svutest_if_valid_ready#(float32_t) i_o (tc.clk, tc.rst);
    
    // ---------------------------------------------------------------------- //
    
    floatmul u_fmul (
        .clk        (tc.clk),
        .rst        (tc.rst),
        .busy       (tc.busy),
        
        .a_valid    (i_a.valid),
        .a_payload  (i_a.payload),
        .a_ready    (i_a.ready),
        
        .b_valid    (i_b.valid),
        .b_payload  (i_b.payload),
        .b_ready    (i_b.ready),
        
        .o_valid    (i_o.valid),
        .o_payload  (i_o.payload),
        .o_ready    (i_o.ready)
    );
    
    // ---------------------------------------------------------------------- //
    
    initial begin
        T_test_case test;
        test = new(tc, i_a, i_b, i_o);
    end
endmodule
```

Once the test top is built, we now need to build a test_case class that drives the input interfaces and evaluates the output transactions. The test case class is derived from ``svutest_pkg::test_case`` and acts as a base class for all test sequences for current DUT. ``svutest_pkg::test_case`` class drives the clock and reset to the DUT while monitoring the busy, manages the interfaces which the drive the DUT and accepts the svutest_if_test_ctrl interface and a test name as constructor arguments:

```
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
        
        // test_case takes a svutest_if_test_ctrl and a string as arguments.
        // The caller of this class's constructor need to pass the 
        // svutest_if_test_ctrl instance and a valid test name
        super.new(vif_test_ctrl, $sformatf("fmul:%0s", test_case_name));
        
        a_driver = new(vif_a);
        b_driver = new(vif_b);
        o_driver = new(vif_o);
        
        m_a_agent = new(this, a_driver);
        m_b_agent = new(this, b_driver);
        m_o_agent = new(this, o_driver);
    endfunction
endclass
```

``sv_utest_pkg`` provides drivers for 4 different interface protocols:
1. Simple data without any qualifier
2. Data with valid
3. Data with valid and ready
4. Data vector with valid_count and ready_count. The number of transfers that happens on a cycle will be equal to min(valid_count, ready_count)

The package also provides 3 different agent classes that can work with each of the above protocols:
1. Sender agent, which injects data into the DUT
2. Target agent, which drives response into the DUT, while also extracting output from the DUT
3. Monitor agent, which only monitors an output interface of the DUT without prodiving any response

The example above instantiates two sender agents and an output agent inside the class and their corresponding driver objects inside the constructor. The driver instances are not needed after the agents are formed and can be declared as local varaibles inside the constructor. The constructor connects the virtual interfaces to the drivers and passes the drivers to the agents. (Note: This syntax may change in future versions).

Once the drivers and agents are set up, the user needs to extend the base class once again and populate two virtual functions ``test_case::inject()`` and ``test_case::check``. ``inject()`` is used to push transactions into different sender agents. The sender_agent class provides a function ``put()`` to pass a transaction to the DUT through the driver. Any number of ``put()`` calls may be made from the inject function.

The transactions emitted from the output channels of the DUT are collected by the target and monitor agents and populated into an internal queue called ``m_mon_queue``. This queue can be queried from the virtual function ``check()`` for correctness of output transactions. Two macros ``UTEST_ASSERT(expr)`` and ``UTEST_ASSERT_EQ(expr_lhs, expr_rhs)`` are provided by ``svutest_defines.svh`` to help the user with the timestamp, line number and a failure count summary for the given test.

```
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
        // Inject 0.0 on interface A
        m_a_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent: '0, mantissa: '0 } });
        // Inject 0.0 on interface B
        m_b_agent.put('{ valid: 1'b1, payload: '{ sign: 1'b0, exponent: '0, mantissa: '0 } });
    endfunction
    
    function void check ();
        // Expect a single extry in the output queue of interface O
        `UTEST_ASSERT_EQ($size(m_o_agent.m_mon_queue), 1)
        
        // Expect the first entry in the output queue of interface O to be 0.0
        `UTEST_ASSERT_EQ(m_o_agent.m_mon_queue[0].payload, '0)
    endfunction
endclass
```

Once the test_top and test cases are set up, we need to populate a top module where we instantiate the test top and trigger the start of the regression:
```
`include "svutest_defines.svh"

module regress_top;
    import svutest_pkg::*;
    import floatmul_test_pkg::*;
    
    // Instantiate test cases floatmul_test_0_0 and floatmul_test_012_012
    // for floatmul_test_top
    `UTEST(floatmul_test_top, floatmul_test_0_0)
    `UTEST(floatmul_test_top, floatmul_test_012_012)
    
    initial begin
        regress_suite::run_all_tests();
    end
endmodule
```

The ``UTEST(module, test_case)`` macro creates an instance of ``module`` while passing ``test_case`` through the parameter list. Once all the required test cases are instantiated, we need to call ``regress_suite::run_all_tests();`` from an initial block as shown above.

The command runs all instantiated test cases, in no specific order, and prints a summary (pass +color to the simulation environment for print in color) on the console:
```
001_floatmul/floatmul_test_pkg.sv", 109: floatmul_test_pkg::\floatmul_test_012_012::check .unnamed$$_8: started at 15000s failed at 15000s
        Offending '(this.m_o_agent.m_mon_queue[3].payload === float32_t'{sign:0, exponent:0, mantissa:0})'
       15000 | UTEST_ASSERT_EQ failed. Test: fmul:012_012. Left == 0x7f000000, right == 0x0
"001_floatmul/floatmul_test_pkg.sv", 111: floatmul_test_pkg::\floatmul_test_012_012::check .unnamed$$_12: started at 15000s failed at 15000s
        Offending '(this.m_o_agent.m_mon_queue[5].payload === float32_t'{sign:0, exponent:128, mantissa:0})'
       15000 | UTEST_ASSERT_EQ failed. Test: fmul:012_012. Left == 0x7f000000, right == 0x80000000
"001_floatmul/floatmul_test_pkg.sv", 112: floatmul_test_pkg::\floatmul_test_012_012::check .unnamed$$_14: started at 15000s failed at 15000s
        Offending '(this.m_o_agent.m_mon_queue[6].payload === float32_t'{sign:0, exponent:0, mantissa:0})'
       15000 | UTEST_ASSERT_EQ failed. Test: fmul:012_012. Left == 0x80000000, right == 0x0
"001_floatmul/floatmul_test_pkg.sv", 114: floatmul_test_pkg::\floatmul_test_012_012::check .unnamed$$_18: started at 15000s failed at 15000s
        Offending '(this.m_o_agent.m_mon_queue[8].payload === float32_t'{sign:0, exponent:129, mantissa:0})'
       15000 | UTEST_ASSERT_EQ failed. Test: fmul:012_012. Left == 0x80000000, right == 0x81000000
       15000 | fmul:0_0> DONE, PASS (2 / 2)
       15000 | fmul:012_012> DONE, FAIL (6 / 10)
       15000 | Status: DONE, FAIL | (Done: 2, Timeout: 0), (Pass: 1, Fail: 1, Unknown: 0)
```

## Compiling and running

SvUTest framework contains only two source files: src/svutest_pkg.sv src/svutest_ctrl.sv and one header file: src/svutest_defines.svh, and can be built using any System Verilog compliant compiler. The source files need to be passed to your eda tool like SV modules while the header file is typically picked up by providing the include path. A typical invocation from the command line would be:

```
<tool> src/svutest_pkg.sv src/svutest_ctrl.sv <include_path_flag> src/ path_to_other_files
```

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Getting in Contact

* [Report an Issue on GitHub](../../issues)
* [Open a Discussion on GitHub](../../discussions)
* [E-mail us](mailto:quic-nvettuva@quicinc.com) for general questions

## License

SvUTest is licensed under the [BSD-3-clause License](https://spdx.org/licenses/BSD-3-Clause.html). See [LICENSE.txt](LICENSE.txt) for the full license text.
