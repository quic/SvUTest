# SvUTest: A Unit Testing Framework in System Verilog

System Verilog Unit Testing Framework (SvUTest) is an open source framework for performing rapid sanity testing of lightweight hardware modules in System Verilog. This project is inspired by [CppUTest](https://cpputest.github.io/), [Google Test](https://google.github.io/googletest) and UVM.

## Features

* Rapid test case development
* Concurrent regressions
* Consolidation of regression status
* Inbuilt support for interface protocols like valid-ready and credit-data

## Target Audience

SvUTest is meant to help RTL designers ensure the basic sanity of small designs whose outputs can be predicted for a given set of inputs. This is not a replacement for UVM based tests.

## Building a unit test

### Design under test:

Let's say we need to test a module that multiplies two floating point numbers:

```systemverilog
package floatmul_pkg;
    typedef struct packed {
        logic           sign;
        logic [7:0]     exponent;
        logic [23:0]    mantissa;
    } float32_t;
endpackage

module floatmul
    import floatmul_pkg::*;
(
    input  logic        clk,
    input  logic        rst,
    output logic        busy,
    
    input  logic        a_valid,
    input  float32_t    a_data,
    output logic        a_ready,
    
    input  logic        b_valid,
    input  float32_t    b_data,
    output logic        b_ready,
    
    output logic        o_valid,
    output float32_t    o_data,
    input  logic        o_ready
);
    // Implementation
    
    a_ready = /* .. */;
    b_ready = /* .. */;
    
    o_valid = /* .. */;
    o_data = /* .. */
endmodule
```

### Test Top:

We start by creating a ``test_top`` module which has a single interface port of type ``svutest_test_ctrl_if.target`` and a single type parameter ``T_test_case``. It instantiates the DUT and calls the ``run()`` method of ``T_Test_case``:

```verilog
module floatmul_test_top
    import floatmul_pkg::*;
#(
    type T_test_case = bit              // Test case
)(
    svutest_test_ctrl_if.target tc      // Test control from the regress suite
);
    // DUT control. Injects clock + rst, and collects test-done
    svutest_dut_ctrl_if dc ();
    
    // Input and output interfaces to DUT
    svutest_req_payload_rsp_if#(float32_t) a (dc.clk, dc.rst);
    svutest_req_payload_rsp_if#(float32_t) b (dc.clk, dc.rst);
    svutest_req_payload_rsp_if#(float32_t) o (dc.clk, dc.rst);
    
    logic busy;
    
    // Instantiate the
    floatmul u_fmul (
        .clk        (dc.clk),
        .rst        (dc.rst),
        .busy       (busy),
        
        .a_valid    (a.req),
        .a_data     (a.req_payload),
        .a_ready    (a.rsp),
        
        .b_valid    (b.req),
        .b_data     (b.req_payload),
        .b_ready    (b.rsp),
        
        .o_valid    (o.req),
        .o_data     (o.req_payload),
        .o_ready    (o.rsp)
    );
    
    // Set this signal once the test is done
    always_comb dc.done = ~(a.req | b.req | o.req | busy);
    
    initial begin
        // Instantiate the test case, pass the test_ctrl and dut_ctrl ifs,
        // along other inputs and outputs. And call run().
        T_test_case test = new(tc, dc, a, b, o);    
        test.run();
    end
endmodule
```

### Test Case Base class

Once the test top is set up, we need to create a test case base class per dut, derived from svutest_pkg::test_case, that accepts the test_ctrl, dut_ctrl and other interfaces:

```verilog
class floatmul_utest extends svutest_pkg::test_case;
    valid_data_ready_injector#(float32_t) m_a_injector;     // Built-in injector for valid-ready protocol (input a)
    valid_data_ready_injector#(float32_t) m_b_injector;     // Injector for input b
    valid_data_ready_extractor#(float32_t) m_o_extractor;   // Extractor for output c
    
    function new (
        virtual svutest_test_ctrl_if.target vif_test_ctrl,              // Test Ctrl
        virtual svutest_dut_ctrl_if.driver vif_dut_ctrl,                // Dut Ctrl
        virtual svutest_req_payload_rsp_if#(float32_t).driver vif_a,    // a
        virtual svutest_req_payload_rsp_if#(float32_t).driver vif_b,    // b
        virtual svutest_req_payload_rsp_if#(float32_t).target vif_o,    // c
        string test_case_name                                           // Test name
    );
        // Pass test-ctrl, dut_ctrl and test_name to svutest_pkg::test_case::new()
        super.new(vif_test_ctrl, vif_dut_ctrl, $sformatf("fmul:%0s", test_case_name));
        
        // Create injectors and extractors
        m_a_injector = new(vif_a);
        m_b_injector = new(vif_b);
        m_o_extractor = new(vif_o);
        
        // And register them with the test case
        this.add(m_a_injector);
        this.add(m_b_injector);
        this.add(m_o_extractor);
    endfunction
endclass
```

### Test Case

The next step is to create a test case class per input-output pattern, derived from the base class:

```verilog
class floatmul_utest_0_0 extends floatmul_utest;
    function new (
        virtual svutest_test_ctrl_if.target vif_test_ctrl,
        virtual svutest_dut_ctrl_if.driver vif_dut_ctrl,
        virtual svutest_req_payload_rsp_if#(float32_t).driver vif_a,
        virtual svutest_req_payload_rsp_if#(float32_t).driver vif_b,
        virtual svutest_req_payload_rsp_if#(float32_t).target vif_o
    );
        super.new(vif_test_ctrl, vif_dut_ctrl, vif_a, vif_b, vif_o, "0_0");
    endfunction
    
    // Override the populate() virtual function to set up the transcations
    // that will be injected per interface. This is a function that is
    // run once before actual simulation
    function void populate ();
        m_a_injector.put('{ sign: 1'b0, exponent: '0, mantissa: '0 });
        m_b_injector.put('{ sign: 1'b0, exponent: '0, mantissa: '0 });
    endfunction
    
    // Override the check() virtual function to check the number of
    // outputs emitted and the expectation of each output
    function void check ();
        // Get the extractor's internal queue
        float32_t queue [$] = m_o_extractor.get_queue();
        
        // Check the number of entries emitted from the output
        `SVUTEST_ASSERT_EQ(queue.size(), 1)
        // Check the first entry
        `SVUTEST_ASSERT_EQ(queue[0], '1)
    endfunction
endclass
```

### Regression Top

The last step is to create a top module that instantiates the test cases and runs them:

```verilog
module regress_top;
    import svutest_pkg::*;
    import floatmul_utest_pkg::*;
    
    // Create the test_ctrl interface
    svutest_test_ctrl_if i_floatmul_test2_0_0 ();
    // Instantiate the test_top while passing the test_ctrl interface
    floatmul_test_top#(floatmul_test2_0_0) u_floatmul_test2_0_0 (i_floatmul_test2_0_0);
    
    // Another test case, using a macro that does the above in one line
    `SVUTEST(floatmul_test_top, floatmul_test2_012_012)
    
    // Test cases for a different DUT
    `SVUTEST(fibonacci_utest_top, fibonacci_utest_0)
    `SVUTEST(fibonacci_utest_top, fibonacci_utest_1)
    `SVUTEST(fibonacci_utest_top, fibonacci_utest_2)
    `SVUTEST(fibonacci_utest_top, fibonacci_utest_3)
    `SVUTEST(fibonacci_utest_top, fibonacci_utest_5)
    `SVUTEST(fibonacci_utest_top, fibonacci_utest_8)
    `SVUTEST(fibonacci_utest_top, fibonacci_utest_0_2)
    `SVUTEST(fibonacci_utest_top, fibonacci_utest_1_5)
    `SVUTEST(fibonacci_utest_top, fibonacci_utest_2_0_3)
    
    initial begin
        // Create a test-list
        test_list list = new();
        
        // Add the test cases to the list by passing the interfaces to add()
        list.add(i_floatmul_test2_0_0);     
        list.add(i_floatmul_test2_012_012);
        list.add(i_fibonacci_utest_0);
        list.add(i_fibonacci_utest_1);
        list.add(i_fibonacci_utest_2);
        list.add(i_fibonacci_utest_3);
        list.add(i_fibonacci_utest_5);
        list.add(i_fibonacci_utest_8);
        list.add(i_fibonacci_utest_0_2);
        list.add(i_fibonacci_utest_1_5);
        list.add(i_fibonacci_utest_2_0_3);
        
        // Run all tests in the test list
        list.run();
    end
endmodule
```

### Output

The ``run()`` task of ``test_list`` outputs one line of summary per test case, showing the number of assertions that failed in that test case. A complete summary will be printed at the end. Any failure from ``SVUTEST_ASSERT_EQ`` macros will get printed in additional lines:

```
        7000 | fmul:0_0> SVUTEST_ASSERT_EQ failed: /usr2/nvettuva/SvUTest/examples/001_floatmul/floatmul_utest_pkg.sv,58: Expected == 0x0, actual == 0x1
        7000 | fmul:0_0> COMPLETE. Assertions: 1/2 [FAIL]
        7000 | fibonacci:0> COMPLETE. Assertions: 1/1 [PASS]
        7000 | fibonacci:1> COMPLETE. Assertions: 2/2 [PASS]
        7000 | fibonacci:2> COMPLETE. Assertions: 3/3 [PASS]
        8000 | fibonacci:3> COMPLETE. Assertions: 4/4 [PASS]
        8000 | fibonacci:0_2> COMPLETE. Assertions: 3/3 [PASS]
       10000 | fibonacci:5> COMPLETE. Assertions: 6/6 [PASS]
       11000 | fibonacci:1_5> COMPLETE. Assertions: 7/7 [PASS]
       11000 | fibonacci:2_0_3> COMPLETE. Assertions: 6/6 [PASS]
       13000 | fibonacci:8> COMPLETE. Assertions: 9/9 [PASS]
       15000 | fmul:012_012> SVUTEST_ASSERT_EQ failed: /usr2/nvettuva/SvUTest/examples/001_floatmul/floatmul_utest_pkg.sv,108: Expected == 0x7f000000, actual == 0x0
       15000 | fmul:012_012> SVUTEST_ASSERT_EQ failed: /usr2/nvettuva/SvUTest/examples/001_floatmul/floatmul_utest_pkg.sv,110: Expected == 0x7f000000, actual == 0x80000000
       15000 | fmul:012_012> SVUTEST_ASSERT_EQ failed: /usr2/nvettuva/SvUTest/examples/001_floatmul/floatmul_utest_pkg.sv,111: Expected == 0x80000000, actual == 0x0
       15000 | fmul:012_012> SVUTEST_ASSERT_EQ failed: /usr2/nvettuva/SvUTest/examples/001_floatmul/floatmul_utest_pkg.sv,113: Expected == 0x80000000, actual == 0x81000000
       15000 | fmul:012_012> COMPLETE. Assertions: 6/10 [FAIL]
       15000 | Status: FAIL | Total: 11, Unresponsive: 0, Timeout: 0, Unchecked: 0, Fail: 2, Pass: 9
```

## Compiling and running

SvUTest framework contains 2 source files:
```
src/svutest_if.sv
src/svutest_pkg.sv
```
and a few header files defined under src:
```
src/svutest_defines.svh
...
```

The source files must be compiled in the order specified above by the user's eda tool like while the header file is typically picked up by providing the include path. A typical invocation from the command line would be:

```
<tool> src/svutest_if.sv src/svutest_pkg.sv <include_path_flag> src path_to_other_files
```

## Documentation

See [guide.md](doc/guide.md) for more information.

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Getting in Contact

* [Report an Issue on GitHub](../../issues)
* [Open a Discussion on GitHub](../../discussions)
* [E-mail us](mailto:quic-nvettuva@quicinc.com) for general questions

## License

SvUTest is licensed under the [BSD-3-clause License](https://spdx.org/licenses/BSD-3-Clause.html). See [LICENSE.txt](LICENSE.txt) for the full license text.
