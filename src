module alu_4bit (
    input  wire [3:0] A,        
    input  wire [3:0] B,        
    input  wire [3:0] sel,      
    input  wire       cin,      
    output reg  [3:0] result,   
    output reg        cout,     
    output reg        overflow, 
    output wire        zero,    
    output wire        negative  
);

    localparam ADD  = 4'b0000;
    localparam SUB  = 4'b0001;
    localparam AND  = 4'b0010;
    localparam OR   = 4'b0011;
    localparam XOR  = 4'b0100;
    localparam NOR  = 4'b0101;
    localparam NAND = 4'b0110;
    localparam XNOR = 4'b0111;
    localparam NOT  = 4'b1000;
    localparam SHL  = 4'b1001;
    localparam SHR  = 4'b1010;
    localparam ROL  = 4'b1011;
    localparam ROR  = 4'b1100;
    localparam INC  = 4'b1101;
    localparam DEC  = 4'b1110;
    localparam PASS = 4'b1111;

    always @(*) begin
        result   = 4'b0000;
        cout     = 1'b0;
        overflow = 1'b0;

        case (sel)       
            ADD: begin
               //concatenation
              {cout, result} = A + B + cin;
                overflow = (A[3] == B[3]) && (result[3] != A[3]);
            end
          

            SUB: begin
                {cout, result} = A - B;
                overflow = (A[3] != B[3]) && (result[3] != A[3]);
            end

            AND:  result = A & B;
          
            OR:   result = A | B;
          
            XOR:  result = A ^ B;
          
            NOR:  result = ~(A | B);
          
            NAND: result = ~(A & B);
          
            XNOR: result = ~(A ^ B);
          
            NOT:  result = ~A;

            SHL: begin
              cout = A[3];
              result = {A[2:0], 1'b0}; 
            end

            SHR: begin
                result = {1'b0, A[3:1]};
                cout   = A[0];              
            end

            ROL: result = {A[2:0], A[3]};
          
            ROR: result = {A[0], A[3:1]};

            INC: begin
                {cout, result} = A + 4'b0001;
                overflow = (A[3] == 1'b0) && (result[3] == 1'b1);
            end

            DEC: begin
                {cout, result} = A - 4'b0001;
                overflow = (A[3] == 1'b1) && (result[3] == 1'b0);
            end

            PASS: result = A;

            default: result = 4'b0000;
          
        endcase
    end

    assign zero     = (result == 4'b0000);
    assign negative = result[3];

endmodule
