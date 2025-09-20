module sqrt
(
    input  wire                 sys_clk     ,
    input  wire                 sys_rst     ,
    input  wire     [20:0]      din         ,
    input  wire                 din_valid   ,
    output wire     [10:0]      dout        ,
    output wire                 dout_valid
);
//----------------------------------------------------------------------
//  c1
reg             [22:0]          data_c1;

always @(posedge sys_clk)
begin
    data_c1 <= {din,2'b0};
end

wire            [23:0]          mult_c1;
assign mult_c1 = 12'b1000_0000_0000 * 12'b1000_0000_0000;

reg                             bit10_c1;

always @(posedge sys_clk)
begin
    if(mult_c1 <= {din,2'b0})
        bit10_c1 <= 1'b1;
    else
        bit10_c1 <= 1'b0;
end

reg                             data_valid_c1;

always @(posedge sys_clk)
begin
    if(sys_rst == 1'b1)
        data_valid_c1 <= 1'b0;
    else
        data_valid_c1 <= din_valid;
end

//----------------------------------------------------------------------
//  c2
reg             [22:0]          data_c2;
reg                             bit10_c2;

always @(posedge sys_clk)
begin
    data_c2  <= data_c1;
    bit10_c2 <= bit10_c1;
end

wire            [23:0]          mult_c2;
assign mult_c2 = {bit10_c1,11'b100_0000_0000} * {bit10_c1,11'b100_0000_0000};

reg                             bit9_c2;

always @(posedge sys_clk)
begin
    if(mult_c2 <= data_c1)
        bit9_c2 <= 1'b1;
    else
        bit9_c2 <= 1'b0;
end

reg                             data_valid_c2;

always @(posedge sys_clk)
begin
    if(sys_rst == 1'b1)
        data_valid_c2 <= 1'b0;
    else
        data_valid_c2 <= data_valid_c1;
end

//----------------------------------------------------------------------
//  c3
reg             [22:0]          data_c3;
reg                             bit10_c3;
reg                             bit9_c3;

always @(posedge sys_clk)
begin
    data_c3  <= data_c2;
    bit10_c3 <= bit10_c2;
    bit9_c3  <= bit9_c2;
end

wire            [23:0]          mult_c3;
assign mult_c3 = {bit10_c2,bit9_c2,10'b10_0000_0000} * {bit10_c2,bit9_c2,10'b10_0000_0000};

reg                             bit8_c3;

always @(posedge sys_clk)
begin
    if(mult_c3 <= data_c2)
        bit8_c3 <= 1'b1;
    else
        bit8_c3 <= 1'b0;
end

reg                             data_valid_c3;

always @(posedge sys_clk)
begin
    if(sys_rst == 1'b1)
        data_valid_c3 <= 1'b0;
    else
        data_valid_c3 <= data_valid_c2;
end

//----------------------------------------------------------------------
//  c4
reg             [22:0]          data_c4;
reg                             bit10_c4;
reg                             bit9_c4;
reg                             bit8_c4;

always @(posedge sys_clk)
begin
    data_c4  <= data_c3;
    bit10_c4 <= bit10_c3;
    bit9_c4  <= bit9_c3;
    bit8_c4  <= bit8_c3;
end

wire            [23:0]          mult_c4;
assign mult_c4 = {bit10_c3,bit9_c3,bit8_c3,9'b1_0000_0000} * {bit10_c3,bit9_c3,bit8_c3,9'b1_0000_0000};

reg                             bit7_c4;

always @(posedge sys_clk)
begin
    if(mult_c4 <= data_c3)
        bit7_c4 <= 1'b1;
    else
        bit7_c4 <= 1'b0;
end

reg                             data_valid_c4;

always @(posedge sys_clk)
begin
    if(sys_rst == 1'b1)
        data_valid_c4 <= 1'b0;
    else
        data_valid_c4 <= data_valid_c3;
end

//----------------------------------------------------------------------
//  c5
reg             [22:0]          data_c5;
reg                             bit10_c5;
reg                             bit9_c5;
reg                             bit8_c5;
reg                             bit7_c5;

always @(posedge sys_clk)
begin
    data_c5  <= data_c4;

    bit10_c5 <= bit10_c4;
    bit9_c5  <= bit9_c4;
    bit8_c5  <= bit8_c4;
    bit7_c5  <= bit7_c4;
end

wire            [23:0]          mult_c5;
assign mult_c5 = {bit10_c4,bit9_c4,bit8_c4,bit7_c4,8'b1000_0000} * {bit10_c4,bit9_c4,bit8_c4,bit7_c4,8'b1000_0000};

reg                             bit6_c5;

always @(posedge sys_clk)
begin
    if(mult_c5 <= data_c4)
        bit6_c5 <= 1'b1;
    else
        bit6_c5 <= 1'b0;
end

reg                             data_valid_c5;

always @(posedge sys_clk)
begin
    if(sys_rst == 1'b1)
        data_valid_c5 <= 1'b0;
    else
        data_valid_c5 <= data_valid_c4;
end

//----------------------------------------------------------------------
//  c6
reg             [22:0]          data_c6;
reg                             bit10_c6;
reg                             bit9_c6;
reg                             bit8_c6;
reg                             bit7_c6;
reg                             bit6_c6;

always @(posedge sys_clk)
begin
    data_c6  <= data_c5;
    bit10_c6 <= bit10_c5;
    bit9_c6  <= bit9_c5;
    bit8_c6  <= bit8_c5;
    bit7_c6  <= bit7_c5;
    bit6_c6  <= bit6_c5;
end

wire            [23:0]          mult_c6;
assign mult_c6 = {bit10_c5,bit9_c5,bit8_c5,bit7_c5,bit6_c5,7'b100_0000} * {bit10_c5,bit9_c5,bit8_c5,bit7_c5,bit6_c5,7'b100_0000};

reg                             bit5_c6;

always @(posedge sys_clk)
begin
    if(mult_c6 <= data_c5)
        bit5_c6 <= 1'b1;
    else
        bit5_c6 <= 1'b0;
end

reg                             data_valid_c6;

always @(posedge sys_clk)
begin
    if(sys_rst == 1'b1)
        data_valid_c6 <= 1'b0;
    else
        data_valid_c6 <= data_valid_c5;
end

//----------------------------------------------------------------------
//  c7
reg             [22:0]          data_c7;
reg                             bit10_c7;
reg                             bit9_c7;
reg                             bit8_c7;
reg                             bit7_c7;
reg                             bit6_c7;
reg                             bit5_c7;

always @(posedge sys_clk)
begin
    data_c7  <= data_c6;
    bit10_c7 <= bit10_c6;
    bit9_c7  <= bit9_c6;
    bit8_c7  <= bit8_c6;
    bit7_c7  <= bit7_c6;
    bit6_c7  <= bit6_c6;
    bit5_c7  <= bit5_c6;
end

wire            [23:0]          mult_c7;
assign mult_c7 = {bit10_c6,bit9_c6,bit8_c6,bit7_c6,bit6_c6,bit5_c6,6'b10_0000} * {bit10_c6,bit9_c6,bit8_c6,bit7_c6,bit6_c6,bit5_c6,6'b10_0000};

reg                             bit4_c7;

always @(posedge sys_clk)
begin
    if(mult_c7 <= data_c6)
        bit4_c7 <= 1'b1;
    else
        bit4_c7 <= 1'b0;
end

reg                             data_valid_c7;

always @(posedge sys_clk)
begin
    if(sys_rst == 1'b1)
        data_valid_c7 <= 1'b0;
    else
        data_valid_c7 <= data_valid_c6;
end

//----------------------------------------------------------------------
//  c8
reg             [22:0]          data_c8;
reg                             bit10_c8;
reg                             bit9_c8;
reg                             bit8_c8;
reg                             bit7_c8;
reg                             bit6_c8;
reg                             bit5_c8;
reg                             bit4_c8;

always @(posedge sys_clk)
begin
    data_c8  <= data_c7;
    bit10_c8 <= bit10_c7;
    bit9_c8  <= bit9_c7;
    bit8_c8  <= bit8_c7;
    bit7_c8  <= bit7_c7;
    bit6_c8  <= bit6_c7;
    bit5_c8  <= bit5_c7;
    bit4_c8  <= bit4_c7;
end

wire            [23:0]          mult_c8;
assign mult_c8 = {bit10_c7,bit9_c7,bit8_c7,bit7_c7,bit6_c7,bit5_c7,bit4_c7,5'b1_0000} * {bit10_c7,bit9_c7,bit8_c7,bit7_c7,bit6_c7,bit5_c7,bit4_c7,5'b1_0000};

reg                             bit3_c8;

always @(posedge sys_clk)
begin
    if(mult_c8 <= data_c7)
        bit3_c8 <= 1'b1;
    else
        bit3_c8 <= 1'b0;
end

reg                             data_valid_c8;

always @(posedge sys_clk)
begin
    if(sys_rst == 1'b1)
        data_valid_c8 <= 1'b0;
    else
        data_valid_c8 <= data_valid_c7;
end

//----------------------------------------------------------------------
//  c9
reg             [22:0]          data_c9;
reg                             bit10_c9;
reg                             bit9_c9;
reg                             bit8_c9;
reg                             bit7_c9;
reg                             bit6_c9;
reg                             bit5_c9;
reg                             bit4_c9;
reg                             bit3_c9;

always @(posedge sys_clk)
begin
    data_c9  <= data_c8;
    bit10_c9 <= bit10_c8;
    bit9_c9  <= bit9_c8;
    bit8_c9  <= bit8_c8;
    bit7_c9  <= bit7_c8;
    bit6_c9  <= bit6_c8;
    bit5_c9  <= bit5_c8;
    bit4_c9  <= bit4_c8;
    bit3_c9  <= bit3_c8;
end

wire            [23:0]          mult_c9;
assign mult_c9 = {bit10_c8,bit9_c8,bit8_c8,bit7_c8,bit6_c8,bit5_c8,bit4_c8,bit3_c8,4'b1000} * {bit10_c8,bit9_c8,bit8_c8,bit7_c8,bit6_c8,bit5_c8,bit4_c8,bit3_c8,4'b1000};

reg                             bit2_c9;

always @(posedge sys_clk)
begin
    if(mult_c9 <= data_c8)
        bit2_c9 <= 1'b1;
    else
        bit2_c9 <= 1'b0;
end

reg                             data_valid_c9;

always @(posedge sys_clk)
begin
    if(sys_rst == 1'b1)
        data_valid_c9 <= 1'b0;
    else
        data_valid_c9 <= data_valid_c8;
end

//----------------------------------------------------------------------
//  c10
reg             [22:0]          data_c10;
reg                             bit10_c10;
reg                             bit9_c10;
reg                             bit8_c10;
reg                             bit7_c10;
reg                             bit6_c10;
reg                             bit5_c10;
reg                             bit4_c10;
reg                             bit3_c10;
reg                             bit2_c10;

always @(posedge sys_clk)
begin
    data_c10  <= data_c9;
    bit10_c10 <= bit10_c9;
    bit9_c10  <= bit9_c9;
    bit8_c10  <= bit8_c9;
    bit7_c10  <= bit7_c9;
    bit6_c10  <= bit6_c9;
    bit5_c10  <= bit5_c9;
    bit4_c10  <= bit4_c9;
    bit3_c10  <= bit3_c9;
    bit2_c10  <= bit2_c9;
end

wire            [23:0]          mult_c10;
assign mult_c10 = {bit10_c9,bit9_c9,bit8_c9,bit7_c9,bit6_c9,bit5_c9,bit4_c9,bit3_c9,bit2_c9,3'b100} * {bit10_c9,bit9_c9,bit8_c9,bit7_c9,bit6_c9,bit5_c9,bit4_c9,bit3_c9,bit2_c9,3'b100};

reg                             bit1_c10;

always @(posedge sys_clk)
begin
    if(mult_c10 <= data_c9)
        bit1_c10 <= 1'b1;
    else
        bit1_c10 <= 1'b0;
end

reg                             data_valid_c10;

always @(posedge sys_clk)
begin
    if(sys_rst == 1'b1)
        data_valid_c10 <= 1'b0;
    else
        data_valid_c10 <= data_valid_c9;
end

//----------------------------------------------------------------------
//  c11
reg             [22:0]          data_c11;
reg                             bit10_c11;
reg                             bit9_c11;
reg                             bit8_c11;
reg                             bit7_c11;
reg                             bit6_c11;
reg                             bit5_c11;
reg                             bit4_c11;
reg                             bit3_c11;
reg                             bit2_c11;
reg                             bit1_c11;

always @(posedge sys_clk)
begin
    data_c11  <= data_c10;
    bit10_c11 <= bit10_c10;
    bit9_c11  <= bit9_c10;
    bit8_c11  <= bit8_c10;
    bit7_c11  <= bit7_c10;
    bit6_c11  <= bit6_c10;
    bit5_c11  <= bit5_c10;
    bit4_c11  <= bit4_c10;
    bit3_c11  <= bit3_c10;
    bit2_c11  <= bit2_c10;
    bit1_c11  <= bit1_c10;
end

wire            [23:0]          mult_c11;
assign mult_c11 = {bit10_c10,bit9_c10,bit8_c10,bit7_c10,bit6_c10,bit5_c10,bit4_c10,bit3_c10,bit2_c10,bit1_c10,2'b10} * {bit10_c10,bit9_c10,bit8_c10,bit7_c10,bit6_c10,bit5_c10,bit4_c10,bit3_c10,bit2_c10,bit1_c10,2'b10};

reg                             bit0_c11;

always @(posedge sys_clk)
begin
    if(mult_c11 <= data_c10)
        bit0_c11 <= 1'b1;
    else
        bit0_c11 <= 1'b0;
end

reg                             data_valid_c11;

always @(posedge sys_clk)
begin
    if(sys_rst == 1'b1)
        data_valid_c11 <= 1'b0;
    else
        data_valid_c11 <= data_valid_c10;
end

//----------------------------------------------------------------------
//  c12
wire            [23:0]          mult_c12;
assign mult_c12 = {bit10_c11,bit9_c11,bit8_c11,bit7_c11,bit6_c11,bit5_c11,bit4_c11,bit3_c11,bit2_c11,bit1_c11,bit0_c11,1'b1} * {bit10_c11,bit9_c11,bit8_c11,bit7_c11,bit6_c11,bit5_c11,bit4_c11,bit3_c11,bit2_c11,bit1_c11,bit0_c11,1'b1};

reg             [10:0]          result_c12;

always @(posedge sys_clk)
begin
    if(mult_c12 <= data_c11)
        result_c12 <= {bit10_c11,bit9_c11,bit8_c11,bit7_c11,bit6_c11,bit5_c11,bit4_c11,bit3_c11,bit2_c11,bit1_c11,bit0_c11} + 1'b1;
    else
        result_c12 <= {bit10_c11,bit9_c11,bit8_c11,bit7_c11,bit6_c11,bit5_c11,bit4_c11,bit3_c11,bit2_c11,bit1_c11,bit0_c11};
end

reg                             result_valid_c12;

always @(posedge sys_clk)
begin
    if(sys_rst == 1'b1)
        result_valid_c12 <= 1'b0;
    else
        result_valid_c12 <= data_valid_c11;
end

//----------------------------------------------------------------------
assign dout = result_c12;
assign dout_valid = result_valid_c12;

endmodule
