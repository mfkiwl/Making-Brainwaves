module ctrl # (
    parameter VEC_ADDRW = 8,
    parameter MAT_ADDRW = 9,
    parameter VEC_SIZEW = VEC_ADDRW + 1,
    parameter MAT_SIZEW = MAT_ADDRW + 1
)(
    input  clk,
    input  rst,
    input  start,
    input  [VEC_ADDRW-1:0] vec_start_addr,
    input  [VEC_SIZEW-1:0] vec_num_words,
    input  [MAT_ADDRW-1:0] mat_start_addr,
    input  [MAT_SIZEW-1:0] mat_num_rows_per_olane,
    output [VEC_ADDRW-1:0] vec_raddr,
    output [MAT_ADDRW-1:0] mat_raddr,
    output accum_first,
    output accum_last,
    output ovalid,
    output busy
);

enum {IDLE, COMPUTE} state, next_state;

logic [VEC_ADDRW-1:0] vec_start_addr_r, vec_raddr_r;
logic [VEC_SIZEW-1:0] vec_num_words_r;
logic [MAT_ADDRW-1:0] mat_start_addr_r, mat_raddr_r;
logic [MAT_SIZEW-1:0] mat_num_rows_per_olane_r;

logic [VEC_SIZEW-1:0] vec_word_count;
logic [MAT_SIZEW-1:0] mat_row_count;

logic ovalid_r, busy_r;

logic accum_first_r [6:0];
logic accum_last_r [6:0];

logic done;

// Output decoder signals
logic [VEC_ADDRW-1:0] vec_raddr_w;
logic [MAT_ADDRW-1:0] mat_raddr_w;
logic ovalid_w, busy_w;

always_ff @(posedge clk) begin
    if (rst) begin
        vec_start_addr_r <= 0;
        vec_num_words_r <= 0;
        mat_start_addr_r <= 0;
        mat_num_rows_per_olane_r <= 0;

        vec_word_count <= 0;
        mat_row_count <= 0;

        ovalid_r <= 0;
        busy_r <= 0;
        done <= 0;

        for (int i = 0; i < 7; i++) begin
            accum_first_r[i] <= 0;
            accum_last_r[i] <= 0;
        end

        vec_raddr_r <= 0;
        mat_raddr_r <= 0;

        state <= IDLE;
    end else begin
        state <= next_state;

        if (state == IDLE && start) begin
            vec_start_addr_r <= vec_start_addr;
            mat_start_addr_r <= mat_start_addr;
            vec_num_words_r <= vec_num_words;
            mat_num_rows_per_olane_r <= mat_num_rows_per_olane;

            vec_word_count <= 0;
            mat_row_count <= 0;
        end else if (state == COMPUTE) begin
            if (vec_word_count == vec_num_words_r - 1) begin
                vec_word_count <= 0;
                if (mat_row_count == mat_num_rows_per_olane_r - 1)
                    mat_row_count <= 0;
                else
                    mat_row_count <= mat_row_count + 1;
            end else begin
                vec_word_count <= vec_word_count + 1;
            end
        end

        done <= (state == COMPUTE && vec_word_count == vec_num_words_r - 1 && mat_row_count == mat_num_rows_per_olane_r - 1);

        vec_raddr_r <= vec_raddr_w;
        mat_raddr_r <= mat_raddr_w;
        ovalid_r    <= ovalid_w;
        busy_r      <= busy_w;

        accum_first_r[0] <= (vec_word_count == 0);
        accum_last_r[0]  <= (vec_word_count == vec_num_words_r - 1);

        for (int i = 1; i < 7; i++) begin
            accum_first_r[i] <= accum_first_r[i-1];
            accum_last_r[i]  <= accum_last_r[i-1];
        end
    end
end

always_comb begin : state_decoder
    case(state)
        IDLE:    next_state = start ? COMPUTE : IDLE;
        COMPUTE: next_state = done ? IDLE : COMPUTE;
        default: next_state = IDLE;
    endcase
end

always_comb begin : output_decoder
    vec_raddr_w = vec_start_addr_r + vec_word_count;
    mat_raddr_w = mat_start_addr_r + mat_row_count * vec_num_words_r + vec_word_count;
    ovalid_w = (state == COMPUTE);
    busy_w   = (state == COMPUTE);
end

assign vec_raddr = vec_raddr_r;
assign mat_raddr = mat_raddr_r;
assign accum_first = accum_first_r[6];
assign accum_last = accum_last_r[6];
assign ovalid = ovalid_r;
assign busy = busy_r;

endmodule
