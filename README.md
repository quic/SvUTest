# SvUTest: A Unit Testing Framework in System Verilog

System Verilog Unit Testing Framework (SvUTest) is a framework for performing unit testing of lightweight hardware modules written in System Verilog. This project is inspired by [CppUTest](https://cpputest.github.io/), [Google Test](https://google.github.io/googletest) and UVM.

## Introduction

Large digital designs often contain hundreds of blocks organized into clusters, with verification done typically done at block, cluster and top levels, generally using UVM. A single block, can itself be quite large, consisting of anywhere between a handful to a hundred modules. Testing of these lower level modules is sometimes left to the block-level (or higher) verification environment, which results in a longer turnaround and higher risk. Building UVM testbenches for each lower-level module is quite cumbersome and generally not practical. While possible, this approach has issues that a UVM testbench can only run one test at a time and there's no inbuilt mechanism to consolidate results of multiple runs.

SvUTest is an attempt at a tool that helps designers write basic sanity checks on their building blocks with minimal overhead. With support for concurrent regressions and inbuilt consolidation of results, the framework enables quicker design sign-off.

## Target Audience

SvUTest is meant to be used by RTL design engineers to ensure the correctness of their designs across a known set of input patterns.

## UVM

SvUTest is not meant to replace UVM. SvUTest is only recommended for small designs with a handful of input and output interfaces and a set of input workloads whose output is known. UVM would still be the go-to solution for large designs with complex stimuli.

## Requirements

A System Verilog compatible compiler and simulator

## Example

TODO: This section will be expanded soon.

## Usage

TODO: Will be expanded soon

```
<tool> src/svutest_pkg.sv src/svutest_ctrl.sv <include_path_flag> src
```

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Getting in Contact

* [Report an Issue on GitHub](../../issues)
* [Open a Discussion on GitHub](../../discussions)
* [E-mail us](mailto:quic-nvettuva@quicinc.com) for general questions

## License

SvUTest is licensed under the [BSD-3-clause License](https://spdx.org/licenses/BSD-3-Clause.html). See [LICENSE.txt](LICENSE.txt) for the full license text.
