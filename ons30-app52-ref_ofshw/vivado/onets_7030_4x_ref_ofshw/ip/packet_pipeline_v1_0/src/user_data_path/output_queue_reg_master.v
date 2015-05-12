`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/03/05 16:41:32
// Design Name: 
// Module Name: output_queue_reg_master
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

   
   module output_queue_reg_master
   (
      input [31:0]   data_output_queues_i ,
      input [31:0]   addr_output_queues_i ,
      input          req_output_queues_i  ,
      input          rw_output_queues_i   ,
      output reg    ack_output_queues_o  ,
      output reg[31:0]  data_output_queues_o ,
      
      input clk,
      input reset,
      
      output reg[5:0]queue_weight_0,
      output reg[5:0]queue_weight_1,
      output reg[5:0]queue_weight_2,
      output reg[5:0]queue_weight_3,
      output reg[5:0]queue_weight_4,
      output reg[5:0]queue_weight_5,
      
      input [5:0]transmit_vld_0   ,
      input [5:0]transmit_vld_1   ,
      input [5:0]transmit_vld_2   ,
      input [5:0]transmit_vld_3   ,
      input [5:0]transmit_vld_4   ,
      input [5:0]transmit_vld_5   ,
      input [5:0]transmit_vld_6   ,
      input [5:0]transmit_vld_7   ,
   
      input [31:0]qos_byte_0   ,
      input [31:0]qos_byte_1   ,
      input [31:0]qos_byte_2   ,
      input [31:0]qos_byte_3   ,
      input [31:0]qos_byte_4   ,
      input [31:0]qos_byte_5   ,
      input [31:0]qos_byte_6   ,
      input [31:0]qos_byte_7   ,
   
      input [5:0]drop_vld_0        ,
      input [5:0]drop_vld_1        ,
      input [5:0]drop_vld_2        ,
      input [5:0]drop_vld_3        ,
      input [5:0]drop_vld_4        ,
      input [5:0]drop_vld_5        ,
      input [5:0]drop_vld_6        ,
      input [5:0]drop_vld_7        
   );
`ifdef ONETS45
begin
       reg [31:0]drop_pkt_0[5:0];
       reg [31:0]drop_pkt_1[5:0];
       reg [31:0]drop_pkt_2[5:0];
       reg [31:0]drop_pkt_3[5:0];
       reg [31:0]drop_pkt_4[5:0];
       reg [31:0]drop_pkt_5[5:0];
       reg [31:0]drop_pkt_6[5:0];
       reg [31:0]drop_pkt_7[5:0];
       
       reg [31:0]drop_byte_0[5:0];
       reg [31:0]drop_byte_1[5:0];
       reg [31:0]drop_byte_2[5:0];
       reg [31:0]drop_byte_3[5:0];
       reg [31:0]drop_byte_4[5:0];
       reg [31:0]drop_byte_5[5:0];
       reg [31:0]drop_byte_6[5:0];
       reg [31:0]drop_byte_7[5:0];
       
       reg [31:0]transmit_byte_0[5:0];
       reg [31:0]transmit_byte_1[5:0];
       reg [31:0]transmit_byte_2[5:0];
       reg [31:0]transmit_byte_3[5:0];
       reg [31:0]transmit_byte_4[5:0];
       reg [31:0]transmit_byte_5[5:0];
       reg [31:0]transmit_byte_6[5:0];
       reg [31:0]transmit_byte_7[5:0];
       
       reg [31:0]transmit_pkt_0[5:0];
       reg [31:0]transmit_pkt_1[5:0];
       reg [31:0]transmit_pkt_2[5:0];
       reg [31:0]transmit_pkt_3[5:0];
       reg [31:0]transmit_pkt_4[5:0];
       reg [31:0]transmit_pkt_5[5:0];
       reg [31:0]transmit_pkt_6[5:0];
       reg [31:0]transmit_pkt_7[5:0];
    
       always@(posedge clk)
       if(reset)
       begin
         transmit_pkt_0[0]<=0;
         transmit_pkt_0[1]<=0;
         transmit_pkt_0[2]<=0;
         transmit_pkt_0[3]<=0;
         transmit_pkt_0[4]<=0;
         
         transmit_byte_0[0]<=0;
         transmit_byte_0[1]<=0;
         transmit_byte_0[2]<=0;
         transmit_byte_0[3]<=0;
         transmit_byte_0[4]<=0;
         
         drop_pkt_0[0]<=0;
         drop_pkt_0[1]<=0;
         drop_pkt_0[2]<=0;
         drop_pkt_0[3]<=0;
         drop_pkt_0[4]<=0;
         
         drop_byte_0[0]<=0;
         drop_byte_0[1]<=0;
         drop_byte_0[2]<=0;
         drop_byte_0[3]<=0;
         drop_byte_0[4]<=0;
       end
       else if(|transmit_vld_0)
       begin
         case(transmit_vld_0)
            6'b000001:
            begin
               transmit_pkt_0[0]<=transmit_pkt_0[0]+1;
               transmit_byte_0[0]<=transmit_byte_0[0]+qos_byte_0;
            end
            6'b000010:
            begin
               transmit_pkt_0[1]<=transmit_pkt_0[1]+1;
               transmit_byte_0[1]<=transmit_byte_0[1]+qos_byte_0;
            end
            6'b000100:
            begin
               transmit_pkt_0[2]<=transmit_pkt_0[2]+1;
               transmit_byte_0[2]<=transmit_byte_0[2]+qos_byte_0;
            end
            6'b001000:
            begin
               transmit_pkt_0[3]<=transmit_pkt_0[3]+1;
               transmit_byte_0[3]<=transmit_byte_0[3]+qos_byte_0;
            end
            6'b010000:
            begin
               transmit_pkt_0[4]<=transmit_pkt_0[4]+1;
               transmit_byte_0[4]<=transmit_byte_0[4]+qos_byte_0;
            end 
           6'b100000:
           begin
              transmit_pkt_0[5]<=transmit_pkt_0[5]+1;
              transmit_byte_0[5]<=transmit_byte_0[5]+qos_byte_0;
           end  
        endcase  
       end
       else if(|drop_vld_0)
       begin
         case(drop_vld_0)
          6'b000001:
             begin
                drop_pkt_0[0]<=drop_pkt_0[0]+1;
                drop_byte_0[0]<=drop_byte_0[0]+qos_byte_0;
             end
             6'b000010:
             begin
                drop_pkt_0[1]<=drop_pkt_0[1]+1;
                drop_byte_0[1]<=drop_byte_0[1]+qos_byte_0;
             end
             6'b000100:
             begin
                drop_pkt_0[2]<=drop_pkt_0[2]+1;
                drop_byte_0[2]<=drop_byte_0[2]+qos_byte_0;
             end
             6'b001000:
             begin
                drop_pkt_0[3]<=drop_pkt_0[3]+1;
                drop_byte_0[3]<=drop_byte_0[3]+qos_byte_0;
             end
             6'b010000:
             begin
                drop_pkt_0[4]<=drop_pkt_0[4]+1;
                drop_byte_0[4]<=drop_byte_0[4]+qos_byte_0;
             end 
            6'b100000:
            begin
               drop_pkt_0[5]<=drop_pkt_0[5]+1;
               drop_byte_0[5]<=drop_byte_0[5]+qos_byte_0;
            end  
         endcase  
       end
       
       always@(posedge clk)
              if(reset)
              begin
                transmit_pkt_1[0]<=0;
                transmit_pkt_1[1]<=0;
                transmit_pkt_1[2]<=0;
                transmit_pkt_1[3]<=0;
                transmit_pkt_1[4]<=0;
                
                transmit_byte_1[0]<=0;
                transmit_byte_1[1]<=0;
                transmit_byte_1[2]<=0;
                transmit_byte_1[3]<=0;
                transmit_byte_1[4]<=0;
                
                drop_pkt_1[0]<=0;
                drop_pkt_1[1]<=0;
                drop_pkt_1[2]<=0;
                drop_pkt_1[3]<=0;
                drop_pkt_1[4]<=0;
                
                drop_byte_1[0]<=0;
                drop_byte_1[1]<=0;
                drop_byte_1[2]<=0;
                drop_byte_1[3]<=0;
                drop_byte_1[4]<=0;
              end
              else if(|transmit_vld_1)
              begin
                case(transmit_vld_1)
                   6'b000001:
                   begin
                      transmit_pkt_1[0]<=transmit_pkt_1[0]+1;
                      transmit_byte_1[0]<=transmit_byte_1[0]+qos_byte_1;
                   end
                   6'b000010:
                   begin
                      transmit_pkt_1[1]<=transmit_pkt_1[1]+1;
                      transmit_byte_1[1]<=transmit_byte_1[1]+qos_byte_1;
                   end
                   6'b000100:
                   begin
                      transmit_pkt_1[2]<=transmit_pkt_1[2]+1;
                      transmit_byte_1[2]<=transmit_byte_1[2]+qos_byte_1;
                   end
                   6'b001000:
                   begin
                      transmit_pkt_1[3]<=transmit_pkt_1[3]+1;
                      transmit_byte_1[3]<=transmit_byte_1[3]+qos_byte_1;
                   end
                   6'b010000:
                   begin
                      transmit_pkt_1[4]<=transmit_pkt_1[4]+1;
                      transmit_byte_1[4]<=transmit_byte_1[4]+qos_byte_1;
                   end 
                  6'b100000:
                  begin
                     transmit_pkt_1[5]<=transmit_pkt_1[5]+1;
                     transmit_byte_1[5]<=transmit_byte_1[5]+qos_byte_1;
                  end  
               endcase  
              end
              else if(|drop_vld_1)
              begin
                case(drop_vld_1)
                 6'b000001:
                    begin
                       drop_pkt_1[0]<=drop_pkt_1[0]+1;
                       drop_byte_1[0]<=drop_byte_1[0]+qos_byte_1;
                    end
                    6'b000010:
                    begin
                       drop_pkt_1[1]<=drop_pkt_1[1]+1;
                       drop_byte_1[1]<=drop_byte_1[1]+qos_byte_1;
                    end
                    6'b000100:
                    begin
                       drop_pkt_1[2]<=drop_pkt_1[2]+1;
                       drop_byte_1[2]<=drop_byte_1[2]+qos_byte_1;
                    end
                    6'b001000:
                    begin
                       drop_pkt_1[3]<=drop_pkt_1[3]+1;
                       drop_byte_1[3]<=drop_byte_1[3]+qos_byte_1;
                    end
                    6'b010000:
                    begin
                       drop_pkt_1[4]<=drop_pkt_1[4]+1;
                       drop_byte_1[4]<=drop_byte_1[4]+qos_byte_1;
                    end 
                   6'b100000:
                   begin
                      drop_pkt_1[5]<=drop_pkt_1[5]+1;
                      drop_byte_1[5]<=drop_byte_1[5]+qos_byte_1;
                   end  
                endcase  
              end
           
          always@(posedge clk)
                 if(reset)
                 begin
                   transmit_pkt_2[0]<=0;
                   transmit_pkt_2[1]<=0;
                   transmit_pkt_2[2]<=0;
                   transmit_pkt_2[3]<=0;
                   transmit_pkt_2[4]<=0;
                   
                   transmit_byte_2[0]<=0;
                   transmit_byte_2[1]<=0;
                   transmit_byte_2[2]<=0;
                   transmit_byte_2[3]<=0;
                   transmit_byte_2[4]<=0;
                   
                   drop_pkt_2[0]<=0;
                   drop_pkt_2[1]<=0;
                   drop_pkt_2[2]<=0;
                   drop_pkt_2[3]<=0;
                   drop_pkt_2[4]<=0;
                   
                   drop_byte_2[0]<=0;
                   drop_byte_2[1]<=0;
                   drop_byte_2[2]<=0;
                   drop_byte_2[3]<=0;
                   drop_byte_2[4]<=0;
                 end
                 else if(|transmit_vld_2)
                 begin
                   case(transmit_vld_2)
                      6'b000001:
                      begin
                         transmit_pkt_2[0]<=transmit_pkt_2[0]+1;
                         transmit_byte_2[0]<=transmit_byte_2[0]+qos_byte_2;
                      end
                      6'b000010:
                      begin
                         transmit_pkt_2[1]<=transmit_pkt_2[1]+1;
                         transmit_byte_2[1]<=transmit_byte_2[1]+qos_byte_2;
                      end
                      6'b000100:
                      begin
                         transmit_pkt_2[2]<=transmit_pkt_2[2]+1;
                         transmit_byte_2[2]<=transmit_byte_2[2]+qos_byte_2;
                      end
                      6'b001000:
                      begin
                         transmit_pkt_2[3]<=transmit_pkt_2[3]+1;
                         transmit_byte_2[3]<=transmit_byte_2[3]+qos_byte_2;
                      end
                      6'b010000:
                      begin
                         transmit_pkt_2[4]<=transmit_pkt_2[4]+1;
                         transmit_byte_2[4]<=transmit_byte_2[4]+qos_byte_2;
                      end 
                     6'b100000:
                     begin
                        transmit_pkt_2[5]<=transmit_pkt_2[5]+1;
                        transmit_byte_2[5]<=transmit_byte_2[5]+qos_byte_2;
                     end  
                  endcase  
                 end
                 else if(|drop_vld_2)
                 begin
                   case(drop_vld_2)
                    6'b000001:
                       begin
                          drop_pkt_2[0]<=drop_pkt_2[0]+1;
                          drop_byte_2[0]<=drop_byte_2[0]+qos_byte_2;
                       end
                       6'b000010:
                       begin
                          drop_pkt_2[1]<=drop_pkt_2[1]+1;
                          drop_byte_2[1]<=drop_byte_2[1]+qos_byte_2;
                       end
                       6'b000100:
                       begin
                          drop_pkt_2[2]<=drop_pkt_2[2]+1;
                          drop_byte_2[2]<=drop_byte_2[2]+qos_byte_2;
                       end
                       6'b001000:
                       begin
                          drop_pkt_2[3]<=drop_pkt_2[3]+1;
                          drop_byte_2[3]<=drop_byte_2[3]+qos_byte_2;
                       end
                       6'b010000:
                       begin
                          drop_pkt_2[4]<=drop_pkt_2[4]+1;
                          drop_byte_2[4]<=drop_byte_2[4]+qos_byte_2;
                       end 
                      6'b100000:
                      begin
                         drop_pkt_2[5]<=drop_pkt_2[5]+1;
                         drop_byte_2[5]<=drop_byte_2[5]+qos_byte_2;
                      end  
                   endcase  
                 end
                     
                 always@(posedge clk)
                        if(reset)
                        begin
                          transmit_pkt_3[0]<=0;
                          transmit_pkt_3[1]<=0;
                          transmit_pkt_3[2]<=0;
                          transmit_pkt_3[3]<=0;
                          transmit_pkt_3[4]<=0;
                          
                          transmit_byte_3[0]<=0;
                          transmit_byte_3[1]<=0;
                          transmit_byte_3[2]<=0;
                          transmit_byte_3[3]<=0;
                          transmit_byte_3[4]<=0;
                          
                          drop_pkt_3[0]<=0;
                          drop_pkt_3[1]<=0;
                          drop_pkt_3[2]<=0;
                          drop_pkt_3[3]<=0;
                          drop_pkt_3[4]<=0;
                          
                          drop_byte_3[0]<=0;
                          drop_byte_3[1]<=0;
                          drop_byte_3[2]<=0;
                          drop_byte_3[3]<=0;
                          drop_byte_3[4]<=0;
                        end
                        else if(|transmit_vld_3)
                        begin
                          case(transmit_vld_3)
                             6'b000001:
                             begin
                                transmit_pkt_3[0]<=transmit_pkt_3[0]+1;
                                transmit_byte_3[0]<=transmit_byte_3[0]+qos_byte_3;
                             end
                             6'b000010:
                             begin
                                transmit_pkt_3[1]<=transmit_pkt_3[1]+1;
                                transmit_byte_3[1]<=transmit_byte_3[1]+qos_byte_3;
                             end
                             6'b000100:
                             begin
                                transmit_pkt_3[2]<=transmit_pkt_3[2]+1;
                                transmit_byte_3[2]<=transmit_byte_3[2]+qos_byte_3;
                             end
                             6'b001000:
                             begin
                                transmit_pkt_3[3]<=transmit_pkt_3[3]+1;
                                transmit_byte_3[3]<=transmit_byte_3[3]+qos_byte_3;
                             end
                             6'b010000:
                             begin
                                transmit_pkt_3[4]<=transmit_pkt_3[4]+1;
                                transmit_byte_3[4]<=transmit_byte_3[4]+qos_byte_3;
                             end 
                            6'b100000:
                            begin
                               transmit_pkt_3[5]<=transmit_pkt_3[5]+1;
                               transmit_byte_3[5]<=transmit_byte_3[5]+qos_byte_3;
                            end  
                         endcase  
                        end
                        else if(|drop_vld_3)
                        begin
                          case(drop_vld_3)
                           6'b000001:
                              begin
                                 drop_pkt_3[0]<=drop_pkt_3[0]+1;
                                 drop_byte_3[0]<=drop_byte_3[0]+qos_byte_3;
                              end
                              6'b000010:
                              begin
                                 drop_pkt_3[1]<=drop_pkt_3[1]+1;
                                 drop_byte_3[1]<=drop_byte_3[1]+qos_byte_3;
                              end
                              6'b000100:
                              begin
                                 drop_pkt_3[2]<=drop_pkt_3[2]+1;
                                 drop_byte_3[2]<=drop_byte_3[2]+qos_byte_3;
                              end
                              6'b001000:
                              begin
                                 drop_pkt_3[3]<=drop_pkt_3[3]+1;
                                 drop_byte_3[3]<=drop_byte_3[3]+qos_byte_3;
                              end
                              6'b010000:
                              begin
                                 drop_pkt_3[4]<=drop_pkt_3[4]+1;
                                 drop_byte_3[4]<=drop_byte_3[4]+qos_byte_3;
                              end 
                             6'b100000:
                             begin
                                drop_pkt_3[5]<=drop_pkt_3[5]+1;
                                drop_byte_3[5]<=drop_byte_3[5]+qos_byte_3;
                             end  
                          endcase  
                        end
                        
                        always@(posedge clk)
                               if(reset)
                               begin
                                 transmit_pkt_4[0]<=0;
                                 transmit_pkt_4[1]<=0;
                                 transmit_pkt_4[2]<=0;
                                 transmit_pkt_4[3]<=0;
                                 transmit_pkt_4[4]<=0;
                                 
                                 transmit_byte_4[0]<=0;
                                 transmit_byte_4[1]<=0;
                                 transmit_byte_4[2]<=0;
                                 transmit_byte_4[3]<=0;
                                 transmit_byte_4[4]<=0;
                                 
                                 drop_pkt_4[0]<=0;
                                 drop_pkt_4[1]<=0;
                                 drop_pkt_4[2]<=0;
                                 drop_pkt_4[3]<=0;
                                 drop_pkt_4[4]<=0;
                                 
                                 drop_byte_4[0]<=0;
                                 drop_byte_4[1]<=0;
                                 drop_byte_4[2]<=0;
                                 drop_byte_4[3]<=0;
                                 drop_byte_4[4]<=0;
                               end
                               else if(|transmit_vld_4)
                               begin
                                 case(transmit_vld_4)
                                    6'b000001:
                                    begin
                                       transmit_pkt_4[0]<=transmit_pkt_4[0]+1;
                                       transmit_byte_4[0]<=transmit_byte_4[0]+qos_byte_4;
                                    end
                                    6'b000010:
                                    begin
                                       transmit_pkt_4[1]<=transmit_pkt_4[1]+1;
                                       transmit_byte_4[1]<=transmit_byte_4[1]+qos_byte_4;
                                    end
                                    6'b000100:
                                    begin
                                       transmit_pkt_4[2]<=transmit_pkt_4[2]+1;
                                       transmit_byte_4[2]<=transmit_byte_4[2]+qos_byte_4;
                                    end
                                    6'b001000:
                                    begin
                                       transmit_pkt_4[3]<=transmit_pkt_4[3]+1;
                                       transmit_byte_4[3]<=transmit_byte_4[3]+qos_byte_4;
                                    end
                                    6'b010000:
                                    begin
                                       transmit_pkt_4[4]<=transmit_pkt_4[4]+1;
                                       transmit_byte_4[4]<=transmit_byte_4[4]+qos_byte_4;
                                    end 
                                   6'b100000:
                                   begin
                                      transmit_pkt_4[5]<=transmit_pkt_4[5]+1;
                                      transmit_byte_4[5]<=transmit_byte_4[5]+qos_byte_4;
                                   end  
                                endcase  
                               end
                               else if(|drop_vld_4)
                               begin
                                 case(drop_vld_4)
                                  6'b000001:
                                     begin
                                        drop_pkt_4[0]<=drop_pkt_4[0]+1;
                                        drop_byte_4[0]<=drop_byte_4[0]+qos_byte_4;
                                     end
                                     6'b000010:
                                     begin
                                        drop_pkt_4[1]<=drop_pkt_4[1]+1;
                                        drop_byte_4[1]<=drop_byte_4[1]+qos_byte_4;
                                     end
                                     6'b000100:
                                     begin
                                        drop_pkt_4[2]<=drop_pkt_4[2]+1;
                                        drop_byte_4[2]<=drop_byte_4[2]+qos_byte_4;
                                     end
                                     6'b001000:
                                     begin
                                        drop_pkt_4[3]<=drop_pkt_4[3]+1;
                                        drop_byte_4[3]<=drop_byte_4[3]+qos_byte_4;
                                     end
                                     6'b010000:
                                     begin
                                        drop_pkt_4[4]<=drop_pkt_4[4]+1;
                                        drop_byte_4[4]<=drop_byte_4[4]+qos_byte_4;
                                     end 
                                    6'b100000:
                                    begin
                                       drop_pkt_4[5]<=drop_pkt_4[5]+1;
                                       drop_byte_4[5]<=drop_byte_4[5]+qos_byte_4;
                                    end  
                                 endcase  
                               end

          always@(posedge clk)
                 if(reset)
                 begin
                   transmit_pkt_5[0]<=0;
                   transmit_pkt_5[1]<=0;
                   transmit_pkt_5[2]<=0;
                   transmit_pkt_5[3]<=0;
                   transmit_pkt_5[4]<=0;
                   
                   transmit_byte_5[0]<=0;
                   transmit_byte_5[1]<=0;
                   transmit_byte_5[2]<=0;
                   transmit_byte_5[3]<=0;
                   transmit_byte_5[4]<=0;
                   
                   drop_pkt_5[0]<=0;
                   drop_pkt_5[1]<=0;
                   drop_pkt_5[2]<=0;
                   drop_pkt_5[3]<=0;
                   drop_pkt_5[4]<=0;
                   
                   drop_byte_5[0]<=0;
                   drop_byte_5[1]<=0;
                   drop_byte_5[2]<=0;
                   drop_byte_5[3]<=0;
                   drop_byte_5[4]<=0;
                 end
                 else if(|transmit_vld_5)
                 begin
                   case(transmit_vld_5)
                      6'b000001:
                      begin
                         transmit_pkt_5[0]<=transmit_pkt_5[0]+1;
                         transmit_byte_5[0]<=transmit_byte_5[0]+qos_byte_5;
                      end
                      6'b000010:
                      begin
                         transmit_pkt_5[1]<=transmit_pkt_5[1]+1;
                         transmit_byte_5[1]<=transmit_byte_5[1]+qos_byte_5;
                      end
                      6'b000100:
                      begin
                         transmit_pkt_5[2]<=transmit_pkt_5[2]+1;
                         transmit_byte_5[2]<=transmit_byte_5[2]+qos_byte_5;
                      end
                      6'b001000:
                      begin
                         transmit_pkt_5[3]<=transmit_pkt_5[3]+1;
                         transmit_byte_5[3]<=transmit_byte_5[3]+qos_byte_5;
                      end
                      6'b010000:
                      begin
                         transmit_pkt_5[4]<=transmit_pkt_5[4]+1;
                         transmit_byte_5[4]<=transmit_byte_5[4]+qos_byte_5;
                      end 
                     6'b100000:
                     begin
                        transmit_pkt_5[5]<=transmit_pkt_5[5]+1;
                        transmit_byte_5[5]<=transmit_byte_5[5]+qos_byte_5;
                     end  
                  endcase  
                 end
                 else if(|drop_vld_5)
                 begin
                   case(drop_vld_5)
                    6'b000001:
                       begin
                          drop_pkt_5[0]<=drop_pkt_5[0]+1;
                          drop_byte_5[0]<=drop_byte_5[0]+qos_byte_5;
                       end
                       6'b000010:
                       begin
                          drop_pkt_5[1]<=drop_pkt_5[1]+1;
                          drop_byte_5[1]<=drop_byte_5[1]+qos_byte_5;
                       end
                       6'b000100:
                       begin
                          drop_pkt_5[2]<=drop_pkt_5[2]+1;
                          drop_byte_5[2]<=drop_byte_5[2]+qos_byte_5;
                       end
                       6'b001000:
                       begin
                          drop_pkt_5[3]<=drop_pkt_5[3]+1;
                          drop_byte_5[3]<=drop_byte_5[3]+qos_byte_5;
                       end
                       6'b010000:
                       begin
                          drop_pkt_5[4]<=drop_pkt_5[4]+1;
                          drop_byte_5[4]<=drop_byte_5[4]+qos_byte_5;
                       end 
                      6'b100000:
                      begin
                         drop_pkt_5[5]<=drop_pkt_5[5]+1;
                         drop_byte_5[5]<=drop_byte_5[5]+qos_byte_5;
                      end  
                   endcase  
                 end

          always@(posedge clk)
                 if(reset)
                 begin
                   transmit_pkt_6[0]<=0;
                   transmit_pkt_6[1]<=0;
                   transmit_pkt_6[2]<=0;
                   transmit_pkt_6[3]<=0;
                   transmit_pkt_6[4]<=0;
                   
                   transmit_byte_6[0]<=0;
                   transmit_byte_6[1]<=0;
                   transmit_byte_6[2]<=0;
                   transmit_byte_6[3]<=0;
                   transmit_byte_6[4]<=0;
                   
                   drop_pkt_6[0]<=0;
                   drop_pkt_6[1]<=0;
                   drop_pkt_6[2]<=0;
                   drop_pkt_6[3]<=0;
                   drop_pkt_6[4]<=0;
                   
                   drop_byte_6[0]<=0;
                   drop_byte_6[1]<=0;
                   drop_byte_6[2]<=0;
                   drop_byte_6[3]<=0;
                   drop_byte_6[4]<=0;
                 end
                 else if(|transmit_vld_6)
                 begin
                   case(transmit_vld_6)
                      6'b000001:
                      begin
                         transmit_pkt_6[0]<=transmit_pkt_6[0]+1;
                         transmit_byte_6[0]<=transmit_byte_6[0]+qos_byte_6;
                      end
                      6'b000010:
                      begin
                         transmit_pkt_6[1]<=transmit_pkt_6[1]+1;
                         transmit_byte_6[1]<=transmit_byte_6[1]+qos_byte_6;
                      end
                      6'b000100:
                      begin
                         transmit_pkt_6[2]<=transmit_pkt_6[2]+1;
                         transmit_byte_6[2]<=transmit_byte_6[2]+qos_byte_6;
                      end
                      6'b001000:
                      begin
                         transmit_pkt_6[3]<=transmit_pkt_6[3]+1;
                         transmit_byte_6[3]<=transmit_byte_6[3]+qos_byte_6;
                      end
                      6'b010000:
                      begin
                         transmit_pkt_6[4]<=transmit_pkt_6[4]+1;
                         transmit_byte_6[4]<=transmit_byte_6[4]+qos_byte_6;
                      end 
                     6'b100000:
                     begin
                        transmit_pkt_6[5]<=transmit_pkt_6[5]+1;
                        transmit_byte_6[5]<=transmit_byte_6[5]+qos_byte_6;
                     end  
                  endcase  
                 end
                 else if(|drop_vld_6)
                 begin
                   case(drop_vld_6)
                    6'b000001:
                       begin
                          drop_pkt_6[0]<=drop_pkt_6[0]+1;
                          drop_byte_6[0]<=drop_byte_6[0]+qos_byte_6;
                       end
                       6'b000010:
                       begin
                          drop_pkt_6[1]<=drop_pkt_6[1]+1;
                          drop_byte_6[1]<=drop_byte_6[1]+qos_byte_6;
                       end
                       6'b000100:
                       begin
                          drop_pkt_6[2]<=drop_pkt_6[2]+1;
                          drop_byte_6[2]<=drop_byte_6[2]+qos_byte_6;
                       end
                       6'b001000:
                       begin
                          drop_pkt_6[3]<=drop_pkt_6[3]+1;
                          drop_byte_6[3]<=drop_byte_6[3]+qos_byte_6;
                       end
                       6'b010000:
                       begin
                          drop_pkt_6[4]<=drop_pkt_6[4]+1;
                          drop_byte_6[4]<=drop_byte_6[4]+qos_byte_6;
                       end 
                      6'b100000:
                      begin
                         drop_pkt_6[5]<=drop_pkt_6[5]+1;
                         drop_byte_6[5]<=drop_byte_6[5]+qos_byte_6;
                      end  
                   endcase  
                 end

          always@(posedge clk)
                 if(reset)
                 begin
                   transmit_pkt_7[0]<=0;
                   transmit_pkt_7[1]<=0;
                   transmit_pkt_7[2]<=0;
                   transmit_pkt_7[3]<=0;
                   transmit_pkt_7[4]<=0;
                   
                   transmit_byte_7[0]<=0;
                   transmit_byte_7[1]<=0;
                   transmit_byte_7[2]<=0;
                   transmit_byte_7[3]<=0;
                   transmit_byte_7[4]<=0;
                   
                   drop_pkt_7[0]<=0;
                   drop_pkt_7[1]<=0;
                   drop_pkt_7[2]<=0;
                   drop_pkt_7[3]<=0;
                   drop_pkt_7[4]<=0;
                   
                   drop_byte_7[0]<=0;
                   drop_byte_7[1]<=0;
                   drop_byte_7[2]<=0;
                   drop_byte_7[3]<=0;
                   drop_byte_7[4]<=0;
                 end
                 else if(|transmit_vld_7)
                 begin
                   case(transmit_vld_7)
                      6'b000001:
                      begin
                         transmit_pkt_7[0]<=transmit_pkt_7[0]+1;
                         transmit_byte_7[0]<=transmit_byte_7[0]+qos_byte_7;
                      end
                      6'b000010:
                      begin
                         transmit_pkt_7[1]<=transmit_pkt_7[1]+1;
                         transmit_byte_7[1]<=transmit_byte_7[1]+qos_byte_7;
                      end
                      6'b000100:
                      begin
                         transmit_pkt_7[2]<=transmit_pkt_7[2]+1;
                         transmit_byte_7[2]<=transmit_byte_7[2]+qos_byte_7;
                      end
                      6'b001000:
                      begin
                         transmit_pkt_7[3]<=transmit_pkt_7[3]+1;
                         transmit_byte_7[3]<=transmit_byte_7[3]+qos_byte_7;
                      end
                      6'b010000:
                      begin
                         transmit_pkt_7[4]<=transmit_pkt_7[4]+1;
                         transmit_byte_7[4]<=transmit_byte_7[4]+qos_byte_7;
                      end 
                     6'b100000:
                     begin
                        transmit_pkt_7[5]<=transmit_pkt_7[5]+1;
                        transmit_byte_7[5]<=transmit_byte_7[5]+qos_byte_7;
                     end  
                  endcase  
                 end
                 else if(|drop_vld_7)
                 begin
                   case(drop_vld_7)
                    6'b000001:
                       begin
                          drop_pkt_7[0]<=drop_pkt_7[0]+1;
                          drop_byte_7[0]<=drop_byte_7[0]+qos_byte_7;
                       end
                       6'b000010:
                       begin
                          drop_pkt_7[1]<=drop_pkt_7[1]+1;
                          drop_byte_7[1]<=drop_byte_7[1]+qos_byte_7;
                       end
                       6'b000100:
                       begin
                          drop_pkt_7[2]<=drop_pkt_7[2]+1;
                          drop_byte_7[2]<=drop_byte_7[2]+qos_byte_7;
                       end
                       6'b001000:
                       begin
                          drop_pkt_7[3]<=drop_pkt_7[3]+1;
                          drop_byte_7[3]<=drop_byte_7[3]+qos_byte_7;
                       end
                       6'b010000:
                       begin
                          drop_pkt_7[4]<=drop_pkt_7[4]+1;
                          drop_byte_7[4]<=drop_byte_7[4]+qos_byte_7;
                       end 
                      6'b100000:
                      begin
                         drop_pkt_7[5]<=drop_pkt_7[5]+1;
                         drop_byte_7[5]<=drop_byte_7[5]+qos_byte_7;
                      end  
                   endcase  
                 end
                                                     
          always@(posedge clk)
              if(reset)
              begin
                  queue_weight_0<=1;
                  queue_weight_1<=2;
                  queue_weight_2<=3;
                  queue_weight_3<=4;       
                  queue_weight_4<=5;
                  queue_weight_5<=6;        
                  data_output_queues_o<=32'hdeadbeef;
              end
              else if(req_output_queues_i && rw_output_queues_i==0)
                  case(addr_output_queues_i[7:0])
                  0:queue_weight_0<=data_output_queues_i;
                  4:queue_weight_1<=data_output_queues_i;
                  8:queue_weight_2<=data_output_queues_i;
                  16:queue_weight_3<=data_output_queues_i;
                  20:queue_weight_4<=data_output_queues_i;
                  24:queue_weight_5<=data_output_queues_i;
                  endcase
              else if(req_output_queues_i && rw_output_queues_i==1)
                  case(addr_output_queues_i[7:0])
                     0:data_output_queues_o<=queue_weight_0;
                     4:data_output_queues_o<=queue_weight_1;
                     8:data_output_queues_o<=queue_weight_2;
                     12:data_output_queues_o<=queue_weight_3;
                     16:data_output_queues_o<=queue_weight_4;
                     20:data_output_queues_o<=queue_weight_5;
                     `TRANSMIT_PKT_COUNTER_QUEUES: 
                     case(addr_output_queues_i[19:16])
                        0:data_output_queues_o<=transmit_pkt_0[addr_output_queues_i[15:8]];
                        1:data_output_queues_o<=transmit_pkt_1[addr_output_queues_i[15:8]];
                        2:data_output_queues_o<=transmit_pkt_2[addr_output_queues_i[15:8]];
                        3:data_output_queues_o<=transmit_pkt_3[addr_output_queues_i[15:8]];
                        4:data_output_queues_o<=transmit_pkt_4[addr_output_queues_i[15:8]];
                        5:data_output_queues_o<=transmit_pkt_5[addr_output_queues_i[15:8]];
                        6:data_output_queues_o<=transmit_pkt_6[addr_output_queues_i[15:8]];
                        7:data_output_queues_o<=transmit_pkt_7[addr_output_queues_i[15:8]];
                        default:data_output_queues_o<=32'hdeadbeef;
                     endcase
                     `TRANSMIT_BYTE_COUNTER_QUEUES:
                      case(addr_output_queues_i[19:16])
                         0:data_output_queues_o<=transmit_byte_0[addr_output_queues_i[15:8]];
                         1:data_output_queues_o<=transmit_byte_1[addr_output_queues_i[15:8]];
                         2:data_output_queues_o<=transmit_byte_2[addr_output_queues_i[15:8]];
                         3:data_output_queues_o<=transmit_byte_3[addr_output_queues_i[15:8]];
                         4:data_output_queues_o<=transmit_byte_4[addr_output_queues_i[15:8]];
                         5:data_output_queues_o<=transmit_byte_5[addr_output_queues_i[15:8]];
                         6:data_output_queues_o<=transmit_byte_6[addr_output_queues_i[15:8]];
                         7:data_output_queues_o<=transmit_byte_7[addr_output_queues_i[15:8]];
                         default:data_output_queues_o<=32'hdeadbeef;
                      endcase
                      `DROP_PKT_COUNTER_QUEUES:
                      case(addr_output_queues_i[19:16])
                         0:data_output_queues_o<=drop_pkt_0[addr_output_queues_i[15:8]];
                         1:data_output_queues_o<=drop_pkt_1[addr_output_queues_i[15:8]];
                         2:data_output_queues_o<=drop_pkt_2[addr_output_queues_i[15:8]];
                         3:data_output_queues_o<=drop_pkt_3[addr_output_queues_i[15:8]];
                         4:data_output_queues_o<=drop_pkt_4[addr_output_queues_i[15:8]];
                         5:data_output_queues_o<=drop_pkt_5[addr_output_queues_i[15:8]];
                         6:data_output_queues_o<=drop_pkt_6[addr_output_queues_i[15:8]];
                         7:data_output_queues_o<=drop_pkt_7[addr_output_queues_i[15:8]];
                         default:data_output_queues_o<=32'hdeadbeef;
                      endcase
                      `DROP_BYTE_COUNTER_QUEUES:
                      case(addr_output_queues_i[19:16])
                         0:data_output_queues_o<=drop_byte_0[addr_output_queues_i[15:8]];
                         1:data_output_queues_o<=drop_byte_1[addr_output_queues_i[15:8]];
                         2:data_output_queues_o<=drop_byte_2[addr_output_queues_i[15:8]];
                         3:data_output_queues_o<=drop_byte_3[addr_output_queues_i[15:8]];
                         4:data_output_queues_o<=drop_byte_4[addr_output_queues_i[15:8]];
                         5:data_output_queues_o<=drop_byte_5[addr_output_queues_i[15:8]];
                         6:data_output_queues_o<=drop_byte_6[addr_output_queues_i[15:8]];
                         7:data_output_queues_o<=drop_byte_7[addr_output_queues_i[15:8]];
                         default:data_output_queues_o<=32'hdeadbeef;
                      endcase
                      
                     default:data_output_queues_o<=32'hdeadbeef;
                   endcase
