`timescale 1ns / 1ps

module uart_top (
    input        clk,
    input        rst,
    input        rx,
    output       tx,
    output [7:0] o_rx_data,
    output       rx_trigger
);
    wire w_b_tick;
    wire w_btn;
    wire rx_done;
    wire [7:0] w_rx_data, w_rx_fifo_pop, w_tx_fifo_pop_data;
    wire w_rx_empty, w_tx_fifo_full, w_tx_fifo_empty, w_tx_busy;

    assign o_rx_data  = w_rx_fifo_pop;
    assign rx_trigger = w_rx_empty;

    FIFO U_rx_fifo (
        .clk      (clk),
        .rst      (rst),
        .push_data(w_rx_data),
        .push     (rx_done),
        .pop      (~w_tx_fifo_full),
        .pop_data (w_rx_fifo_pop),
        .full     (),
        .empty    (w_rx_empty)
    );

    FIFO U_tx_fifo (
        .clk      (clk),
        .rst      (rst),
        .push_data(w_rx_fifo_pop),
        .push     (~w_rx_empty),
        .pop      (~w_tx_busy),
        .pop_data (w_tx_fifo_pop_data),
        .full     (w_tx_fifo_full),
        .empty    (w_tx_fifo_empty)
    );

    baud_tick_gen U_baud_tick_gen (
        .clk   (clk),
        .rst   (rst),
        .b_tick(w_b_tick)
    );

    uart_tx U_uart_tx (
        .clk          (clk),
        .rst          (rst),
        .start_trigger(~w_tx_fifo_empty),
        .tx_data      (w_tx_fifo_pop_data),
        .b_tick       (w_b_tick),
        .tx           (tx),
        .tx_busy      (w_tx_busy)
    );

    uart_rx U_uart_rx (
        .clk    (clk),
        .rst    (rst),
        .rx     (rx),
        .b_tick (w_b_tick),
        .rx_data(w_rx_data),
        .rx_done(rx_done)
    );


endmodule

module baud_tick_gen (
    input  clk,
    input  rst,
    output b_tick
);
    parameter BAUDRATE = 9600*16;  //baudrate => 샘플링 갯수를 늘려 오차를 줄이기 위해
    localparam BAUD_COUNT = 100_000_000 / BAUDRATE;

    reg [$clog2(BAUD_COUNT)-1:0] counter_reg, counter_next;
    reg tick_reg, tick_next;

    assign b_tick = tick_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            tick_reg <= 1'b0;
        end else begin
            counter_reg <= counter_next;
            tick_reg <= tick_next;
        end
    end

    always @(*) begin
        counter_next = counter_reg;
        tick_next = tick_reg;
        if (counter_reg == BAUD_COUNT - 1) begin
            tick_next = 1'b1;
            counter_next = 0;
        end else begin
            counter_next = counter_reg + 1;
            tick_next = 1'b0;
        end
    end
endmodule
