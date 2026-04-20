module slt (
    input wire [31:0] a,
    input wire [31:0] b, 
    output reg [31:0] result  
);
    wire [31:0] diff;
    wire c_out;
    wire is_a_neg, is_b_neg, diff_sign;


    subtractor subtractor_unit (
        .a(a),
        .b(b),
        .c_in(1'b1),
        .sub(diff),
        .c_out(c_out)
    );

    assign is_a_neg = a[31];
    assign is_b_neg = b[31];
    assign diff_sign = diff[31];

    always @(*) begin
        if (is_a_neg != is_b_neg) begin

            result = {31'b0,is_a_neg};

        end else begin

            result = {31'b0,diff_sign};
        end
    end

endmodule

