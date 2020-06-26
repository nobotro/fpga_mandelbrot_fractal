`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/15/2020 11:22:48 PM
// Design Name: 
// Module Name: mfraq
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:s
// 
//////////////////////////////////////////////////////////////////////////////////


module mfraq(
    input clk,
    output [4:0] vga_r,
    output [5:0] vga_g,
    output [4:0] vga_b,
    output wire vsync,//vga vsync output
    output wire hsync,///vga hsync output
    output reg [4:0] led,
      // Inouts
   inout [15:0]  ddr3_dq,
   inout [1:0]  ddr3_dqs_n,
   inout [1:0]  ddr3_dqs_p,

   // Outputs
   output [13:0] ddr3_addr,
   output [2:0]  ddr3_ba,
   output  ddr3_ras_n,
   output  ddr3_cas_n,
   output  ddr3_we_n,
   output  ddr3_reset_n,
   output [0:0]  ddr3_ck_p,
   output [0:0]  ddr3_ck_n,
   output [0:0]  ddr3_cke, 
   output [1:0] ddr3_dm,
   output [0:0] ddr3_odt,
   
   
   input  sys_rst

    );

wire clkout;//~65 mzh clock for vga 1024X768

///vars for memory controler

wire calib_done;

reg  [27:0] app_addr = 0;
reg  [2:0]  app_cmd = 0;
reg  app_en;
wire app_rdy;

reg [127:0]app_wdf_data=0;
wire app_wdf_end = 1;
reg  app_wdf_wren;
wire app_wdf_rdy;

wire [127:0]app_rd_data;
wire [15:0] app_wdf_mask = 0;
wire app_rd_data_end;
wire app_rd_data_valid;

wire app_sr_req = 0;
wire app_ref_req = 0;
wire app_zq_req = 0;
wire app_sr_active;
wire app_ref_ack;
wire app_zq_ack;

wire ui_clk;
wire ui_clk_sync_rst;

wire sys_clk_200m;

wire[15:0] pixel;
wire[15:0] mand_pixel;


 
reg [1279:0] data_storage=1280'b0; //5 pixel 


localparam IDLE = 3'd0;
localparam WRITE = 3'd1;
localparam WRITE_DONE = 3'd2;
localparam READ = 3'd3;
localparam READ_DONE = 3'd4;
localparam PARK = 3'd5;
reg [2:0] state = IDLE;

localparam CMD_WRITE = 3'b000;
localparam CMD_READ = 3'b001;

///////////////



reg[2:0] clkcounter= 3'b100;// 200mhz-s vyoft 3 ze,vga-s clk stvis


 
 
 reg    [27:0] readaddr=0;//ramshi wakitxvis misamarti

 
 wire[27:0] readaddr_deb=readaddr;



reg do_read=0;
wire do_write; 
reg is_writing=0;
wire is_writing_wire=is_writing;
integer counter=1;
wire[27:0] where_write;
wire [127:0] data_to_write;
 reg [15:0] pixel_reg=16'b0;
  assign pixel=pixel_reg;         
 assign clkout=clkcounter[0]; 

 reg alflag=0;
reg ram_init_done_reg=0;

wire ram_init_done=ram_init_done_reg;
 reg ack_reg=0;
wire ack=ack_reg;
  wire framedone;
   reg start_drawing=0;
  wire start=start_drawing;
 wire[1:0] need_pixel;

reg ack_vga_reg=0;
wire ack_vga=ack_vga_reg;
  clk_wiz_0 clkgen(.clk_in1(clk),
   .clk_out1(sys_clk_200m),
   .locked()
   );
reg zoom_reg=0;
wire zoom=zoom_reg;
wire zoom_ack; 

reg zoom_reg2=0;
wire zoom2=zoom_reg2;
wire zoom_ack2; 

   mandelbrot man(
   .clk(clk),
   .zoom(zoom),
   .ack(ack),
     .ram_init_done(ram_init_done),
   .is_writing(is_writing_wire),
   .where_write(where_write),
   .data_to_write(data_to_write),
   .do_write(do_write),
   .last_write_done(framedone),
   .zoom_ack(zoom_ack)
    
   );
   
 reg[10:0] store_coun=0;
wire[10:0] store_coun_wire=store_coun; 

 vga vgac(
 .clk(clkout),
 .zoom(zoom2),
 .zoom_ack2(zoom_ack2),
  .need_pixel(need_pixel),
 .storage(data_storage),
 .start(start),
 .vga_r(vga_r),
 .vga_g(vga_g),
 .vga_b(vga_b),
 .vsync(vsync),
 .hsync(hsync),
 .store_coun(store_coun_wire)
 
 
 );

ddr3contr ram (
   // DDR3 Physical interface ports
   .ddr3_addr   (ddr3_addr),
   .ddr3_ba     (ddr3_ba),
   .ddr3_cas_n  (ddr3_cas_n),
   .ddr3_ck_n   (ddr3_ck_n),
   .ddr3_ck_p   (ddr3_ck_p),
   .ddr3_cke    (ddr3_cke),
   .ddr3_ras_n  (ddr3_ras_n),
   .ddr3_reset_n(ddr3_reset_n),
   .ddr3_we_n   (ddr3_we_n),
   .ddr3_dq     (ddr3_dq),
   .ddr3_dqs_n  (ddr3_dqs_n),
   .ddr3_dqs_p  (ddr3_dqs_p),
   .ddr3_dm     (ddr3_dm),
   .ddr3_odt    (ddr3_odt),
   .init_calib_complete (calib_done),
   // User interface ports
   .app_addr    (app_addr),
   .app_cmd     (app_cmd),
   .app_en      (app_en),
   .app_wdf_data(app_wdf_data),
   .app_wdf_end (app_wdf_end),
   .app_wdf_wren(app_wdf_wren),
   .app_rd_data (app_rd_data),
   .app_rd_data_end (app_rd_data_end),
   .app_rd_data_valid (app_rd_data_valid),
   .app_rdy     (app_rdy),
   .app_wdf_rdy (app_wdf_rdy),
   .app_sr_req  (app_sr_req),
   .app_ref_req (app_ref_req),
   .app_zq_req  (app_zq_req),
   .app_sr_active(app_sr_active),
   .app_ref_ack (app_ref_ack),
   .app_zq_ack  (app_zq_ack),
   .ui_clk      (ui_clk),
   .ui_clk_sync_rst (ui_clk_sync_rst),
   .app_wdf_mask(app_wdf_mask),
   // Clock and Reset input ports
   .sys_clk_i (sys_clk_200m),
   .sys_rst(1'b1)
   );




//generate clock for vga  
always @(posedge sys_clk_200m)begin

clkcounter <={clkcounter[1:0],clkcounter[2]};

end
 reg  [10:0] read_count=0;
 
reg [10:0] index=9;

reg[12:0] cycle_counter=0;
reg[12:0] cycle_counter2=0;
reg[12:0] idle_counter=0;
reg[127:0] data=128'b0;
reg err=0;
//to write data set state=write,data_to_write=128 bit data,app_addr = adress multiple of 8
//to read data set satate=read,readed_data=app_rd_data,app_addr = adress multiple of 8
//set read or write state only when state is idle
always @ (posedge ui_clk) begin
 if (ui_clk_sync_rst  ) begin
    state <= IDLE;
    app_en <= 0;
    app_wdf_wren <= 0;
     
    
  end 
  else  if(counter==300)begin
  ack_reg<=0;
    read_count<=0;
    readaddr<=0;
      zoom_reg<=1;
      zoom_reg2<=1;
      counter<=1;
      state<=IDLE;
      is_writing<=0;
      cycle_counter2<=0;
      cycle_counter<=0;
      store_coun<=0;
      index<=9;
      err<=0;
      start_drawing<=0;
      alflag<=0;
    end
  
  else if(calib_done) begin
     ram_init_done_reg<=1;
     
     
     
      if(zoom_ack) zoom_reg<=0;
      if(zoom_ack2) zoom_reg2<=0;
      
    if(do_write && alflag==0)begin
 
      is_writing<=1;
      alflag<=1;
      ack_reg<=1;
  end
 else if (do_write==0)begin
 alflag<=0;
 ack_reg<=0;
 end
     
    case (state)
    
      WRITE: begin

        if (app_rdy & app_wdf_rdy) begin
          state <= WRITE_DONE;
          app_en <= 1;
          app_wdf_wren <= 1;
          app_addr <=where_write;
          app_cmd <= CMD_WRITE;
          app_wdf_data <= data_to_write; 
          
           
          
        end
        
        
     
      end

      WRITE_DONE: begin
        if (app_rdy & app_en) begin
          app_en <= 0;
        end

        if (app_wdf_rdy & app_wdf_wren) begin
          app_wdf_wren <= 0;
        end

        if (~app_en & ~app_wdf_wren) begin
          state <= IDLE;
          
         
        is_writing<=0;
        end
        
       
       end
         READ: begin
       
            app_en<=0;
            if( read_count<10 )begin
                    
                    
                    if(app_rdy )begin
                        
                        if((read_count==5 || read_count==0) && err==0  )begin
                               err<=1;
                                app_en<=1;
                               app_cmd <= CMD_READ;     
                               app_addr <= readaddr;
                        end 
                        
                        else begin
                        
                              
                               err<=0;
                              read_count<=read_count+1;        
                               app_en<=1;
                               app_cmd <= CMD_READ;     
                              app_addr <= readaddr;
                              if(readaddr<786424)readaddr<=readaddr+8;
                              else begin
                                   readaddr<=0;
                                   if(counter>0)
                                   counter<=counter+1;
                                    
                               end
                              cycle_counter<=cycle_counter+1;
                          end
                  end
                 
                 
                  
              end 
             
              
    
         
        if (app_rd_data_valid && err==0) begin
                
                
                data<=app_rd_data;
                store_coun<=store_coun+1;
                    
                if((cycle_counter2<5 && start_drawing==1) || (cycle_counter2<10 && start_drawing==0))
                begin
                    
                    
                    cycle_counter2<=cycle_counter2+1;
                   
                     if(start_drawing==0)data_storage<={data_storage,app_rd_data};
                   else begin
                    data_storage[(index*128)+:128]<=app_rd_data;
                    index<=index-1;
                    end
                  
              end
              else if(start_drawing)
              begin   
                              
                              if(index<5) data_storage[640+:640]<={data_storage[640+:640],app_rd_data};
                              else data_storage[0+:640]<={data_storage[0+:640],app_rd_data};
 
              end
        
      end
               if(store_coun==10)start_drawing<=1;


      
             if(ack_vga_reg==0 && need_pixel && read_count==10 && cycle_counter==cycle_counter2)begin
               
              ack_vga_reg<=1;
              read_count<=5;
               cycle_counter<=0; 
               cycle_counter2<=0;
                if(need_pixel==1)index<=9;
         
          
      end
      
      if(need_pixel==0)ack_vga_reg<=0;
     
      end

      IDLE:begin
      
      
     
     if(framedone && zoom_reg2==0 && zoom_reg==0)state<=READ;
      
      if(do_write)state<=WRITE;
       
      end
      default: begin
     
        state<=PARK;
      end
    endcase
  end
end









 
endmodule
