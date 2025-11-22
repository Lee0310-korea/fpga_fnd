`timescale 1ns / 1ps



module butten_debounce (
    input  clk,
    input  rst,
    input  i_btn,
    output o_btn
);

    reg [$clog2(100)-1:0] counter_reg;
    reg clk_reg;
    reg [7:0] q_reg, q_next;
    reg  edge_reg;
    wire debouce;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            clk_reg <= 1'b0;
        end else begin
            if (counter_reg == 100 - 1) begin
                counter_reg <= 0;
                clk_reg <= 1'b1;
            end else begin
                counter_reg <= counter_reg + 1;
                clk_reg <= 1'b0;
            end
        end
    end

    always @(posedge clk_reg, posedge rst) begin
        if (rst) begin
            q_reg <= 0;
        end else begin
            q_reg <= q_next;
        end
    end

    always @(*) begin
        q_next = {i_btn, q_reg[7:1]};
    end

    assign debouce = &q_reg;  //4input AND

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            edge_reg <= 1'b0;
        end else begin
            edge_reg <= debouce;
        end
    end

    assign o_btn = ~edge_reg & debouce;

endmodule
