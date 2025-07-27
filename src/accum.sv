/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 4                                           */
/* Accumulator Module                              */
/***************************************************/

module accum # (
    parameter DATAW = 19,
    parameter ACCUMW = 32
)(
    input  clk,
    input  rst,
    input  signed [DATAW-1:0] data,
    input  ivalid,
    input  first,
    input  last,
    output signed [ACCUMW-1:0] result,
    output ovalid
);

/******* Your code starts here *******/
logic signed [ACCUMW-1:0] r_accum;
logic r_ovalid;

always_ff @(posedge clk) begin
    if (rst) begin
        r_accum <= 0;
        r_ovalid <= 0;
    end else begin
        if (ivalid == 1) begin
            r_accum <= first  ? data: r_accum + data;
            r_ovalid <= last;
        end
    end
end
    
assign result = r_accum;
assign ovalid = r_ovalid;

/******* Your code ends here ********/

endmodule
