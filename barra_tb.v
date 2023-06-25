module barramento_tb;

  reg clk;
  reg reset;
  reg [127:0] data_in;
  reg valid_in;
  wire valid_out;
  wire [127:0] data_out;

  // Instantiate the module under test
  barramento dut (
    .clk(clk),
    .reset(reset),
    .data_in(data_in),
    .valid_in(valid_in),
    .valid_out(valid_out),
    .data_out(data_out)
  );

  // Clock generation
  always begin
    #5 clk = ~clk;
  end

  // Stimulus
  initial begin
	
    clk = 0;
    reset = 1;
    data_in = 128'h00000000000000000000000000000000;
    valid_in = 1;

    #10 reset = 0;

    // Test case 1
    #5 data_in = 128'h1234567890ABCDEF1234567890ABCDEF;
    valid_in = 1;
    #10 valid_in = 0;
    #50;

    // Test case 2
    #5 data_in = 128'hFEDCBA0987654321FEDCBA0987654321;
    valid_in = 1;
    #10 valid_in = 0;
    #50;

    // Test case 3
    #5 data_in = 128'h11111111111111111111111111111111;
    valid_in = 1;
    #10 valid_in = 0;
    #50;

    // Test case 4
    #5 data_in = 128'h22222222222222222222222222222222;
    valid_in = 1;
    #10 valid_in = 0;
    #50;
	

	
    // Test case 5
    #5 data_in = 128'h33333333333333333333333333333333;
    valid_in = 1;
    #10 valid_in = 0;
    #50;

    // Test case 6
    #5 data_in = 128'h44444444444444444444444444444444;
    valid_in = 1;
    #10 valid_in = 0;
    #50;

    // Test case 7
    #5 data_in = 128'h55555555555555555555555555555555;
    valid_in = 1;
    #10 valid_in = 0;
    #50;

    $finish;
  end

endmodule
