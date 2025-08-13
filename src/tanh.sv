module tanh (
    input  clk,         // Input clock signal
    input  rst,         // Active-high reset signal
    // Input interface
    input  [13:0] i_x,  // Input value x
    input  i_valid,     // Input value x is valid
    output o_ready,     // Circuit is ready to accept an input
    // Output interface 
    output [13:0] o_fx, // Output result f(x)
    output o_valid,     // Output result f(x) is valid
    input  i_ready      // Downstream circuit is ready to accept an input
);

// Local parameters to define the Taylor coefficients
localparam signed [13:0] A0 = 14'b11101010101011; // a0 = -0.33349609375
localparam signed [13:0] A1 = 14'b00001000100010; // a1 =  0.13330078125
localparam signed [13:0] A2 = 14'b11111100100011; // a2 = -0.05419921875
localparam signed [13:0] A3 = 14'b00000001011001; // a3 =  0.021484375
localparam signed [13:0] A4 = 14'b11111111011100; // a4 = -0.0087890625


/******* Your code starts here *******/                        
                                                                                                 
// Pipeline registers                                                                            
logic signed [13:0] x_1, x_2, x_3, x_4, x_5, x_6, x_7, x_8, x_9, x_10, 
                    x_11, x_12, x_13, x_14, x_15, x_16, x_17, x_18, x_19, x_20, x_21, x_22;                     

logic signed [13:0] x2_1, x2_2, x2_3, x2_4, x2_5, x2_6, x2_7, x2_8, 
                    x2_9, x2_10, x2_11, x2_12, x2_13, x2_14, x2_15, x2_16, x2_17, x2_18;                        

logic signed [13:0] res_1, res_2, res_3, res_4, res_5, res_6, res_7, res_8, res_9, res_10, res_11;                          

logic signed [13:0] r_o, r_x;                                                                    
                                                                                                 
logic r_valid1, r_valid2, r_valid3, r_valid4, r_valid5, r_valid6, r_valid7, r_valid8, r_valid9, r_valid10, r_valid11, 
      r_valid12, r_valid13, r_valid14, r_valid15, r_valid16, r_valid17, r_valid18, r_valid19, r_valid20, r_valid21, r_valid22;                              

logic r_o_valid, r_i_valid;                                                                      
                                                                                                 
logic signed [27:0] temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8, temp9, temp10, temp11;                                                                        
                                                                                                 
