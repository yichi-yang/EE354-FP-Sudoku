// ----------------------------------------------------------------------
//     A Verilog module for a simple divider
//
//     Written by Gandhi Puvvada  Date: 7/17/98, 2/15/2008, 10/13/08, 2/22/2010
//
//      File name:  divider_combined_cu_dpu_with_single_step.v
// ------------------------------------------------------------------------
// This file is essentially same as the divider_combined_cu_dpu.v except for 
// the SCEN additional input port pin which is used to single step the divider
// in the compute state.
// Note the following lines later in the code:
//              COMPUTE    :
//              if (SCEN)  // Notice SCEN
//               begin
// ------------------------------------------------------------------------
module SudokuSolver (Prev, Next, Enter, Start, Clk, Reset, InputValue,
                    Init, Load, Forward, Check, Back, Disp, Fail,
                    Row, Col, OutputValue, OutputAttempt, Single, OutputFixed);

input Prev, Next, Enter, Start, Clk, Reset, Single;
input [3:0] InputValue;
output Init, Load, Forward, Check, Back, Disp, Fail;
output [3:0] Row, Col;
output [3:0] OutputValue, OutputAttempt;
output OutputFixed;

reg [6:0] state;
reg [3:0] Row, Col, rowNext, colNext, rowPrev, colPrev;
reg [3:0] OutputValue, OutputAttempt;
reg [8:0] inputOneHot;

reg [8:0] sudoku [8:0][8:0];
reg fixed [8:0][8:0];
reg [8:0] attempt, nextAttempt;

localparam
INIT    = 7'b0000001,
LOAD    = 7'b0000010,
FORWARD = 7'b0000100,
CHECK   = 7'b0001000,
BACK    = 7'b0010000,
DISP    = 7'b0100000,
FAIL    = 7'b1000000;

assign {Fail, Disp, Back, Check, Forward, Load, Init} = state;
assign OutputFixed = fixed[Row][Col];

always @(Row, Col)
    begin
        if(Col == 8)
            begin
                colNext <= 0;
                if(Row == 8)
                    rowNext <= 0;
                else
                    rowNext <= Row + 1;
            end
        else
            begin
                colNext <= Col + 1;
                rowNext <= Row;
            end
        if(Col == 0)
            begin
                colPrev <= 8;
                if(Row == 0)
                    rowPrev <= 8;
                else
                    rowPrev <= Row - 1;
            end
        else
            begin
                colPrev <= Col - 1;
                rowPrev <= Row;
            end
    end

always @ (InputValue) 
    begin : INPUT_TO_ONE_HOT
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

always @ (*)
    begin
        case (sudoku[Row][Col]) 
            9'b000000001: OutputValue = 4'b0001; // 1
            9'b000000010: OutputValue = 4'b0010; // 2
            9'b000000100: OutputValue = 4'b0011; // 3
            9'b000001000: OutputValue = 4'b0100; // 4
            9'b000010000: OutputValue = 4'b0101; // 5
            9'b000100000: OutputValue = 4'b0110; // 6
            9'b001000000: OutputValue = 4'b0111; // 7
            9'b010000000: OutputValue = 4'b1000; // 8
            9'b100000000: OutputValue = 4'b1001; // 9  
            default:      OutputValue = 4'b0000; // default to 4'b0
        endcase
    end

always @ (attempt)
    begin
        case (attempt) 
            9'b000000001: OutputAttempt = 4'b0001; // 1
            9'b000000010: OutputAttempt = 4'b0010; // 2
            9'b000000100: OutputAttempt = 4'b0011; // 3
            9'b000001000: OutputAttempt = 4'b0100; // 4
            9'b000010000: OutputAttempt = 4'b0101; // 5
            9'b000100000: OutputAttempt = 4'b0110; // 6
            9'b001000000: OutputAttempt = 4'b0111; // 7
            9'b010000000: OutputAttempt = 4'b1000; // 8
            9'b100000000: OutputAttempt = 4'b1001; // 9  
            default:      OutputAttempt = 4'b0000; // default to 4'b0
        endcase
    end

always @ (attempt) 
    begin : ONE_HOT_INCREMENTER
        case (attempt) 
            9'b000000001: nextAttempt = 9'b000000010; // 1 + 1 = 2
            9'b000000010: nextAttempt = 9'b000000100; // 2 + 1 = 3
            9'b000000100: nextAttempt = 9'b000001000; // 3 + 1 = 4
            9'b000001000: nextAttempt = 9'b000010000; // 4 + 1 = 5
            9'b000010000: nextAttempt = 9'b000100000; // 5 + 1 = 6
            9'b000100000: nextAttempt = 9'b001000000; // 6 + 1 = 7
            9'b001000000: nextAttempt = 9'b010000000; // 7 + 1 = 8
            9'b010000000: nextAttempt = 9'b100000000; // 8 + 1 = 9
            default:      nextAttempt = 9'bxxxxxxxxx;
        endcase
    end

always @(posedge Clk, posedge Reset) 

  begin  : CU_n_DU
    if (Reset)
       begin : RESET_STATE_MACHINE
            reg [3:0] i, j;
            state <= INIT;
            Row <= 4'bxxxx;
            Col <= 4'bxxxx;
            rowNext <= 4'bxxxx;
            colNext <= 4'bxxxx;
            rowPrev <= 4'bxxxx;
            colPrev <= 4'bxxxx;
            OutputValue <= 4'bxxxx;
            OutputAttempt <= 4'bxxxx;
            inputOneHot <= 9'bxxxxxxxxx;
            attempt <= 9'bxxxxxxxxx;
            nextAttempt <= 9'bxxxxxxxxx;
            for (i = 0; i <= 8; i = i + 1)
                begin 
                    for (j = 0; j <= 8; j = j + 1)
                        begin
                            sudoku[i][j] <= 9'bxxxxxxxxx;
                            fixed[i][j] <= 1'bx;
                        end
                end
       end
    else
        begin
            (* full_case, parallel_case *)
            case (state)

                INIT: 
                    begin: INIT_STATE
                        reg [3:0] i, j;
                        // state transitions in the control unit
                        state <= LOAD;
                        // RTL operations in the Data Path 
                        Col <= 0;
                        Row <= 0;
                        for (i = 0; i <= 8; i = i + 1)
                            begin 
                                for (j = 0; j <= 8; j = j + 1)
                                    begin
                                        sudoku[i][j] <= 0;
                                        fixed[i][j] <= 0;
                                    end
                            end
                    end

                LOAD:
                    begin
                        // state transition
                        if(Start)
                            state <= FORWARD;
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
                                if(inputOneHot == 9'b0)
                                    fixed[Row][Col] <= 1'b0;
                                else
                                    fixed[Row][Col] <= 1'b1;
                            end
                        if(Start)
                            begin
                                Row <= 0;
                                Col <= 0;
                            end
                    end

                FORWARD:
                    begin
                        if(!Single || Enter)
                            begin
                                // state transition
                                if(fixed[Row][Col] == 1'b0 && fixed[Row][Col] == 1'b0)
                                    state <= CHECK;
                                if(fixed[Row][Col] == 1'b1 && Row == 8 && Col == 8)
                                    state <= DISP;
                                // DPU
                                if(fixed[Row][Col] == 1'b1)
                                    begin
                                        Row <= rowNext;
                                        Col <= colNext;
                                    end
                                else
                                    attempt <= 9'b000000001;
                                if(fixed[Row][Col] == 1'b1 && Row == 8 && Col == 8)
                                    begin
                                        Row <= 0;
                                        Col <= 0;
                                    end
                            end
                    end

                CHECK:
                    begin
                        if(!Single || Enter)
                            begin: VALIDATE_ATTEMPT
                                reg isValid;
                                reg [3:0] i, j;
                                reg [8:0] rowMask, colMask;
                                isValid = 1'b1;
                                for(i = 0; i < 9; i = i + 1)
                                    begin
                                        if(sudoku[Row][i] & attempt || sudoku[i][Col] & attempt)
                                            isValid = 1'b0;
                                    end

                                if(Row < 3)
                                    rowMask = 9'b000000111;
                                else if(Row < 6)
                                    rowMask = 9'b000111000;
                                else
                                    rowMask = 9'b111000000;

                                if(Col < 3)
                                    colMask = 9'b000000111;
                                else if(Col < 6)
                                    colMask = 9'b000111000;
                                else
                                    colMask = 9'b111000000;

                                for(i = 0; i < 9; i = i + 1)
                                    begin
                                        for(j = 0; j < 9; j = j + 1)
                                            begin
                                                if(rowMask[i] && colMask[j] && (sudoku[i][j] & attempt))
                                                    isValid = 1'b0;
                                            end
                                    end                                

                                // state transition
                                if(isValid)
                                    state <= FORWARD;
                                if(!isValid && attempt[8]) // last attempt
                                    begin
                                        if(Row == 0 && Col == 0) // cannot go back anymore
                                            state <= FAIL;
                                        else
                                            state <= BACK;
                                    end
                                // DPU
                                if(isValid)
                                    begin
                                        sudoku[Row][Col] <= attempt;
                                        Row <= rowNext;
                                        Col <= colNext;
                                    end
                                if(!isValid && attempt[8]) // prepare for back track
                                    begin
                                        Row <= rowPrev;
                                        Col <= colPrev;
                                        attempt <= sudoku[rowPrev][colPrev]; // load the value in previous location to increment
                                    end
                                if(!isValid && !attempt[8]) // try next number
                                    attempt <= nextAttempt;
                            end
                    end

                BACK:
                    begin
                        if(!Single || Enter) 
                            begin: BACKTRACK
                                reg usable;

                                // we can update a location if it is not fixed and its value is not 9
                                if(fixed[Row][Col] == 1'b0 && sudoku[Row][Col] != 9'b100000000)
                                    usable = 1'b1;
                                else
                                    usable = 1'b0;

                                // state transition
                                if(usable) // if not fixed and currently not at 9
                                    state <= CHECK;

                                // if at first location and it is fixed or it has value 9 then there are no soltion
                                if(Row == 0 && Col == 0 && !usable)
                                    state <= FAIL;

                                // DPU
                                sudoku[Row][Col] <= 9'b0;
                                if(usable)
                                    begin
                                        attempt <= nextAttempt; // increment the attempt value by one
                                    end
                                else // we need to backtrack further
                                    begin
                                        Row <= rowPrev;
                                        Col <= colPrev;
                                        attempt <= sudoku[rowPrev][colPrev]; // load the value in previous location to increment
                                    end
                            end
                    end

                DISP:
                    begin
                        // state transition
                        if(Start)
                            state <= INIT;
                        // DPU
                        if (Next)
                            begin
                                Row <= rowNext;
                                Col <= colNext;
                            end
                        if (Prev)
                            begin 
                                Row <= rowPrev;
                                Col <= colPrev;
                            end
                    end

                FAIL:
                    begin
                        // state transition
                        if(Start)
                            state <= INIT;
                    end
        endcase
    end 
  end

endmodule  // SudokuSolver