module bsg_cgol_ctrl #(
   parameter `BSG_INV_PARAM(max_game_length_p)
  ,localparam game_len_width_lp=`BSG_SAFE_CLOG2(max_game_length_p+1)
) (
   input clk_i
  ,input reset_i

  ,input en_i

  // Input Data Channel
  ,input  [game_len_width_lp-1:0] frames_i
  ,input  v_i
  ,output ready_o

  // Output Data Channel
  ,input yumi_i
  ,output v_o

  // Cell Array
  ,output update_o
  ,output en_o
);

  wire unused = en_i; // for clock gating, unused
  
  // TODO: Design your control logic
  logic [game_len_width_lp-1:0] frameCount;
  logic init_load, countEnd;
  typedef enum [1:0] {eWAIT, eBUSY, eDONE} state_e;
  state_e substate_r, substate_n;

  always_ff @(posedge clk_i)
  begin
    if (reset_i)
    begin
      substate_r <= eWAIT;
      frameCount <= 0; 
    end
    else //if (en_i)
    begin
      substate_r <= substate_n;
      frameCount <= init_load? frames_i : countEnd? 0: (frameCount - 1);
    end
  end

  always_comb 
  begin
    unique case (substate_r)
  	eWAIT:     substate_n = (v_i)? eBUSY:eWAIT;
  	eBUSY:     substate_n = (countEnd)? eDONE:eBUSY;
	eDONE:	   substate_n = (yumi_i)? eWAIT:eDONE;
       default:    substate_n = substate_r; 
    endcase
  end

  assign ready_o = (substate_r == eWAIT);
  assign v_o = (substate_r==eDONE);

  assign init_load = (substate_r == eWAIT) & v_i;
  assign countEnd = (frameCount == 0);
  assign update_o = (v_i) & (substate_r == eWAIT);
  assign en_o = !countEnd & (substate_r == eBUSY);
  
endmodule
