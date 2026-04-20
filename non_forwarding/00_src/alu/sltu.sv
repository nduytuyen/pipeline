
module sltu (
    input wire [31:0] a,    // Toán hạng đầu vào a
    input wire [31:0] b,    // Toán hạng đầu vào b
    output reg [31:0] result  // Kết quả so sánh: 1 nếu a < b, ngược lại 0
);

    wire [31:0] diff;
    wire c_out;

    // a - b
    subtractor subtractor_unit (
        .a(a),
        .b(b),
        .c_in(1'b1),
        .sub(diff),
        .c_out(c_out)
    );

    always @(*) begin
        // Nếu cout = 0, thì a < b không dấu, ngược lại a >= b
        result = {31'b0,~c_out};
    end
endmodule

