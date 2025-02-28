module clk_divider #(parameter DIVISOR = 50000000) (
    input clk_in,
    output reg clk_out = 0
);
    reg [31:0] counter = 0;
    
    always @(posedge clk_in) begin
        if(counter == DIVISOR/2 - 1) begin
            clk_out <= ~clk_out;
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule