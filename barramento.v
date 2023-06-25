module barramento(
	 input clk,
	 input reset,
	 input [127:0]data_in,
	 input	valid_in,
	 output	reg valid_out,
	 output reg [127:0]data_out
	);
	
	 reg start_pck;
	 reg end_pck;
	 reg[39:0]HDR_var;
	 reg[23:0]CRC_var;
	 reg[31:0]PLD_low_var;
	 reg[127:0]PLD_mid_var;
	 reg 	PLD_high_var;
	 reg[3:0]counter_v;
	 reg flag;
	 reg[127:0]data_out_wire;


//machine one
	parameter [2:0]START = 3'b000;		//0
	parameter [2:0]HDR = 3'b001	;		//1	
	parameter [2:0]PLD_low = 3'b010;		//2
	parameter [2:0]PLD_mid = 3'b011;		//3
	parameter [2:0]PLD_high = 3'b100;		//4
	parameter [2:0]CRC = 3'b101	;		//5
	parameter [2:0]END = 3'b110	;		//6

//machine 2

	parameter [2:0]HDR_2 = 3'b000	;		//0	
	parameter [2:0]PLD_1 = 3'b001	;		//1
	parameter [2:0]PLD_2 = 3'b010	;		//2
	parameter [2:0]CRC_2 = 3'b011	;		//3
	parameter [2:0]END_2 = 3'b100	;		//4

	

	reg [2:0]state1;
	reg [2:0]next_state1;
	reg [2:0]next_state2;
	reg [2:0]state2;

/*

	COMBINATIONAL PART MACHINE ONE

*/





	always @ (*)
	
		begin
		//next_state1=state1;
			case(state1)
				START:if( start_pck  && valid_in  )
				begin
					next_state1 = HDR;
	
				end else 
				begin
					next_state1 = START;
				end



				HDR:if(valid_in  )
				begin
					next_state1 = PLD_low;
				end else 
				begin
					next_state1 = HDR;
				end



				PLD_low :if( valid_in  )
				begin
					next_state1 = PLD_mid;
				end else
				begin
					next_state1 = PLD_low;
				end



				PLD_mid:if( valid_in  )
				begin
					next_state1 = PLD_high;
					flag = 1;
				end else 
				begin
					next_state1 = PLD_mid;
				end



				PLD_high :if(valid_in )
				begin
					next_state1 = CRC;
					flag = 1;
				end else 
				begin
					next_state1 = PLD_high;
				end



				CRC:if(valid_in  )
				begin
					next_state1 = END;
					flag = 1;
				end	else 
				begin
					next_state1 = CRC;

				end



				END:if(end_pck)
				begin 
					next_state1 = START;
				end else 
				begin
					next_state1 = END;

				end



				default:begin
					 next_state1 = START;
					flag = 0;
					end
			endcase
		
		
	end

/*

		SEQUENTIAL PART MACHINE 1	

*/
/*logica de mudanca de estados*/

always @ ( posedge clk or posedge reset) begin 
    if ( reset ) begin
	
      state1 <= START;
    end else begin
      
        state1 <= next_state1;
      
    end
  end

always @ (*)
	begin
	counter_v = 0;
	start_pck =((state1== START)| (state1== HDR)) ? 1 : 0;
	HDR_var = (state1== HDR)?  data_in[39:0] : 0;
	PLD_low_var = (state1== PLD_low ) ?  data_in[127:96] : 0;
	PLD_mid_var = (state1== PLD_mid ) ? 	data_in[127:0] : 0;
	PLD_high_var = (state1== PLD_high ) ? 	data_in : 0;
	CRC_var = (state1==CRC) ? 	data_in[23:0] : 0;
	end_pck = (state1 ==END) ? 1: 0;
	
	end

/*
			COMBINATIONAL PART MACHINE 2

*/


always @ (*)
	begin
	
		next_state2 = state2;

		case(state2)
			HDR_2:if( flag == 1 )
				begin 
					next_state2 = PLD_1;
				end else 
					begin
					next_state2 = HDR_2;
					end

			PLD_1:if(flag == 1)
				begin
					next_state2 = PLD_2;

				end else 
					begin
					next_state2 = PLD_1;
					end


			PLD_2:if( flag == 1)
				begin
					next_state2= CRC_2;

				end else 
					begin
					next_state2 = PLD_2;
					end


			CRC_2:if( flag == 1)
				begin
					next_state2= END_2;
				end else 
					begin
					next_state2= CRC_2;

					end


			END_2:if(valid_in!= 1 | flag != 1)
					begin
					next_state2= HDR_2;
					//counter_v=counter_v+1;
					end



		default: next_state2 = HDR_2;

		endcase
	end

/*logica de mudanca de estados*/

always @ ( posedge clk or posedge reset) begin 
    if ( reset ) begin
		data_out<=0;
      state2 <= HDR_2;
    end else if(flag ==1) begin
      
        state2 <= next_state2;
      
    end
  end


	/*

		SEQUENTIAL PART MACHINE 2

	*/


always @ (*)
	begin
	if(flag == 1)
		begin 
		data_out= data_out_wire;
		end

	data_out_wire= (state2== HDR_2)?HDR_var : 0;
	data_out_wire = (state2== PLD_1 ) ? {PLD_low_var[31:0], PLD_mid_var[95:0]}: 0;
	data_out_wire = (state2== PLD_2 ) ? 	{PLD_mid_var[127:96], PLD_high_var} : 0;
	data_out_wire = (state2==CRC_2) ? 	CRC_var: 0;
	valid_out = (state2 == END_2) ? 1 : 0;
end



endmodule

	
