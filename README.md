# Blake512
---
## C (Blake-512 Algorithm Overview)
 : The Blake-512 algorithm is a cryptographic hash function that transforms arbitrary input data into a fixed-length encrypted output.
- **Input**: `gX13` (80 bytes)  
- **Output**: `dst` (64 bytes)
    ### 1. Initialization
    : The internal state `state.H` is initialized with the predefined constant `IV512`.  The 80-byte input message is copied into `state.buf`.
    ### 2. Padding
    : Padding is constructed using `tmpbuf`:
            -  Append `0x80` to the input
            - Fill the remaining bytes with zeros
            - Insert the message length (640 bits) into `T0`
     This forms a single 128-byte (1024-bit) message block.
    ### 3. State Construction
    : The working state `state.V` consists of sixteen 64-bit registers:
      - `V[0]–V[7]` are directly copied from `state.H`
      - `V[8]–V[15]` are initialized by XORing constants (`CB0–CB7`) with counter values (`T0`, `T1`)
    ### 4. Message Word Array (M)
    : The 128-byte `state.buf` is interpreted as sixteen 64-bit words and stored in `M[0]–M[15]`.
    ### 5. Compression Loop
    : A total of **16 rounds** (`k = 0–15`) are executed.  In each round:
      - Message word indices are permuted using the `sigma[k][ ]` table
      - The `GB()` function is invoked **8 times** to repeatedly mix `V[0]–V[15]`
    The `GB()` function combines 64-bit modular addition, XOR, and rotation operations to strongly mix four state variables (`a`, `b`, `c`, `d`) in two stages.
    ### 6. Final Output
    : After completing all 16 rounds, the hash state is updated as: `H[i] ^= V[i] ^ V[i+8]`
---
## Verilog
** If you want to check the cycle count, uncomment the `$display` section in `tb.v`.
- ### 8Gcore :
  An Structure that invokes the GB function eight times and generates the final output within 16 cycles. Since this is an early prototype, the code is not yet well-refined.
- ### 1Gcore :
  A structure in which the GB function is invoked once and executed over a total of 128 cycles.
  -   **version 1**: When the finalization stage in the `datapath.v` is implemented sequentially, the total latency becomes 129 cycles.
                    If implemented combinationally, it completes in 128 cycles. However, due to a race condition with the testbench, a hash failure occurs; adding a delay to the output comparison in `tb.v` resolves                      this and the hash completes correctly.
  -   **version 2**: The Structure was modularized, with the controller and counter implemented as separate modules, and FSM signals provided accordingly, reducing the number of control signals.
