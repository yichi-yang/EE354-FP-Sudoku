// ----------------------------------------------------------------------
// 	A Verilog module for a simple divider
//
// 	Written by Gandhi Puvvada  Date: 7/17/98, 2/15/2008, 10/13/08, 2/22/2010
//
//      File name:  divider_combined_cu_dpu_with_single_step.v
// ------------------------------------------------------------------------
// This file is essentially same as the divider_combined_cu_dpu.v except for 
// the SCEN additional input port pin which is used to single step the divider
// in the compute state.
// Note the following lines later in the code:
//  	        COMPUTE	:
//			  if (SCEN)  // Notice SCEN
//	           begin
// ------------------------------------------------------------------------
module SudokuSolver (Prev, Next, Enter, Start, Clk, Reset, InputValue,
                    Init, Load, Forword, ValRow, ValCol, ValBlk, Back, Disp, Fail,
                    Row, Col, OutputValue);

input Prev, Next, Enter, Start, CLk, Reset;
input [3:0] InputValue;
output Init, Load, Forword, ValRow, ValCol, ValBlk, Back, Disp, Fail;
output [3:0] Row, Col;
output [3:0] OutputValue;

reg [10:0] state;
reg [3:0] Row, Col, rowNext, colNext, rowPrev, colPrev;
reg [8:0] inputOneHot;

reg [8:0] sudoku [8:0][8:0];
reg fixed [8:0][8:0];
reg [8:0] attempt;

localparam
INIT    = 9'b000000001,
LOAD    = 9'b000000010,
FORWORD = 9'b000000100,
VAL_ROW = 9'b000001000,
VAL_COL = 9'b000010000,
VAL_BLK = 9'b000100000,
BACK    = 9'b001000000,
DISP    = 9'b010000000,
FAIL    = 9'b100000000;

assign {Fail, Disp, Back, ValBlk, ValCol, ValRow, Forword, Load, Init} = state;
assign OutputValue = sudoku[Row][Col];

always @(Row, Col)
    begin
        if(Col == 8)
            begin
                colNext <= 0;
                if(Row != 8)
                    rowNext <= Row + 1;
            end
        else
            begin
                colNext <= Col + 1;
            end
        if(Col == 0)
            begin
                colPrev <= 8;
                if(Row != 0)
                    rowPrev <= Row - 1;
            end
        else
            begin
                colPrev <= Col - 1;
            end
    end

always @ (InputValue) 
	begin : HEX_TO_SSD
		case (InputValue) 
			4'b0001: inputOneHot = 9'b000000001; // 1
			4'b0010: inputOneHot = 9'b000000010; // 2
			4'b0011: inputOneHot = 9'b000000100; // 3
			4'b0100: inputOneHot = 9'b000001000; // 4
			4'b0101: inputOneHot = 9'b000010000; // 5
			4'b0110: inputOneHot = 9'b000100000; // 6
			4'b0111: inputOneHot = 9'b001000000; // 7
			4'b1000: inputOneHot = 9'b010000000; // 8
			4'b1001: inputOneHot = 9'b100000000; // 9  
			default: inputOneHot = 9'b000000000; // default to 9'b0
		endcase
	end	

always @(posedge Clk, posedge Reset) 

  begin  : CU_n_DU
    if (Reset)
        begin
            state <= INITIAL;
	        X <= 4'bXXXX;        // to avoid recirculating mux controlled by Reset
	        Y <= 4'bXXXX;	   // to avoid recirculating mux controlled by Reset 
	        Quotient <= 4'bXXXX; // to avoid recirculating mux controlled by Reset
       end
    else
        begin
            (* full_case, parallel_case *)
            case (state)
                LOAD:
                    begin
                        // state transition
                        if(Start)
                            state <= NEXT;
                        // DPU
                        if(Next)
                            begin
                                Row <= rowNext;
                                Col <= colNext;
                            end
                        if(Prev)
                            begin
                                Row <= rowPrev;
                                Col <= colPrev;
                            end
                        if(Enter)
                            begin
                                sudoku[Row][Col] <= inputOneHot;
                                fixed[Row][Col] <= (InputValue == 4'b0);
                            end
                        if(Start)
                            begin
                                Row <= 0;
                                Col <= 0;
                            end
                    end
        endcase
    end 
  end

endmodule  // SudokuSolver