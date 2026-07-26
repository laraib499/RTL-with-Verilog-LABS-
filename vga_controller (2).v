module vga_controller (
    input wire clk,
    input wire rst_n,
    input wire [11:0] data_in,
    output wire hsync,
    output wire vsync,
    output wire [11:0] rgb_out,
    output wire [18:0] sram_addr,
    output wire sram_ce,
    output wire sram_we,
    output wire sram_oe
);

    parameter H_FRONT = 16;
    parameter H_SYNC = 80;
    parameter H_BACK = 88;
    parameter H_ACTIVE = 800;
    parameter H_TOTAL = 1040;

    parameter V_FRONT = 1;
    parameter V_SYNC = 3;
    parameter V_BACK = 21;
    parameter V_ACTIVE = 600;
    parameter V_TOTAL = 625;

    reg [10:0] h_count;
    reg [10:0] v_count;
    wire h_active, v_active;
    wire h_sync_signal, v_sync_signal;

    reg [18:0] addr_count;

    reg [11:0] rgb_reg;

    initial begin
        h_count = 11'b0;
        v_count = 11'b0;
        addr_count = 19'b0;
        rgb_reg = 12'b0;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            h_count <= 11'b0;
        end else begin
            if (h_count == H_TOTAL - 1)
                h_count <= 11'b0;
            else
                h_count <= h_count + 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            v_count <= 11'b0;
        end else begin
            if (h_count == H_TOTAL - 1) begin
                if (v_count == V_TOTAL - 1)
                    v_count <= 11'b0;
                else
                    v_count <= v_count + 1'b1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            addr_count <= 19'b0;
        end else begin
            if (h_active && v_active) begin
                if (h_count >= H_BACK && h_count < H_BACK + H_ACTIVE)
                    addr_count <= addr_count + 1'b1;
            end else if (h_count == H_TOTAL - 1 && v_count == V_TOTAL - 1) begin
                addr_count <= 19'b0;
            end
        end
    end

    assign h_active = (h_count >= H_BACK && h_count < H_BACK + H_ACTIVE);

    assign v_active = (v_count >= V_BACK && v_count < V_BACK + V_ACTIVE);

    assign h_sync_signal = (h_count >= H_BACK + H_ACTIVE + H_FRONT &&
                           h_count < H_BACK + H_ACTIVE + H_FRONT + H_SYNC);

    assign v_sync_signal = (v_count >= V_BACK + V_ACTIVE + V_FRONT &&
                           v_count < V_BACK + V_ACTIVE + V_FRONT + V_SYNC);

    assign sram_ce = 1'b0;
    assign sram_we = 1'b1;
    assign sram_oe = h_active && v_active ? 1'b0 : 1'b1;

    assign sram_addr = addr_count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rgb_reg <= 12'b0;
        end else if (h_active && v_active) begin
            rgb_reg <= data_in;
        end else begin
            rgb_reg <= 12'b0;
        end
    end

    assign hsync = h_sync_signal;
    assign vsync = v_sync_signal;
    assign rgb_out = rgb_reg;

endmodule

