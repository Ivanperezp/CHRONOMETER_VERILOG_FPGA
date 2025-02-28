module debounce(
    input wire clk,
    input wire btn_in,
    output reg btn_out  
);

    reg [19:0] count = 0;
    reg stable_state = 1'b1;

    always @(posedge clk) begin
        if (btn_in != stable_state) begin
            count <= count + 1;
            if (count == 20'hFFFFF) begin
                stable_state <= btn_in;
                count <= 0;
            end
        end else
            count <= 0;

        btn_out <= stable_state;
    end

endmodule
