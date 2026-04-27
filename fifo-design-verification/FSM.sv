module FSM (CLOCK, RESET_N, CLEAR_N, READ, WRITE, USE_DW, F_FULL_N, F_EMPTY_N, ena_cw, ena_cr, ena_udw, updn_udw, sel, wr_ram, rd_ram);

	parameter DEPTH = 32;
	parameter WIDTH = 8;

	input CLOCK, RESET_N, CLEAR_N, READ, WRITE;
	input [$clog2(DEPTH):0] USE_DW;

	output logic F_EMPTY_N, F_FULL_N, ena_cw, ena_cr, ena_udw, updn_udw, wr_ram, rd_ram, sel;
	
	enum {vacio, otros, lleno} state, next_state;
	
	always_ff @(posedge CLOCK or negedge RESET_N)
	if (!RESET_N)
			state <= vacio;
	else if (!CLEAR_N)
			state <= vacio;	
	else 
		state <= next_state;
	
	always_comb
		case(state)
			vacio:
				next_state = (!WRITE) ? vacio : ((READ) ? vacio : otros); 
			otros:
				next_state = (CLEAR_N) ? ((WRITE) ? ((READ) ? otros : ((USE_DW==31) ? lleno : otros)) : ((READ) ? ((USE_DW==1) ? vacio : otros) : otros)) : vacio;
			lleno: 
				next_state = (CLEAR_N) ? ((WRITE) ? lleno : ((READ) ? otros : lleno)) : vacio;
			default: next_state = vacio;
		endcase
		
	always_comb
		case(state)
			vacio: 
				begin
					begin
						F_EMPTY_N = 1'b0;
						F_FULL_N = 1'b1;
						sel = 1'b0;
						ena_cw = 1'b0;
						updn_udw = 1'b1;
						ena_udw = 1'b0;
						wr_ram = 1'b0;
						rd_ram = 1'b0;
						ena_cr = 1'b0;
					end
					if (WRITE==1'b1)
						if (READ==1'b1)
							begin
							F_EMPTY_N = 1'b0;
							F_FULL_N = 1'b1;
							sel = 1'b1;
							ena_cw = 1'b0;
							updn_udw = 1'b1;
							ena_udw = 1'b0;
							wr_ram = 1'b0;
							rd_ram = 1'b0;
							ena_cr = 1'b0;
							end

						else if (READ==1'b0)
							begin
							F_EMPTY_N = 1'b0;
							F_FULL_N = 1'b1;
							sel = 1'b0;
							ena_cw = 1'b1;
							updn_udw = 1'b1;
							ena_udw = 1'b1;
							wr_ram = 1'b1;
							rd_ram = 1'b0;
							ena_cr = 1'b0;
							end
				end
						
			otros:
				begin
					begin
						F_EMPTY_N = 1;
						F_FULL_N = 1;
						sel = 1'b0;
						ena_cr = 1'b0;
						ena_cw = 1'b0;
						ena_udw = 1'b0;
						updn_udw = 1'b0;
						wr_ram = 1'b0;
						rd_ram = 1'b0;
					end	
					if ((WRITE==1'b1)&&(READ==1'b1))
								begin
									F_EMPTY_N = 1;
									F_FULL_N = 1;
									sel = 1'b0;
									ena_cr = 1'b1;
									ena_cw = 1'b1;
									ena_udw = 1'b0;
									updn_udw = 1'b1;
									wr_ram = 1'b1;
									rd_ram = 1'b1;
								end
					else if ((WRITE==1'b1)&&(READ==1'b0))
								begin
									F_EMPTY_N = 1;
									F_FULL_N = 1;
									sel = 1'b0;
									ena_cr = 1'b0;
									ena_cw = 1'b1;
									ena_udw = 1'b1;
									updn_udw = 1'b1;
									wr_ram = 1'b1;
									rd_ram = 1'b0;
								end
					else if ((WRITE==1'b0)&&(READ==1'b1))
								begin
									F_EMPTY_N = 1;
									F_FULL_N = 1;
									sel = 1'b0;
									ena_cr = 1'b1;
									ena_cw = 1'b0;
									ena_udw = 1'b1;
									updn_udw = 1'b0;
									wr_ram = 1'b0;
									rd_ram = 1'b1;
								end
				end
			lleno:
				begin
					begin
						F_EMPTY_N = 1'b1;
						F_FULL_N = 1'b0;
						sel = 1'b0;
						updn_udw = 1'b0;
						ena_cr = 1'b0;
						ena_cw = 1'b0;
						ena_udw = 1'b0;
						rd_ram = 1'b0;
						wr_ram = 1'b0;
					end
						if ((WRITE==1'b1)&&(READ==1'b1))
								begin
									F_EMPTY_N = 1'b1;
									F_FULL_N = 1'b0;
									sel = 1'b0;
									ena_cr = 1'b1;
									ena_cw = 1'b1;
									ena_udw = 1'b0;
									updn_udw = 1'b0;
									rd_ram = 1'b1;
									wr_ram = 1'b1;
								end
						else if ((WRITE==1'b0)&&(READ==1'b1))
								begin
									F_EMPTY_N = 1'b1;
									F_FULL_N = 1'b0;
									sel = 1'b0;
									ena_cr = 1'b1;
									ena_cw = 1'b0;
									ena_udw = 1'b1;
									updn_udw = 1'b0;
									rd_ram = 1'b1;
									wr_ram = 1'b0;
								end
				end
		endcase
endmodule

	