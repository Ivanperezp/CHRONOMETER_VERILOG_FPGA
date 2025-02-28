module cronometro_top(
    input wire CLOCK_50,  // 50 MHz clock
    input wire RST,       // Reset button (active low)
    input wire START,     // Start/Stop button (active low)
    output wire [6:0] HEX0, // Hundredths of a second
    output wire [6:0] HEX1, // Tenths of a second
    output wire [6:0] HEX2, // Seconds (units)
    output wire [6:0] HEX3, // Seconds (tens)
    output wire [6:0] HEX4, // Minutes (units)
    output wire [6:0] HEX5  // Minutes (tens)
);

wire slow_clk;
reg running = 0;

// Debounced button signals
wire rst_db, start_db;

debounce db_rst (.clk(CLOCK_50), .btn_in(~RST), .btn_out(rst_db));
debounce db_start (.clk(CLOCK_50), .btn_in(~START), .btn_out(start_db));

// Counter registers
reg [3:0] q_hundredths = 0;
reg [3:0] q_tenths = 0;
reg [3:0] q_seconds = 0;
reg [3:0] q_seconds_tens = 0;
reg [3:0] q_minutes = 0;
reg [3:0] q_minutes_tens = 0;

// Clock divider instance
clk_divider #(.DIVISOR(500000)) div_inst (
    .clk_in(CLOCK_50),
    .clk_out(slow_clk)
);

// Start/Stop logic
always @(posedge CLOCK_50 or posedge rst_db) begin
    if (rst_db)
        running <= 0;
    else if (start_db)
        running <= ~running;
end

// Counting logic
always @(posedge slow_clk or posedge rst_db) begin
    if (rst_db) begin
        q_hundredths <= 0;
        q_tenths <= 0;
        q_seconds <= 0;
        q_seconds_tens <= 0;
        q_minutes <= 0;
        q_minutes_tens <= 0;
    end else if (running) begin
        q_hundredths <= q_hundredths + 1;
        if (q_hundredths == 9) begin
            q_hundredths <= 0;
            q_tenths <= q_tenths + 1;
            if (q_tenths == 9) begin
                q_tenths <= 0;
                q_seconds <= q_seconds + 1;
                if (q_seconds == 9) begin
                    q_seconds <= 0;
                    q_seconds_tens <= q_seconds_tens + 1;
                    if (q_seconds_tens == 5) begin
                        q_seconds_tens <= 0;
                        q_minutes <= q_minutes + 1;
                        if (q_minutes == 9) begin
                            q_minutes <= 0;
                            q_minutes_tens <= q_minutes_tens + 1;
                            if (q_minutes_tens == 5)
                                q_minutes_tens <= 0;
                        end
                    end
                end
            end
        end
    end
end

// BCD to 7-segment display instances
bcd7seg display_hundredths (.bcd(q_hundredths), .seg(HEX0));
bcd7seg display_tenths    (.bcd(q_tenths),    .seg(HEX1));
bcd7seg display_seconds   (.bcd(q_seconds),   .seg(HEX2));
bcd7seg display_seconds_tens (.bcd(q_seconds_tens), .seg(HEX3));
bcd7seg display_minutes    (.bcd(q_minutes),    .seg(HEX4));
bcd7seg display_minutes_tens (.bcd(q_minutes_tens), .seg(HEX5));

endmodule