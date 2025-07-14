module receiver (
    input clk,
    input rst,
    input rx,              // Serial bitstream input
    output reg [3:0] data, // Received 4-bit data
    output reg done        // Done pulse when valid byte received
);

    // State encoding using parameters (Verilog style)
    parameter IDLE      = 3'd0,
              RECEIVE   = 3'd1,
              WAIT_STOP = 3'd2,
              DONE      = 3'd3,
              ERROR     = 3'd4;

    reg [2:0] state, next_state;

    reg [2:0] bit_cnt;
    reg [3:0] shift_reg;

    // Sequential logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state      <= IDLE;
            bit_cnt    <= 3'd0;
            shift_reg  <= 4'd0;
            data       <= 4'd0;
            done       <= 1'b0;
        end else begin
            state <= next_state;

            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (rx == 1'b0) begin  // Start bit detected
                        bit_cnt   <= 3'd0;
                        shift_reg <= 4'd0;
                    end
                end

                RECEIVE: begin
                    shift_reg <= {rx, shift_reg[3:1]};
                    bit_cnt   <= bit_cnt + 1;
                end

                WAIT_STOP: begin
                    if (rx == 1'b1) begin
                        data <= shift_reg;
                        done <= 1'b1;
                    end
                end

                DONE: begin
                    done <= 1'b0;
                end

                ERROR: begin
                    done <= 1'b0;
                end
            endcase
        end
    end

    // Combinational next-state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE:
                next_state = (rx == 1'b0) ? RECEIVE : IDLE;

            RECEIVE:
                next_state = (bit_cnt == 3'd3) ? WAIT_STOP : RECEIVE;

            WAIT_STOP:
                next_state = (rx == 1'b1) ? DONE : ERROR;

            DONE:
                next_state = IDLE;

            ERROR:
                next_state = (rx == 1'b1) ? IDLE : ERROR;
        endcase
    end

endmodule