always_ff @(posedge clk) begin                                                                   
    if (rst) begin                                                                               
        x_1 <= 0; x_2 <= 0; x_3 <= 0; x_4 <= 0; x_5 <= 0;                                        
        x_6 <= 0; x_7 <= 0; x_8 <= 0; x_9 <= 0; x_10 <= 0; x_11 <= 0;                            
                                                                                                 
        x2_1 <= 0; x2_2 <= 0; x2_3 <= 0; x2_4 <= 0; x2_5 <= 0;                                   
        x2_6 <= 0; x2_7 <= 0; x2_8 <= 0; x2_9 <= 0;                                              
                                                                                                 
        res_1 <= 0; res_2 <= 0; res_3 <= 0; res_4 <= 0; res_5 <= 0;                              
        res_6 <= 0; res_7 <= 0; res_8 <= 0; res_9 <= 0; res_10 <= 0; res_11 <= 0;                
                                                                                                 
        r_valid1 <= 0; r_valid2 <= 0; r_valid3 <= 0; r_valid4 <= 0; r_valid5 <= 0;               
        r_valid6 <= 0; r_valid7 <= 0; r_valid8 <= 0; r_valid9 <= 0; r_valid10 <= 0; r_valid11 <= 
                                                                                                 
        r_o <= 0;                                                                                
        r_o_valid <= 0;                                                                          
    end else if (i_ready) begin                                                                  
        // Stage 0
        r_i_valid <= i_valid;
        r_x <= i_x;
        
        // Stage 1
        r_valid1 <= r_i_valid;
        x_1 <= r_x;
        temp1 <= r_x * r_x;
        
        // Stage 2
        r_valid2 <= r_valid1;
        x_2 <= x_1;
        x2_2 <= temp1[25:12];
        res_1 <= temp1[25:12];
        
        // Stage 3
        r_valid3 <= r_valid2;
        x_3 <= x_2;
        temp2 <= A4 * res_1;
        x2_3 <= x2_2;
        
        // Stage 4
        r_valid4 <= r_valid3;
        x_4 <= x_3;
        res_2 <= temp2[25:12];
        x2_4 <= x2_3;
        
        // Stage 5
        r_valid5 <= r_valid4;
        x_5 <= x_4;
        temp3 <= res_2 + A3;
        x2_5 <= x2_4;
        
        // Stage 6
        r_valid6 <= r_valid5;
        x_6 <= x_5;
        res_3 <= temp3;
        x2_6 <= x2_5;
        
        // Stage 7
        r_valid7 <= r_valid6;
        x_7 <= x_6;
        temp4 <= res_3 * x2_6;
        x2_7 <= x2_6;
        
        // Stage 8
        r_valid8 <= r_valid7;
        x_8 <= x_7;
        res_4 <= temp4[25:12];
        x2_8 <= x2_7;
        
        // Stage 9
        r_valid9 <= r_valid8;
        x_9 <= x_8;
        temp5 <= A2 + res_4;
        x2_9 <= x2_8;
        
        // Stage 10
        r_valid10 <= r_valid9;
        x_10 <= x_9;
        res_5 <= temp5;
        x2_10 <= x2_9;
        
        // Stage 11
        r_valid11 <= r_valid10;
        x_11 <= x_10;
        temp6 <= res_5 * x2_10;
        x2_11 <= x2_10;
        
        // Stage 12
        r_valid12 <= r_valid11;
        x_12 <= x_11;
        res_6 <= temp6[25:12];
        x2_12 <= x2_11;
        
        // Stage 13
        r_valid13 <= r_valid12;
        x_13 <= x_12;
        temp7 <= A1 + res_6;
        x2_13 <= x2_12;
        
        // Stage 14
        r_valid14 <= r_valid13;
        x_14 <= x_13;
        res_7 <= temp7;
        x2_14 <= x2_13;
        
        // Stage 15
        r_valid15 <= r_valid14;
        x_15 <= x_14;
        temp8 <= res_7 * x2_14;
        x2_15 <= x2_14;
        
        // Stage 16
        r_valid16 <= r_valid15;
        x_16 <= x_15;
        res_8 <= temp8[25:12];
        x2_16 <= x2_15;
        
        // Stage 17
        r_valid17 <= r_valid16;
        x_17 <= x_16;
        temp9 <= A0 + res_8;
        x2_17 <= x2_16;
        
        // Stage 18
        r_valid18 <= r_valid17;
        x_18 <= x_17;
        res_9 <= temp9;
        x2_18 <= x2_17;
        
        // Stage 19
        r_valid19 <= r_valid18;
        x_19 <= x_18;
        temp10 <= res_9 * x2_18;
        
        // Stage 20
        r_valid20 <= r_valid19;
        x_20 <= x_19;
        res_10 <= temp10[25:12];
        
        // Stage 21
        r_valid21 <= r_valid20;
        x_21 <= x_20;
        temp11 <= res_10 * x_20;
        
        // Stage 22
        r_valid22 <= r_valid21;
        x_22 <= x_21;
        res_11 <= temp11[25:12];
        
        // Stage 23
        r_o_valid <= r_valid22;
        r_o <= res_11 + x_22;                                                         
    end                                                                                          
end                                                                                              

          // horner's rule: ((((A4*x^2 + A3)*x^2 + A2)*x^2 + A1)*x^2 + A0)
//        h = A4;
//        temp = h * x2;         
//        h= (temp >>> 12) + A3;
//        temp = h * x2;          
//        h = (temp >>> 12) + A2;
//        temp = h * x2;          
//        h = (temp >>> 12) + A1;
//        temp = h * x2;          
//        h = (temp >>> 12) + A0;

//        temp = x2 * h;
//        temp = (temp >>> 12) * x;
//        r_o <= x + (temp >>> 12);
//        r_o_valid <= r_i_valid;

assign o_ready = i_ready;
assign o_valid = r_o_valid;
assign o_fx = r_o;

/******* Your code ends here ********/


endmodule

