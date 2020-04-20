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

reg [8:0] sudoku [8:0][8:0];
reg fixed [8:0][8:0];

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

always @(posedge Clk, posedge Reset) 

  begin  : CU_n_DU
    if (Reset)
       begin
          state <= INIT;
	      X <= 4'bXXXX;        // to avoid recirculating mux controlled by Reset
	      Y <= 4'bXXXX;	   // to avoid recirculating mux controlled by Reset 
	      Quotient <= 4'bXXXX; // to avoid recirculating mux controlled by Reset
       end
    else
       begin
         (* full_case, parallel_case *)
         case (state)
	        INIT	: 
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
	        DISP	:
	          begin  
		         if (Next)
				 	begin
					 	row <= rowNext;
						col <= colNext;
					end
				 if (Prev)
				 	begin 
					 	row <= rowPrev;
						col <= colProv;
					end
	          end    
      endcase
    end 
  end

endmodule  // SudokuSolver