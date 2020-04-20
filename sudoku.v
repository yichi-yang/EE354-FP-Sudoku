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
module SudokuSolver (Prev, Next, Enter, Start, Clk, InputValue,
                    Init, Load, Next, ValRow, ValCol, ValBlk, Back, Disp, Fail,
                    Row, Col, OutputValue);

input Prev, Next, Enter, Start, CLk;
input [3:0] InputValue;
output Init, Load, Next, ValRow, ValCol, ValBlk, Back, Disp, Fail;
output [3:0] Row, Col;
output [3:0] OutputValue;

reg [10:0] state;

localparam
INIT    = 9'b000000001,
LOAD    = 9'b000000010,
NEXT    = 9'b000000100,
VAL_ROW = 9'b000001000,
VAL_COL = 9'b000010000,
VAL_BLK = 9'b000100000,
BACK    = 9'b001000000,
DISP    = 9'b010000000,
FAIL    = 9'b100000000;

assign {Fail, Disp, Back, ValBlk, ValCol, ValRow, Next, Load, Init} = state;

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
	        INITIAL	: 
	          begin
			  	 int i, j;
		         // state transitions in the control unit
		         state <= LOAD;
		         // RTL operations in the Data Path 
		           for (int i = 0; i <= 8; i <= i + 1)
					begin 
						for (int j = 0; j <= 8; j <= j + 1)
							begin
								sudoku[i][j] <= 0;
								fixed[i][j] <= 0;
								col <= 0;
								row <= 0;
							end
					end
	          end
	        COMPUTE	:
			  if (SCEN)  // Notice SCEN
	          begin
		         // state transitions in the control unit
		         if (X < Y)
		           state <= DONE_S;
		         // RTL operations in the Data Path 
		         if (!(X < Y))
		           begin
		             X <= X - Y;
		             Quotient <= Quotient + 1;
		           end
 	          end
	        DONE_S	:
	          begin  
		         // state transitions in the control unit
		         if (Ack)
		           state <= INITIAL;
		         // RTL operations in the Data Path 
		         // In DONE_S state, there are no RTL operations in the Data Path 
	          end    
      endcase
    end 
  end

endmodule  // SudokuSolver