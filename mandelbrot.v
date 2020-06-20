`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/24/2020 11:33:41 PM
// Design Name: 
// Module Name: mandelbrot
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


module mandelbrot(
    input clk,
    input zoom,
      input ram_init_done,
      input ack,
    input is_writing,
    output wire[27:0] where_write,
    output reg do_write=0,
    output wire [127:0] data_to_write,
    output reg last_write_done=0,
    output reg zoom_ack=0
    
    );
   
function signed  [63:0] mm (input signed [63:0] a ,input signed [63:0] b);
begin
  mm = (a*b)>>>24;
end
endfunction

function signed  [63:0] f (input signed [63:0] a );
begin
  f=a*(1<<<24);
end
endfunction

function  signed [63:0] i (input signed [63:0] a);
begin
  i=(a+(1<<<23))>>>24;
end
endfunction
  
parameter  MAX_ITER = 500, HEIGHT=768 , WIDTH = 1024;
 
reg  signed [63:0] xb=-64'd33554432 , xl=16777216 , yb=-64'd16777216 , yl=16777216 , xs=49152 , ys=43690;
reg signed  [63:0]xn=0, yn=0,x0=0,y0=0;

  
reg signed [10:0] n_reg=-11'd1;
reg[10:0] x =11'd0;
reg[10:0] y =11'd0;
  
 
 
 reg[9:0] wr_pixel_counter=10'b0;
 reg signed [27:0] writeaddr=-8;
 
 reg [127:0] data_to_write_reg=128'b0;
 assign data_to_write=data_to_write_reg;
 assign where_write=writeaddr;
 


  reg  [0:15] colors [15:0];
  initial begin
   colors[0]=16'h445F;
   colors[1]=16'h47F8;
   colors[2]=16'hFF08;
   colors[3]=16'h329F;
   colors[4]=16'hA19B;
   colors[5]=16'hCEC6;
   colors[6]=16'hDC06;
   colors[7]=16'hD6C6;
   colors[8]=16'h34F1;
   colors[9]=16'h79DB;
   colors[10]=16'h3ED3;
   colors[11]=16'hDCC7;
   colors[12]=16'h8EC7;
   colors[13]=16'h3B7B;
   colors[14]=16'hAE6B;
   colors[15]=16'hA2D9;







  end
  
  
 
reg framedone=0;
 reg shed=1;
 
 reg last_write=0;
 reg[5:0] zc=0;
 always @(posedge clk)begin
 
 
 if(zoom)begin
 

 zoom_ack<=1;
 framedone<=0;
  shed<=1;
  last_write<=0;
  wr_pixel_counter<=0;
  writeaddr<=-8;
  if(zoom_ack==0)begin
    
     if(zc<5)zc<=zc+1;
 else zc<=0;
  case(zc)
  
  0:begin
  
  
      xb<=-64'd21593736;
      xl<=-64'd3180462;
      yb<=-64'd4320182;
      yl<=64'd4084079;
      xs<=64'd17981;
       ys<=64'd10942;
   end
  
  1:begin
  
        xb<=-64'd15460749;
        xl<=-64'd11966878;
        yb<=-64'd3699510;
        yl<=-64'd2104824;
        xs<=64'd3411;
        ys<=64'd2076;
  end
  
  2:begin
  
        xb<=-64'd14906092;
        xl<=-64'd13225814;
        yb<=-64'd4320821;
        yl<=-64'd3553902;
        xs<=64'd1640;
        ys<=64'd998;
  end
  3:begin
  
          xb<=-64'd12611579;
        xl<=-64'd12601181;
        yb<=64'd510686;
        yl<=64'd515432;
        xs<=64'd10;
        ys<=64'd6;
         

  end
  
  4:begin
  
        xb<=-64'd14485636;
        xl<=-64'd14393974;
        yb<=-64'd3987444;
        yl<=-64'd3945607;
        xs<=64'd89;
        ys<=64'd54;
  
  end
  
  5:begin
  
        xb<=-64'd13665344;
        xl<=-64'd11985067;
        yb<=64'd2579363;
        yl<=64'd3346282;
        xs<=64'd1640;
        ys<=64'd998;

  
  
  end
  default:begin
  
      xb<=-64'd33554432;
      xl<=16777216;
      yb<=-64'd16777216; 
      yl<=16777216;
      xs<=49152;
      ys<=43690;
  end
  
endcase
end
    xn<=0;
    yn<=0;
    x0<=0;
    y0<=0;
    n_reg<=-11'd1;
    x<=11'd0;
    y<=11'd0;

    do_write<=0;
    last_write_done<=0;
 
 
 end else begin
 zoom_ack<=0;
 if (is_writing==0 && last_write && ack)begin
     do_write<=0;
     last_write_done<=1;
 
 end
if(ack)  shed<=1;
 
if(is_writing==0 && framedone!=1 && ram_init_done && shed )begin
  do_write<=0;
  


if(n_reg==-1)begin
 x0<=xb+x*xs;
 y0<=yb+y*ys;
 
 xn<=xb+x*xs;
 yn<=yb+y*ys;
 n_reg<=n_reg+1;
  end
else begin

    if(wr_pixel_counter==8)begin
                 wr_pixel_counter<=0;
                 do_write<=1;
                 shed<=0;
                   writeaddr<=writeaddr+8;
                  
                 
                    
     end
     
     else if(mm(yn,yn)+mm(xn,xn)<f(4) && n_reg<MAX_ITER)begin
    
         yn<=2*mm(yn,xn) +y0;
         xn<=mm(xn,xn)- mm(yn,yn) + x0;
         n_reg<=n_reg+1;
         
      end
      
       
      else begin  
      
       
                wr_pixel_counter=wr_pixel_counter+1;
                                
                if(n_reg==500)begin
                
                    data_to_write_reg<={data_to_write_reg,16'b0}; 
                  end
                else data_to_write_reg<={data_to_write_reg,colors[n_reg-((n_reg>>4)*16)]}; 
              
                   n_reg<=-1;
                  if(x<=1022)begin
                        x<=x+1;
                        
                  end 
                  else begin
                        x<=0;
                        if(y <=766)begin
                             y<=y +1; 
                         
                          end                     
                          else begin
                               y<=0; 
                                framedone<=1; 
                               do_write<=1;
                                last_write<=1;
                               writeaddr<=writeaddr+8;
                 
                                
                                 
                          end
             
             end 
             
          
        
        end
    
    end

end
end


end

wire signed[10:0] n_reg_d=n_reg;

wire [9:0] wr_pixel_counter_d=wr_pixel_counter;


 
endmodule