end
`elsif ONETS30
begin
reg [31:0]drop_pkt_0[5:0];
reg [31:0]drop_pkt_1[5:0];
reg [31:0]drop_pkt_2[5:0];
reg [31:0]drop_pkt_3[5:0];
reg [31:0]drop_pkt_4[5:0];
reg [31:0]drop_pkt_5[5:0];
reg [31:0]drop_pkt_6[5:0];
reg [31:0]drop_pkt_7[5:0];

reg [31:0]drop_byte_0[5:0];
reg [31:0]drop_byte_1[5:0];
reg [31:0]drop_byte_2[5:0];
reg [31:0]drop_byte_3[5:0];
reg [31:0]drop_byte_4[5:0];
reg [31:0]drop_byte_5[5:0];
reg [31:0]drop_byte_6[5:0];
reg [31:0]drop_byte_7[5:0];

reg [31:0]transmit_byte_0[5:0];
reg [31:0]transmit_byte_1[5:0];
reg [31:0]transmit_byte_2[5:0];
reg [31:0]transmit_byte_3[5:0];
reg [31:0]transmit_byte_4[5:0];
reg [31:0]transmit_byte_5[5:0];
reg [31:0]transmit_byte_6[5:0];
reg [31:0]transmit_byte_7[5:0];

reg [31:0]transmit_pkt_0[5:0];
reg [31:0]transmit_pkt_1[5:0];
reg [31:0]transmit_pkt_2[5:0];
reg [31:0]transmit_pkt_3[5:0];
reg [31:0]transmit_pkt_4[5:0];
reg [31:0]transmit_pkt_5[5:0];
reg [31:0]transmit_pkt_6[5:0];
reg [31:0]transmit_pkt_7[5:0];

always@(posedge clk)
if(reset)
begin
  transmit_pkt_0[0]<=0;
  transmit_pkt_0[1]<=0;
  transmit_pkt_0[2]<=0;
  transmit_pkt_0[3]<=0;
  transmit_pkt_0[4]<=0;
  
  transmit_byte_0[0]<=0;
  transmit_byte_0[1]<=0;
  transmit_byte_0[2]<=0;
  transmit_byte_0[3]<=0;
  transmit_byte_0[4]<=0;
  
  drop_pkt_0[0]<=0;
  drop_pkt_0[1]<=0;
  drop_pkt_0[2]<=0;
  drop_pkt_0[3]<=0;
  drop_pkt_0[4]<=0;
  
  drop_byte_0[0]<=0;
  drop_byte_0[1]<=0;
  drop_byte_0[2]<=0;
  drop_byte_0[3]<=0;
  drop_byte_0[4]<=0;
end
else if(|transmit_vld_0)
begin
  case(transmit_vld_0)
     6'b000001:
     begin
        transmit_pkt_0[0]<=transmit_pkt_0[0]+1;
        transmit_byte_0[0]<=transmit_byte_0[0]+qos_byte_0;
     end
     6'b000010:
     begin
        transmit_pkt_0[1]<=transmit_pkt_0[1]+1;
        transmit_byte_0[1]<=transmit_byte_0[1]+qos_byte_0;
     end
     6'b000100:
     begin
        transmit_pkt_0[2]<=transmit_pkt_0[2]+1;
        transmit_byte_0[2]<=transmit_byte_0[2]+qos_byte_0;
     end
     6'b001000:
     begin
        transmit_pkt_0[3]<=transmit_pkt_0[3]+1;
        transmit_byte_0[3]<=transmit_byte_0[3]+qos_byte_0;
     end
     6'b010000:
     begin
        transmit_pkt_0[4]<=transmit_pkt_0[4]+1;
        transmit_byte_0[4]<=transmit_byte_0[4]+qos_byte_0;
     end 
    6'b100000:
    begin
       transmit_pkt_0[5]<=transmit_pkt_0[5]+1;
       transmit_byte_0[5]<=transmit_byte_0[5]+qos_byte_0;
    end  
 endcase  
end
else if(|drop_vld_0)
begin
  case(drop_vld_0)
   6'b000001:
      begin
         drop_pkt_0[0]<=drop_pkt_0[0]+1;
         drop_byte_0[0]<=drop_byte_0[0]+qos_byte_0;
      end
      6'b000010:
      begin
         drop_pkt_0[1]<=drop_pkt_0[1]+1;
         drop_byte_0[1]<=drop_byte_0[1]+qos_byte_0;
      end
      6'b000100:
      begin
         drop_pkt_0[2]<=drop_pkt_0[2]+1;
         drop_byte_0[2]<=drop_byte_0[2]+qos_byte_0;
      end
      6'b001000:
      begin
         drop_pkt_0[3]<=drop_pkt_0[3]+1;
         drop_byte_0[3]<=drop_byte_0[3]+qos_byte_0;
      end
      6'b010000:
      begin
         drop_pkt_0[4]<=drop_pkt_0[4]+1;
         drop_byte_0[4]<=drop_byte_0[4]+qos_byte_0;
      end 
     6'b100000:
     begin
        drop_pkt_0[5]<=drop_pkt_0[5]+1;
        drop_byte_0[5]<=drop_byte_0[5]+qos_byte_0;
     end  
  endcase  
end

always@(posedge clk)
       if(reset)
       begin
         transmit_pkt_1[0]<=0;
         transmit_pkt_1[1]<=0;
         transmit_pkt_1[2]<=0;
         transmit_pkt_1[3]<=0;
         transmit_pkt_1[4]<=0;
         
         transmit_byte_1[0]<=0;
         transmit_byte_1[1]<=0;
         transmit_byte_1[2]<=0;
         transmit_byte_1[3]<=0;
         transmit_byte_1[4]<=0;
         
         drop_pkt_1[0]<=0;
         drop_pkt_1[1]<=0;
         drop_pkt_1[2]<=0;
         drop_pkt_1[3]<=0;
         drop_pkt_1[4]<=0;
         
         drop_byte_1[0]<=0;
         drop_byte_1[1]<=0;
         drop_byte_1[2]<=0;
         drop_byte_1[3]<=0;
         drop_byte_1[4]<=0;
       end
       else if(|transmit_vld_1)
       begin
         case(transmit_vld_1)
            6'b000001:
            begin
               transmit_pkt_1[0]<=transmit_pkt_1[0]+1;
               transmit_byte_1[0]<=transmit_byte_1[0]+qos_byte_1;
            end
            6'b000010:
            begin
               transmit_pkt_1[1]<=transmit_pkt_1[1]+1;
               transmit_byte_1[1]<=transmit_byte_1[1]+qos_byte_1;
            end
            6'b000100:
            begin
               transmit_pkt_1[2]<=transmit_pkt_1[2]+1;
               transmit_byte_1[2]<=transmit_byte_1[2]+qos_byte_1;
            end
            6'b001000:
            begin
               transmit_pkt_1[3]<=transmit_pkt_1[3]+1;
               transmit_byte_1[3]<=transmit_byte_1[3]+qos_byte_1;
            end
            6'b010000:
            begin
               transmit_pkt_1[4]<=transmit_pkt_1[4]+1;
               transmit_byte_1[4]<=transmit_byte_1[4]+qos_byte_1;
            end 
           6'b100000:
           begin
              transmit_pkt_1[5]<=transmit_pkt_1[5]+1;
              transmit_byte_1[5]<=transmit_byte_1[5]+qos_byte_1;
           end  
        endcase  
       end
       else if(|drop_vld_1)
       begin
         case(drop_vld_1)
          6'b000001:
             begin
                drop_pkt_1[0]<=drop_pkt_1[0]+1;
                drop_byte_1[0]<=drop_byte_1[0]+qos_byte_1;
             end
             6'b000010:
             begin
                drop_pkt_1[1]<=drop_pkt_1[1]+1;
                drop_byte_1[1]<=drop_byte_1[1]+qos_byte_1;
             end
             6'b000100:
             begin
                drop_pkt_1[2]<=drop_pkt_1[2]+1;
                drop_byte_1[2]<=drop_byte_1[2]+qos_byte_1;
             end
             6'b001000:
             begin
                drop_pkt_1[3]<=drop_pkt_1[3]+1;
                drop_byte_1[3]<=drop_byte_1[3]+qos_byte_1;
             end
             6'b010000:
             begin
                drop_pkt_1[4]<=drop_pkt_1[4]+1;
                drop_byte_1[4]<=drop_byte_1[4]+qos_byte_1;
             end 
            6'b100000:
            begin
               drop_pkt_1[5]<=drop_pkt_1[5]+1;
               drop_byte_1[5]<=drop_byte_1[5]+qos_byte_1;
            end  
         endcase  
       end
    
   always@(posedge clk)
          if(reset)
          begin
            transmit_pkt_2[0]<=0;
            transmit_pkt_2[1]<=0;
            transmit_pkt_2[2]<=0;
            transmit_pkt_2[3]<=0;
            transmit_pkt_2[4]<=0;
            
            transmit_byte_2[0]<=0;
            transmit_byte_2[1]<=0;
            transmit_byte_2[2]<=0;
            transmit_byte_2[3]<=0;
            transmit_byte_2[4]<=0;
            
            drop_pkt_2[0]<=0;
            drop_pkt_2[1]<=0;
            drop_pkt_2[2]<=0;
            drop_pkt_2[3]<=0;
            drop_pkt_2[4]<=0;
            
            drop_byte_2[0]<=0;
            drop_byte_2[1]<=0;
            drop_byte_2[2]<=0;
            drop_byte_2[3]<=0;
            drop_byte_2[4]<=0;
          end
          else if(|transmit_vld_2)
          begin
            case(transmit_vld_2)
               6'b000001:
               begin
                  transmit_pkt_2[0]<=transmit_pkt_2[0]+1;
                  transmit_byte_2[0]<=transmit_byte_2[0]+qos_byte_2;
               end
               6'b000010:
               begin
                  transmit_pkt_2[1]<=transmit_pkt_2[1]+1;
                  transmit_byte_2[1]<=transmit_byte_2[1]+qos_byte_2;
               end
               6'b000100:
               begin
                  transmit_pkt_2[2]<=transmit_pkt_2[2]+1;
                  transmit_byte_2[2]<=transmit_byte_2[2]+qos_byte_2;
               end
               6'b001000:
               begin
                  transmit_pkt_2[3]<=transmit_pkt_2[3]+1;
                  transmit_byte_2[3]<=transmit_byte_2[3]+qos_byte_2;
               end
               6'b010000:
               begin
                  transmit_pkt_2[4]<=transmit_pkt_2[4]+1;
                  transmit_byte_2[4]<=transmit_byte_2[4]+qos_byte_2;
               end 
              6'b100000:
              begin
                 transmit_pkt_2[5]<=transmit_pkt_2[5]+1;
                 transmit_byte_2[5]<=transmit_byte_2[5]+qos_byte_2;
              end  
           endcase  
          end
          else if(|drop_vld_2)
          begin
            case(drop_vld_2)
             6'b000001:
                begin
                   drop_pkt_2[0]<=drop_pkt_2[0]+1;
                   drop_byte_2[0]<=drop_byte_2[0]+qos_byte_2;
                end
                6'b000010:
                begin
                   drop_pkt_2[1]<=drop_pkt_2[1]+1;
                   drop_byte_2[1]<=drop_byte_2[1]+qos_byte_2;
                end
                6'b000100:
                begin
                   drop_pkt_2[2]<=drop_pkt_2[2]+1;
                   drop_byte_2[2]<=drop_byte_2[2]+qos_byte_2;
                end
                6'b001000:
                begin
                   drop_pkt_2[3]<=drop_pkt_2[3]+1;
                   drop_byte_2[3]<=drop_byte_2[3]+qos_byte_2;
                end
                6'b010000:
                begin
                   drop_pkt_2[4]<=drop_pkt_2[4]+1;
                   drop_byte_2[4]<=drop_byte_2[4]+qos_byte_2;
                end 
               6'b100000:
               begin
                  drop_pkt_2[5]<=drop_pkt_2[5]+1;
                  drop_byte_2[5]<=drop_byte_2[5]+qos_byte_2;
               end  
            endcase  
          end
              
          always@(posedge clk)
                 if(reset)
                 begin
                   transmit_pkt_3[0]<=0;
                   transmit_pkt_3[1]<=0;
                   transmit_pkt_3[2]<=0;
                   transmit_pkt_3[3]<=0;
                   transmit_pkt_3[4]<=0;
                   
                   transmit_byte_3[0]<=0;
                   transmit_byte_3[1]<=0;
                   transmit_byte_3[2]<=0;
                   transmit_byte_3[3]<=0;
                   transmit_byte_3[4]<=0;
                   
                   drop_pkt_3[0]<=0;
                   drop_pkt_3[1]<=0;
                   drop_pkt_3[2]<=0;
                   drop_pkt_3[3]<=0;
                   drop_pkt_3[4]<=0;
                   
                   drop_byte_3[0]<=0;
                   drop_byte_3[1]<=0;
                   drop_byte_3[2]<=0;
                   drop_byte_3[3]<=0;
                   drop_byte_3[4]<=0;
                 end
                 else if(|transmit_vld_3)
                 begin
                   case(transmit_vld_3)
                      6'b000001:
                      begin
                         transmit_pkt_3[0]<=transmit_pkt_3[0]+1;
                         transmit_byte_3[0]<=transmit_byte_3[0]+qos_byte_3;
                      end
                      6'b000010:
                      begin
                         transmit_pkt_3[1]<=transmit_pkt_3[1]+1;
                         transmit_byte_3[1]<=transmit_byte_3[1]+qos_byte_3;
                      end
                      6'b000100:
                      begin
                         transmit_pkt_3[2]<=transmit_pkt_3[2]+1;
                         transmit_byte_3[2]<=transmit_byte_3[2]+qos_byte_3;
                      end
                      6'b001000:
                      begin
                         transmit_pkt_3[3]<=transmit_pkt_3[3]+1;
                         transmit_byte_3[3]<=transmit_byte_3[3]+qos_byte_3;
                      end
                      6'b010000:
                      begin
                         transmit_pkt_3[4]<=transmit_pkt_3[4]+1;
                         transmit_byte_3[4]<=transmit_byte_3[4]+qos_byte_3;
                      end 
                     6'b100000:
                     begin
                        transmit_pkt_3[5]<=transmit_pkt_3[5]+1;
                        transmit_byte_3[5]<=transmit_byte_3[5]+qos_byte_3;
                     end  
                  endcase  
                 end
                 else if(|drop_vld_3)
                 begin
                   case(drop_vld_3)
                    6'b000001:
                       begin
                          drop_pkt_3[0]<=drop_pkt_3[0]+1;
                          drop_byte_3[0]<=drop_byte_3[0]+qos_byte_3;
                       end
                       6'b000010:
                       begin
                          drop_pkt_3[1]<=drop_pkt_3[1]+1;
                          drop_byte_3[1]<=drop_byte_3[1]+qos_byte_3;
                       end
                       6'b000100:
                       begin
                          drop_pkt_3[2]<=drop_pkt_3[2]+1;
                          drop_byte_3[2]<=drop_byte_3[2]+qos_byte_3;
                       end
                       6'b001000:
                       begin
                          drop_pkt_3[3]<=drop_pkt_3[3]+1;
                          drop_byte_3[3]<=drop_byte_3[3]+qos_byte_3;
                       end
                       6'b010000:
                       begin
                          drop_pkt_3[4]<=drop_pkt_3[4]+1;
                          drop_byte_3[4]<=drop_byte_3[4]+qos_byte_3;
                       end 
                      6'b100000:
                      begin
                         drop_pkt_3[5]<=drop_pkt_3[5]+1;
                         drop_byte_3[5]<=drop_byte_3[5]+qos_byte_3;
                      end  
                   endcase  
                 end
                 
                 always@(posedge clk)
                        if(reset)
                        begin
                          transmit_pkt_4[0]<=0;
                          transmit_pkt_4[1]<=0;
                          transmit_pkt_4[2]<=0;
                          transmit_pkt_4[3]<=0;
                          transmit_pkt_4[4]<=0;
                          
                          transmit_byte_4[0]<=0;
                          transmit_byte_4[1]<=0;
                          transmit_byte_4[2]<=0;
                          transmit_byte_4[3]<=0;
                          transmit_byte_4[4]<=0;
                          
                          drop_pkt_4[0]<=0;
                          drop_pkt_4[1]<=0;
                          drop_pkt_4[2]<=0;
                          drop_pkt_4[3]<=0;
                          drop_pkt_4[4]<=0;
                          
                          drop_byte_4[0]<=0;
                          drop_byte_4[1]<=0;
                          drop_byte_4[2]<=0;
                          drop_byte_4[3]<=0;
                          drop_byte_4[4]<=0;
                        end
                        else if(|transmit_vld_4)
                        begin
                          case(transmit_vld_4)
                             6'b000001:
                             begin
                                transmit_pkt_4[0]<=transmit_pkt_4[0]+1;
                                transmit_byte_4[0]<=transmit_byte_4[0]+qos_byte_4;
                             end
                             6'b000010:
                             begin
                                transmit_pkt_4[1]<=transmit_pkt_4[1]+1;
                                transmit_byte_4[1]<=transmit_byte_4[1]+qos_byte_4;
                             end
                             6'b000100:
                             begin
                                transmit_pkt_4[2]<=transmit_pkt_4[2]+1;
                                transmit_byte_4[2]<=transmit_byte_4[2]+qos_byte_4;
                             end
                             6'b001000:
                             begin
                                transmit_pkt_4[3]<=transmit_pkt_4[3]+1;
                                transmit_byte_4[3]<=transmit_byte_4[3]+qos_byte_4;
                             end
                             6'b010000:
                             begin
                                transmit_pkt_4[4]<=transmit_pkt_4[4]+1;
                                transmit_byte_4[4]<=transmit_byte_4[4]+qos_byte_4;
                             end 
                            6'b100000:
                            begin
                               transmit_pkt_4[5]<=transmit_pkt_4[5]+1;
                               transmit_byte_4[5]<=transmit_byte_4[5]+qos_byte_4;
                            end  
                         endcase  
                        end
                        else if(|drop_vld_4)
                        begin
                          case(drop_vld_4)
                           6'b000001:
                              begin
                                 drop_pkt_4[0]<=drop_pkt_4[0]+1;
                                 drop_byte_4[0]<=drop_byte_4[0]+qos_byte_4;
                              end
                              6'b000010:
                              begin
                                 drop_pkt_4[1]<=drop_pkt_4[1]+1;
                                 drop_byte_4[1]<=drop_byte_4[1]+qos_byte_4;
                              end
                              6'b000100:
                              begin
                                 drop_pkt_4[2]<=drop_pkt_4[2]+1;
                                 drop_byte_4[2]<=drop_byte_4[2]+qos_byte_4;
                              end
                              6'b001000:
                              begin
                                 drop_pkt_4[3]<=drop_pkt_4[3]+1;
                                 drop_byte_4[3]<=drop_byte_4[3]+qos_byte_4;
                              end
                              6'b010000:
                              begin
                                 drop_pkt_4[4]<=drop_pkt_4[4]+1;
                                 drop_byte_4[4]<=drop_byte_4[4]+qos_byte_4;
                              end 
                             6'b100000:
                             begin
                                drop_pkt_4[5]<=drop_pkt_4[5]+1;
                                drop_byte_4[5]<=drop_byte_4[5]+qos_byte_4;
                             end  
                          endcase  
                        end

   always@(posedge clk)
          if(reset)
          begin
            transmit_pkt_5[0]<=0;
            transmit_pkt_5[1]<=0;
            transmit_pkt_5[2]<=0;
            transmit_pkt_5[3]<=0;
            transmit_pkt_5[4]<=0;
            
            transmit_byte_5[0]<=0;
            transmit_byte_5[1]<=0;
            transmit_byte_5[2]<=0;
            transmit_byte_5[3]<=0;
            transmit_byte_5[4]<=0;
            
            drop_pkt_5[0]<=0;
            drop_pkt_5[1]<=0;
            drop_pkt_5[2]<=0;
            drop_pkt_5[3]<=0;
            drop_pkt_5[4]<=0;
            
            drop_byte_5[0]<=0;
            drop_byte_5[1]<=0;
            drop_byte_5[2]<=0;
            drop_byte_5[3]<=0;
            drop_byte_5[4]<=0;
          end
          else if(|transmit_vld_5)
          begin
            case(transmit_vld_5)
               6'b000001:
               begin
                  transmit_pkt_5[0]<=transmit_pkt_5[0]+1;
                  transmit_byte_5[0]<=transmit_byte_5[0]+qos_byte_5;
               end
               6'b000010:
               begin
                  transmit_pkt_5[1]<=transmit_pkt_5[1]+1;
                  transmit_byte_5[1]<=transmit_byte_5[1]+qos_byte_5;
               end
               6'b000100:
               begin
                  transmit_pkt_5[2]<=transmit_pkt_5[2]+1;
                  transmit_byte_5[2]<=transmit_byte_5[2]+qos_byte_5;
               end
               6'b001000:
               begin
                  transmit_pkt_5[3]<=transmit_pkt_5[3]+1;
                  transmit_byte_5[3]<=transmit_byte_5[3]+qos_byte_5;
               end
               6'b010000:
               begin
                  transmit_pkt_5[4]<=transmit_pkt_5[4]+1;
                  transmit_byte_5[4]<=transmit_byte_5[4]+qos_byte_5;
               end 
              6'b100000:
              begin
                 transmit_pkt_5[5]<=transmit_pkt_5[5]+1;
                 transmit_byte_5[5]<=transmit_byte_5[5]+qos_byte_5;
              end  
           endcase  
          end
          else if(|drop_vld_5)
          begin
            case(drop_vld_5)
             6'b000001:
                begin
                   drop_pkt_5[0]<=drop_pkt_5[0]+1;
                   drop_byte_5[0]<=drop_byte_5[0]+qos_byte_5;
                end
                6'b000010:
                begin
                   drop_pkt_5[1]<=drop_pkt_5[1]+1;
                   drop_byte_5[1]<=drop_byte_5[1]+qos_byte_5;
                end
                6'b000100:
                begin
                   drop_pkt_5[2]<=drop_pkt_5[2]+1;
                   drop_byte_5[2]<=drop_byte_5[2]+qos_byte_5;
                end
                6'b001000:
                begin
                   drop_pkt_5[3]<=drop_pkt_5[3]+1;
                   drop_byte_5[3]<=drop_byte_5[3]+qos_byte_5;
                end
                6'b010000:
                begin
                   drop_pkt_5[4]<=drop_pkt_5[4]+1;
                   drop_byte_5[4]<=drop_byte_5[4]+qos_byte_5;
                end 
               6'b100000:
               begin
                  drop_pkt_5[5]<=drop_pkt_5[5]+1;
                  drop_byte_5[5]<=drop_byte_5[5]+qos_byte_5;
               end  
            endcase  
          end

   always@(posedge clk)
          if(reset)
          begin
            transmit_pkt_6[0]<=0;
            transmit_pkt_6[1]<=0;
            transmit_pkt_6[2]<=0;
            transmit_pkt_6[3]<=0;
            transmit_pkt_6[4]<=0;
            
            transmit_byte_6[0]<=0;
            transmit_byte_6[1]<=0;
            transmit_byte_6[2]<=0;
            transmit_byte_6[3]<=0;
            transmit_byte_6[4]<=0;
            
            drop_pkt_6[0]<=0;
            drop_pkt_6[1]<=0;
            drop_pkt_6[2]<=0;
            drop_pkt_6[3]<=0;
            drop_pkt_6[4]<=0;
            
            drop_byte_6[0]<=0;
            drop_byte_6[1]<=0;
            drop_byte_6[2]<=0;
            drop_byte_6[3]<=0;
            drop_byte_6[4]<=0;
          end
          else if(|transmit_vld_6)
          begin
            case(transmit_vld_6)
               6'b000001:
               begin
                  transmit_pkt_6[0]<=transmit_pkt_6[0]+1;
                  transmit_byte_6[0]<=transmit_byte_6[0]+qos_byte_6;
               end
               6'b000010:
               begin
                  transmit_pkt_6[1]<=transmit_pkt_6[1]+1;
                  transmit_byte_6[1]<=transmit_byte_6[1]+qos_byte_6;
               end
               6'b000100:
               begin
                  transmit_pkt_6[2]<=transmit_pkt_6[2]+1;
                  transmit_byte_6[2]<=transmit_byte_6[2]+qos_byte_6;
               end
               6'b001000:
               begin
                  transmit_pkt_6[3]<=transmit_pkt_6[3]+1;
                  transmit_byte_6[3]<=transmit_byte_6[3]+qos_byte_6;
               end
               6'b010000:
               begin
                  transmit_pkt_6[4]<=transmit_pkt_6[4]+1;
                  transmit_byte_6[4]<=transmit_byte_6[4]+qos_byte_6;
               end 
              6'b100000:
              begin
                 transmit_pkt_6[5]<=transmit_pkt_6[5]+1;
                 transmit_byte_6[5]<=transmit_byte_6[5]+qos_byte_6;
              end  
           endcase  
          end
          else if(|drop_vld_6)
          begin
            case(drop_vld_6)
             6'b000001:
                begin
                   drop_pkt_6[0]<=drop_pkt_6[0]+1;
                   drop_byte_6[0]<=drop_byte_6[0]+qos_byte_6;
                end
                6'b000010:
                begin
                   drop_pkt_6[1]<=drop_pkt_6[1]+1;
                   drop_byte_6[1]<=drop_byte_6[1]+qos_byte_6;
                end
                6'b000100:
                begin
                   drop_pkt_6[2]<=drop_pkt_6[2]+1;
                   drop_byte_6[2]<=drop_byte_6[2]+qos_byte_6;
                end
                6'b001000:
                begin
                   drop_pkt_6[3]<=drop_pkt_6[3]+1;
                   drop_byte_6[3]<=drop_byte_6[3]+qos_byte_6;
                end
                6'b010000:
                begin
                   drop_pkt_6[4]<=drop_pkt_6[4]+1;
                   drop_byte_6[4]<=drop_byte_6[4]+qos_byte_6;
                end 
               6'b100000:
               begin
                  drop_pkt_6[5]<=drop_pkt_6[5]+1;
                  drop_byte_6[5]<=drop_byte_6[5]+qos_byte_6;
               end  
            endcase  
          end

   always@(posedge clk)
          if(reset)
          begin
            transmit_pkt_7[0]<=0;
            transmit_pkt_7[1]<=0;
            transmit_pkt_7[2]<=0;
            transmit_pkt_7[3]<=0;
            transmit_pkt_7[4]<=0;
            
            transmit_byte_7[0]<=0;
            transmit_byte_7[1]<=0;
            transmit_byte_7[2]<=0;
            transmit_byte_7[3]<=0;
            transmit_byte_7[4]<=0;
            
            drop_pkt_7[0]<=0;
            drop_pkt_7[1]<=0;
            drop_pkt_7[2]<=0;
            drop_pkt_7[3]<=0;
            drop_pkt_7[4]<=0;
            
            drop_byte_7[0]<=0;
            drop_byte_7[1]<=0;
            drop_byte_7[2]<=0;
            drop_byte_7[3]<=0;
            drop_byte_7[4]<=0;
          end
          else if(|transmit_vld_7)
          begin
            case(transmit_vld_7)
               6'b000001:
               begin
                  transmit_pkt_7[0]<=transmit_pkt_7[0]+1;
                  transmit_byte_7[0]<=transmit_byte_7[0]+qos_byte_7;
               end
               6'b000010:
               begin
                  transmit_pkt_7[1]<=transmit_pkt_7[1]+1;
                  transmit_byte_7[1]<=transmit_byte_7[1]+qos_byte_7;
               end
               6'b000100:
               begin
                  transmit_pkt_7[2]<=transmit_pkt_7[2]+1;
                  transmit_byte_7[2]<=transmit_byte_7[2]+qos_byte_7;
               end
               6'b001000:
               begin
                  transmit_pkt_7[3]<=transmit_pkt_7[3]+1;
                  transmit_byte_7[3]<=transmit_byte_7[3]+qos_byte_7;
               end
               6'b010000:
               begin
                  transmit_pkt_7[4]<=transmit_pkt_7[4]+1;
                  transmit_byte_7[4]<=transmit_byte_7[4]+qos_byte_7;
               end 
              6'b100000:
              begin
                 transmit_pkt_7[5]<=transmit_pkt_7[5]+1;
                 transmit_byte_7[5]<=transmit_byte_7[5]+qos_byte_7;
              end  
           endcase  
          end
          else if(|drop_vld_7)
          begin
            case(drop_vld_7)
             6'b000001:
                begin
                   drop_pkt_7[0]<=drop_pkt_7[0]+1;
                   drop_byte_7[0]<=drop_byte_7[0]+qos_byte_7;
                end
                6'b000010:
                begin
                   drop_pkt_7[1]<=drop_pkt_7[1]+1;
                   drop_byte_7[1]<=drop_byte_7[1]+qos_byte_7;
                end
                6'b000100:
                begin
                   drop_pkt_7[2]<=drop_pkt_7[2]+1;
                   drop_byte_7[2]<=drop_byte_7[2]+qos_byte_7;
                end
                6'b001000:
                begin
                   drop_pkt_7[3]<=drop_pkt_7[3]+1;
                   drop_byte_7[3]<=drop_byte_7[3]+qos_byte_7;
                end
                6'b010000:
                begin
                   drop_pkt_7[4]<=drop_pkt_7[4]+1;
                   drop_byte_7[4]<=drop_byte_7[4]+qos_byte_7;
                end 
               6'b100000:
               begin
                  drop_pkt_7[5]<=drop_pkt_7[5]+1;
                  drop_byte_7[5]<=drop_byte_7[5]+qos_byte_7;
               end  
            endcase  
          end
                                              
   always@(posedge clk)
       if(reset)
       begin
           queue_weight_0<=1;
           queue_weight_1<=2;
           queue_weight_2<=3;
           queue_weight_3<=4;       
           queue_weight_4<=5;
           queue_weight_5<=6;        
           data_output_queues_o<=32'hdeadbeef;
       end
       else if(req_output_queues_i && rw_output_queues_i==0)
           case(addr_output_queues_i[7:0])
           0:queue_weight_0<=data_output_queues_i;
           4:queue_weight_1<=data_output_queues_i;
           8:queue_weight_2<=data_output_queues_i;
           16:queue_weight_3<=data_output_queues_i;
           20:queue_weight_4<=data_output_queues_i;
           24:queue_weight_5<=data_output_queues_i;
           endcase
       else if(req_output_queues_i && rw_output_queues_i==1)
           case(addr_output_queues_i[7:0])
              0:data_output_queues_o<=queue_weight_0;
              4:data_output_queues_o<=queue_weight_1;
              8:data_output_queues_o<=queue_weight_2;
              12:data_output_queues_o<=queue_weight_3;
              16:data_output_queues_o<=queue_weight_4;
              20:data_output_queues_o<=queue_weight_5;
              `TRANSMIT_PKT_COUNTER_QUEUES: 
              case(addr_output_queues_i[19:16])
                 0:data_output_queues_o<=transmit_pkt_0[addr_output_queues_i[15:8]];
                 1:data_output_queues_o<=transmit_pkt_1[addr_output_queues_i[15:8]];
                 2:data_output_queues_o<=transmit_pkt_2[addr_output_queues_i[15:8]];
                 3:data_output_queues_o<=transmit_pkt_3[addr_output_queues_i[15:8]];
                 4:data_output_queues_o<=transmit_pkt_4[addr_output_queues_i[15:8]];
                 5:data_output_queues_o<=transmit_pkt_5[addr_output_queues_i[15:8]];
                 6:data_output_queues_o<=transmit_pkt_6[addr_output_queues_i[15:8]];
                 7:data_output_queues_o<=transmit_pkt_7[addr_output_queues_i[15:8]];
                 default:data_output_queues_o<=32'hdeadbeef;
              endcase
              `TRANSMIT_BYTE_COUNTER_QUEUES:
               case(addr_output_queues_i[19:16])
                  0:data_output_queues_o<=transmit_byte_0[addr_output_queues_i[15:8]];
                  1:data_output_queues_o<=transmit_byte_1[addr_output_queues_i[15:8]];
                  2:data_output_queues_o<=transmit_byte_2[addr_output_queues_i[15:8]];
                  3:data_output_queues_o<=transmit_byte_3[addr_output_queues_i[15:8]];
                  4:data_output_queues_o<=transmit_byte_4[addr_output_queues_i[15:8]];
                  5:data_output_queues_o<=transmit_byte_5[addr_output_queues_i[15:8]];
                  6:data_output_queues_o<=transmit_byte_6[addr_output_queues_i[15:8]];
                  7:data_output_queues_o<=transmit_byte_7[addr_output_queues_i[15:8]];
                  default:data_output_queues_o<=32'hdeadbeef;
               endcase
               `DROP_PKT_COUNTER_QUEUES:
               case(addr_output_queues_i[19:16])
                  0:data_output_queues_o<=drop_pkt_0[addr_output_queues_i[15:8]];
                  1:data_output_queues_o<=drop_pkt_1[addr_output_queues_i[15:8]];
                  2:data_output_queues_o<=drop_pkt_2[addr_output_queues_i[15:8]];
                  3:data_output_queues_o<=drop_pkt_3[addr_output_queues_i[15:8]];
                  4:data_output_queues_o<=drop_pkt_4[addr_output_queues_i[15:8]];
                  5:data_output_queues_o<=drop_pkt_5[addr_output_queues_i[15:8]];
                  6:data_output_queues_o<=drop_pkt_6[addr_output_queues_i[15:8]];
                  7:data_output_queues_o<=drop_pkt_7[addr_output_queues_i[15:8]];
                  default:data_output_queues_o<=32'hdeadbeef;
               endcase
               `DROP_BYTE_COUNTER_QUEUES:
               case(addr_output_queues_i[19:16])
                  0:data_output_queues_o<=drop_byte_0[addr_output_queues_i[15:8]];
                  1:data_output_queues_o<=drop_byte_1[addr_output_queues_i[15:8]];
                  2:data_output_queues_o<=drop_byte_2[addr_output_queues_i[15:8]];
                  3:data_output_queues_o<=drop_byte_3[addr_output_queues_i[15:8]];
                  4:data_output_queues_o<=drop_byte_4[addr_output_queues_i[15:8]];
                  5:data_output_queues_o<=drop_byte_5[addr_output_queues_i[15:8]];
                  6:data_output_queues_o<=drop_byte_6[addr_output_queues_i[15:8]];
                  7:data_output_queues_o<=drop_byte_7[addr_output_queues_i[15:8]];
                  default:data_output_queues_o<=32'hdeadbeef;
               endcase
               
              default:data_output_queues_o<=32'hdeadbeef;
            endcase
end   
`elsif ONETS20 
begin
always@(posedge clk)
    if(reset)
    begin
        queue_weight_0<=1;
        queue_weight_1<=2;
        queue_weight_2<=3;
        queue_weight_3<=4;       
        queue_weight_4<=5;
        queue_weight_5<=6;        
        data_output_queues_o<=32'hdeadbeef;
    end
    else if(req_output_queues_i && rw_output_queues_i==0)
        case(addr_output_queues_i[7:0])
        0:queue_weight_0<=data_output_queues_i;
        4:queue_weight_1<=data_output_queues_i;
        8:queue_weight_2<=data_output_queues_i;
        16:queue_weight_3<=data_output_queues_i;
        20:queue_weight_4<=data_output_queues_i;
        24:queue_weight_5<=data_output_queues_i;
        endcase
    else if(req_output_queues_i && rw_output_queues_i==1)
        case(addr_output_queues_i[7:0])
           0:data_output_queues_o<=queue_weight_0;
           4:data_output_queues_o<=queue_weight_1;
           8:data_output_queues_o<=queue_weight_2;
           12:data_output_queues_o<=queue_weight_3;
           16:data_output_queues_o<=queue_weight_4;
           20:data_output_queues_o<=queue_weight_5;
           default:data_output_queues_o<=32'hdeadbeef;
         endcase
end   
`endif
          
          always@(posedge clk)
              if(reset)
                  ack_output_queues_o<=0;
              else if(req_output_queues_i && rw_output_queues_i==1)
                  ack_output_queues_o<=1;
              else if(req_output_queues_i && rw_output_queues_i==0)
                  ack_output_queues_o<=1;
              else ack_output_queues_o<=0;
    
endmodule
