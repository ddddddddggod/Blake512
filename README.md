# Blake512
---
** If you want to check the cycle count, uncomment the `$display` section in `tb.v`.
- ### 8Gcore :
  An Structure that invokes the GB function eight times and generates the final output within 16 cycles. Since this is an early prototype, the code is not yet well-refined.
- ### 1Gcore :
  A structure in which the GB function is invoked once and executed over a total of 128 cycles.
  -   version 1: When the finalization stage in the `datapath.v` is implemented sequentially, the total latency becomes 129 cycles.
                    If implemented combinationally, it completes in 128 cycles. However, due to a race condition with the testbench, a hash failure occurs; adding a delay to the output comparison in `tb.v` resolves                      this and the hash completes correctly.
  -   version 2: The Structure was modularized, with the controller and counter implemented as separate modules, and FSM signals provided accordingly, reducing the number of control signals.
