`timescale 1ns / 1ps
module alu_4bit_tb;

    reg  [3:0] A, B, sel;
    reg        cin;
    wire [3:0] result;
    wire       cout, overflow, zero, negative;

    integer pass_count = 0;
    integer fail_count = 0;

    alu_4bit DUT (
        .A(A),
        .B(B),
        .sel(sel),
        .cin(cin),
        .result(result),
        .cout(cout),
        .overflow(overflow),
        .zero(zero),
        .negative(negative)
    );

  
    task check (
        //ASCII value
        input [127:0] op_name,
        input [3:0]   exp_result,
        input         exp_cout,
        input         exp_zero,
        input         exp_negative,
        input         exp_overflow
    );
        begin
            #10; 

            if (result === exp_result && cout === exp_cout && zero === exp_zero && negative === exp_negative && overflow === exp_overflow) begin
              
                pass_count = pass_count + 1;
                $display("PASS | %s A=%b B=%b cin=%b | result=%b cout=%b zero=%b neg=%b ovf=%b",op_name, A, B, cin, result, cout, zero, negative, overflow);
            end 
          else begin
                
            fail_count = fail_count + 1;
            $display("FAIL | %s A=%b B=%b cin=%b | got: result=%b cout=%b zero=%b neg=%b ovf=%b | expected: result=%b cout=%b zero=%b neg=%b ovf=%b",op_name, A, B, cin, result, cout, zero, negative, overflow,exp_result, exp_cout, exp_zero, exp_negative, exp_overflow);
            end
          
        end
      
    endtask

    initial begin
        $display("=================================================");
        $display(" 4-bit ALU Testbench - Test Cases");
        $display("=================================================");

        // ---------------- ADD ----------------
        A = 4'b0011; B = 4'b0010; sel = 4'b0000; cin = 0; // 3 + 2 = 5
        check("ADD", 4'b0101, 0, 0, 0, 0);

        A = 4'b0111; B = 4'b0001; sel = 4'b0000; cin = 0; // 7 + 1 = 8 -> signed overflow
      check("ADD", 4'b1000, 0, 0, 1, 1);

        A = 4'b1111; B = 4'b0001; sel = 4'b0000; cin = 0; // 15 + 1 = 16 -> unsigned carry-out
        check("ADD", 4'b0000, 1, 1, 0, 0);

        // ---------------- SUB ----------------
        A = 4'b0101; B = 4'b0011; sel = 4'b0001; cin = 0; // 5 - 3 = 2
        check("SUB", 4'b0010, 0, 0, 0, 0);

        A = 4'b0101; B = 4'b0101; sel = 4'b0001; cin = 0; // 5 - 5 = 0
        check("SUB", 4'b0000, 0, 1, 0, 0);

        A = 4'b0001; B = 4'b0010; sel = 4'b0001; cin = 0; // 1 - 2 = -1 (borrow, negative)
        check("SUB", 4'b1111, 1, 0, 1, 0);

        // ---------------- AND / OR / XOR ----------------
        A = 4'b1100; B = 4'b1010; sel = 4'b0010; // AND
        check("AND", 4'b1000, 0, 0, 1, 0);

        A = 4'b1100; B = 4'b1010; sel = 4'b0011; // OR
        check("OR", 4'b1110, 0, 0, 1, 0);

        A = 4'b1100; B = 4'b1010; sel = 4'b0100; // XOR
        check("XOR", 4'b0110, 0, 0, 0, 0);

        // ---------------- NOR / NAND / XNOR ----------------
        A = 4'b1100; B = 4'b1010; sel = 4'b0101; // NOR
        check("NOR", 4'b0001, 0, 0, 0, 0);

        A = 4'b1100; B = 4'b1010; sel = 4'b0110; // NAND
        check("NAND", 4'b0111, 0, 0, 0, 0);

        A = 4'b1100; B = 4'b1010; sel = 4'b0111; // XNOR
        check("XNOR", 4'b1001, 0, 0, 1, 0);

        // ---------------- NOT ----------------
        A = 4'b1010; sel = 4'b1000;
        check("NOT", 4'b0101, 0, 0, 0, 0);

        // ---------------- Shifts ----------------
        A = 4'b1011; sel = 4'b1001; // SHL: 1011 -> 0110, cout = shifted-out MSB
        check("SHL", 4'b0110, 1, 0, 0, 0);

        A = 4'b1000; sel = 4'b1001; // SHL: 1000 -> 0000, cout=1, zero=1
        check("SHL", 4'b0000, 1, 1, 0, 0);

        A = 4'b1011; sel = 4'b1010; // SHR: 1011 -> 0101, cout = shifted-out LSB
        check("SHR", 4'b0101, 1, 0, 0, 0);

        // ---------------- Rotates ----------------
        A = 4'b1011; sel = 4'b1011; // ROL: 1011 -> 0111
        check("ROL", 4'b0111, 0, 0, 0, 0);

        A = 4'b1011; sel = 4'b1100; // ROR: 1011 -> 1101
        check("ROR", 4'b1101, 0, 0, 1, 0);

        // ---------------- INC / DEC ----------------
        A = 4'b0110; sel = 4'b1101; // INC: 6 -> 7
        check("INC", 4'b0111, 0, 0, 0, 0);

        A = 4'b0110; sel = 4'b1110; // DEC: 6 -> 5
        check("DEC", 4'b0101, 0, 0, 0, 0);

        // ---------------- PASS ----------------
        A = 4'b1001; sel = 4'b1111; // PASS A
        check("PASS", 4'b1001, 0, 0, 1, 0);

        // ---------------- Summary ----------------
        $display("=================================================");
        $display(" Total: %0d   Passed: %0d   Failed: %0d",
                   pass_count + fail_count, pass_count, fail_count);
        if (fail_count == 0)
            $display(" RESULT: ALL TESTS PASSED");
        else
            $display(" RESULT: %0d TEST(S) FAILED", fail_count);
        $display("=================================================");

        $finish;
    end

    
    initial begin
        $dumpfile("alu_4bit_tb.vcd");
        $dumpvars(0, alu_4bit_tb);
    end

endmodule
