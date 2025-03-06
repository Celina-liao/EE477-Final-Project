/**
* Conway's Game of Life Cell
*
* data_i[7:0] is status of 8 neighbor cells
* data_o is status this cell
* 1: alive, 0: death
*
* when en_i==1:
*   simulate the cell transition with 8 given neighors
* else when update_i==1:
*   update the cell status to update_val_i
* else:
*   cell status remains unchanged
**/

module bsg_cgol_cell (
     input clk_i

    ,input en_i          
    ,input [7:0] data_i

    ,input update_i     
    ,input update_val_i

    ,output logic data_o
  );

  // TODO: Design your bsg_cgl_cell
  // Hint: Find the module to count the number of neighbors from basejump
  logic [3:0] neighbors_alive;
  logic cell_r, cell_n;
  // TODO: Add basejump module

  bsg_popcount #(.width_p(8)) 
               count1s   (.i(data_i)
                         ,.o(neighbors_alive));
  always_comb 
  begin
    case (cell_r)
      1'b1: 
      begin
        if (neighbors_alive < 2)
	  cell_n = 0;
	else if ((neighbors_alive == 2) | (neighbors_alive == 3)) //1 < neighbors_alive < 4
	  cell_n = 1;
	else 
	  cell_n = 0;
      end
      1'b0: 
      begin
        if (neighbors_alive == 3)
	  cell_n = 1;
	else 
	  cell_n = 0;
      end
      default: cell_n = cell_r;
    endcase
  end

  always_ff @(posedge clk_i)
    if (en_i)  
      cell_r <= cell_n;
    else if (update_i)
      cell_r <= update_val_i;

  assign data_o = cell_r;

endmodule
