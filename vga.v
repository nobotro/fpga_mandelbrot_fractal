`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/27/2020 01:43:06 PM
// Design Name: 
// Module Name: vga
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module vga(
    input clk,
    input start,
    input zoom,
    output reg zoom_ack2,
    output[1:0] need_pixel,
    output[10:0] horcd,
    output[10:0] vertcd,
    output [4:0] vga_r,
    output [5:0] vga_g,
    output [4:0] vga_b,
    output wire vsync,//vga vsync output
    output wire hsync,///vga hsync output
    input [1279:0] storage,
    input [10:0] store_coun
   
 );
 
 
 reg[1:0] need_pixel_reg=0;
   
 reg[10:0] vertc=0;
 reg[10:0] horc=0;
 
 assign horcd=horc; 
 assign vertcd=vertc; 
 
 reg start2_flag=0;
 reg[15:0] pixel=16'b0;
 reg[6:0] rd_pixel_index=79;
 reg prev_zoom=0;
 always @(posedge clk) begin
 if(zoom)
 begin
 prev_zoom<=1;
  zoom_ack2<=1;
 rd_pixel_index<=79;
  need_pixel_reg<=0;
 horc<=0;
 horc<=0;
 end
 else begin zoom_ack2<=0;
 
 if(start)begin
start2_flag<=1;
need_pixel_reg<=0;

 if(horc<1024 && vertc<768 && prev_zoom==0)begin
        pixel<=storage[(rd_pixel_index*16)+:16];
        rd_pixel_index<=rd_pixel_index-1;
        
        if(rd_pixel_index==0)//marjvena 5 data fragmenti damtavrda
           begin
                
                need_pixel_reg<=2;
                rd_pixel_index<=79;
            end
       
          if(rd_pixel_index==40)//marcxena 5 data fragmenti dasrulda
           begin
                
                need_pixel_reg<=1;
             end
         end
         end
 	
	end
	
   if(start2_flag)begin
 
       
      //clock counter for vertical and horizontal sync
		if (horc<1343) begin
			 horc<=horc+1;
		 
			end
		else begin
		     
			  horc<=0;		  
			  if(vertc<805) begin
					vertc<=vertc+1;
				  end
			  else begin
					vertc<=0;
					if(start)prev_zoom<=0;
				    end   	
			 end
		
  
	end
end 
 
assign vsync = vertc> (768+3) && vertc <= (768+3+6);

assign hsync = horc > (1024 + 24) && horc <= (1024 + 24+ 136);


assign vga_b=(horc<1024 && vertc<768)?pixel[4:0]:5'b00000;
assign vga_g=(horc<1024 && vertc<768)?pixel[10:5]:6'b000000;
assign vga_r=(horc<1024 && vertc<768)?pixel[15:11]:5'b00000;
assign need_pixel= need_pixel_reg;

endmodule