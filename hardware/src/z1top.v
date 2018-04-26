module z1top # (
  // We are using a 125 MHz input clock for our design.
  // It is declared as a parameter so the testbench can override it if desired
  // This clock isn't used directly
  parameter SYSTEM_CLOCK_FREQ = 125_000_000,

  // CPU clock frequency in Hz.
  // This is generated by one of the Zynq's PLLs. The PLL must be configured
  // to generate this value.
  parameter CPU_CLOCK_FREQ = 50_000_000,

  // These are used for the button debouncer.
  // They are overridden in the testbench for faster runtime.
  parameter integer B_SAMPLE_COUNT_MAX = 0.0002 * SYSTEM_CLOCK_FREQ,
  parameter integer B_PULSE_COUNT_MAX = 0.03/0.0002,

  // I2S control signals.
  parameter integer LRCK_FREQ_HZ = 22050,
  parameter integer MCLK_TO_LRCK_RATIO = 128,
  parameter integer BIT_DEPTH = 24
) (
  input USER_CLK,             // 125 MHz clock.

    input RESET,
    input [2:0] BUTTONS,        // Momentary push-buttons.
    input [1:0] SWITCHES,       // Slide switches
    output [5:0] LEDS,          // Board LEDs.
//    output [7:0] PMOD_LEDS,
    output aud_sd,


  // UART connections
  input FPGA_SERIAL_RX,
  output FPGA_SERIAL_TX,

  // I2S Signals
  output MCLK,                // Master Clock.
  output LRCK,                // Left-right Clock.
  output SCLK,                // Serial Clock.
  output SDIN,                // Serial audio data output.

  // Primitive audio
  output AUDIO_PWM,

  // HDMI TX
  inout HDMI_TX_CEC,          // You can ignore this.
  output HDMI_TX_CLK_N,
  output HDMI_TX_CLK_P,
  output [2:0] HDMI_TX_D_N,
  output [2:0] HDMI_TX_D_P,
  input HDMI_TX_HPDN,
  inout HDMI_TX_SCL,          // You can ignore this.
  inout HDMI_TX_SDA,           // You can ignore this.

  // For debugging
  output [7:0] PMOD_LEDS
);

    // Remove these lines when implementing checkpoint 3.
//    assign MCLK = 1'b1;
//    assign LRCK = 1'b1;
//    assign SDIN = 1'b1;
//    assign SDIN = 1'b1;

    // Remove these lines when implementing checkpoint 2.
//    assign AUDIO_PWM = 1'b0;
    assign aud_sd = 1'b1;

    //// Clocking
//    wire user_clk_g, cpu_clk, cpu_clk_g, cpu_clk_pll_lock;
//    wire cpu_clk_pll_fb_out, cpu_clk_pll_fb_in;
        
//    reg [31:0] counter;
//    reg sig;
//    wire [31:0] pc;
//    always @(posedge cpu_clk_g) begin
//      if (counter == CPU_CLOCK_FREQ - 1) begin
//        counter <= 32'b0;
//        sig <= ~sig;
//      end
//      else counter <= counter + 1;
//    end
//    assign LEDS[5] = sig;
//    assign LEDS[4] = cpu_clk_pll_lock;
//    assign LEDS[3] = cpu_clk_g;
//    assign LEDS[2:0] = counter[26:24];
    
//    assign PMOD_LEDS[7:1] = pc[31:25];

  wire user_clk_g;

  IBUFG user_clk_buf  (.I(USER_CLK),           .O(user_clk_g));

  wire cpu_clk, cpu_clk_g, cpu_clk_pll_lock;
  wire cpu_clk_pll_fb_out, cpu_clk_pll_fb_in;

  BUFG  cpu_clk_buf     (.I(cpu_clk),               .O(cpu_clk_g));
  BUFG  cpu_clk_f_buf   (.I(cpu_clk_pll_fb_out),    .O (cpu_clk_pll_fb_in));
 
  // Magical instantiation of a PLL on the Zynq chip. (If you're curious,
  // you can create one yourself with the Clocking Wizard IP.) The first PLL
  // is for your RISC-V CPU clock.
  PLLE2_ADV
  #(
    .BANDWIDTH            ("OPTIMIZED"),
    .COMPENSATION         ("BUF_IN"),  // Not "ZHOLD"
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (5),
    .CLKFBOUT_MULT        (34),
    .CLKFBOUT_PHASE       (0.000),
    .CLKOUT0_DIVIDE       (17),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKIN1_PERIOD        (8.000))
  plle2_cpu_inst
  // Output clocks
  (
    .CLKFBOUT            (cpu_clk_pll_fb_out),
    .CLKOUT0             (cpu_clk),
     // Input clock control
    .CLKFBIN             (cpu_clk_pll_fb_in),
    .CLKIN1              (user_clk_g),
    .CLKIN2              (1'b0),
     // Tied to always select the primary input clock
    .CLKINSEL            (1'b1),
    // Other control and status signals
    .LOCKED              (cpu_clk_pll_lock),
    .PWRDWN              (1'b0),
    .RST                 (1'b0));

  wire pixel_clk, pixel_clk_g, pixel_clk_pll_lock;
  wire pixel_clk_pll_fb_out, pixel_clk_pll_fb_in;

  BUFG  pixel_clk_buf   (.I(pixel_clk),             .O(pixel_clk_g));
  BUFG  pixel_clk_f_buf (.I(pixel_clk_pll_fb_out),  .O (pixel_clk_pll_fb_in));

  // The second PLL is for the HDMI pixel clock.
  PLLE2_ADV
  #(
    .BANDWIDTH            ("OPTIMIZED"),
    .COMPENSATION         ("BUF_IN"),  // Not "ZHOLD"
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (5),
    .CLKFBOUT_MULT        (39),
    .CLKFBOUT_PHASE       (0.000),
    .CLKOUT0_DIVIDE       (15),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKIN1_PERIOD        (8.000))
  plle2_pixel_inst
  (
    .CLKFBOUT            (pixel_clk_pll_fb_out),
    .CLKOUT0             (pixel_clk),
    .CLKFBIN             (pixel_clk_pll_fb_in),
    .CLKIN1              (user_clk_g),
    .CLKIN2              (1'b0),
    .CLKINSEL            (1'b1),
    .LOCKED              (pixel_clk_pll_lock),
    .PWRDWN              (1'b0),
    .RST                 (1'b0));
  
  // This is a sanity check of the three different clocks.
  // reg [63:0] zynq_counter;
  // initial zynq_counter = 0;
  // always @(posedge zynq_clk) zynq_counter <= zynq_counter + 1;

  // reg [63:0] pixel_counter;
  // initial pixel_counter = 0;
  // always @(posedge pixel_clk_g) pixel_counter <= pixel_counter + 1;

  // reg [63:0] cycle_counter;
  // initial cycle_counter = 0;
  // always @(posedge cpu_clk_g) cycle_counter <= cycle_counter + 1;

  // assign PMOD_LEDS[7] = pixel_counter[25];
  // assign PMOD_LEDS[6] = zynq_counter[25];
  // assign PMOD_LEDS[5] = cycle_counter[25];

  // -------------------------------------------------------------------------
  // Zynq Processor Subsystem
  // -------------------------------------------------------------------------

  // wire zynq_clk;

  // wire axi_error, axi_txn_done;
  // wire user_write_ready, user_read_ready, user_write_enable;
  // wire [31:0] user_read_data;
  // wire [31:0] user_read_addr, user_write_data, user_write_addr;
  // wire axi_txn_init;

  // zynq_subsystem_wrapper zynq_system (
  //   .ZYNQ_PS_CLK(zynq_clk),
  //   .aux_reset_in(1'b1),
  //   .axi_error(axi_error),
  //   .axi_txn_init(axi_txn_init),
  //   .axi_txn_done(axi_txn_done),
  //   .user_write_enable(user_write_enable),
  //   .user_read_addr(user_read_addr),
  //   .user_read_data(user_read_data),
  //   .user_read_ready(user_read_ready),
  //   .user_write_addr(user_write_addr),
  //   .user_write_data(user_write_data),
  //   .user_write_ready(user_write_ready)
  // );
      
  // -------------------------------------------------------------------------
  // DRAM
  // -------------------------------------------------------------------------

  // This is an example of how to use the DRAM interface in the Zynq
  // Processor Subsystem.
  //
  // Every 100.000,000 cycles, this writes some data to RAM and reads the data
  // written on the previous iteration. If the data read this time matches the
  // data written last time, it asserts last_compare. You should modify this
  // to use an ansynchronous FIFO to read/write from DRAM.
  //
  // Once you've launched the Xilinx SDK, you can inspect the memory we're
  // writing to directly. Go to the Xilinx menu -> Dump/Restore Data File. Our
  // access port memory is mapped to 0x00000000, so set the starting address
  // to 0. Length is up to you. You can inspect the output file with the
  // hexdump or hexedit programs.
  //
  // Remember that this needs the ps7_init functions to run. Until they're
  // run, the PS7 system clock output doesn't work. We can do this in the FPGA
  // by building and running a Hello World app, but is there an easier way?

  
  //reg [31:0] user_read_addr, user_write_data, user_write_addr;

  // `define NUM_CYCLES 100_000_000

  // reg [63:0] addr_counter;
  // reg [31:0] last_write_data;
  // reg [31:0] last_read_data;
  // reg last_compare;

  // assign user_write_enable = 1'b1;
  // 
  // initial begin
  //     addr_counter = 0;
  //     last_write_data = 0;
  //     user_write_addr = 0;
  //     user_read_addr = 0;
  //     user_write_data = 0;
  // end
  // 
  // always @(posedge zynq_clk) begin
  //     addr_counter <= addr_counter + 1;
  //     if (addr_counter == `NUM_CYCLES - 1) begin
  //         user_write_data <= user_write_data + 1;
  //         last_write_data <= user_write_data;
  //         user_read_addr <= user_write_addr;
  //         user_write_addr <= user_write_addr + 4;
  //         axi_txn_init <= 1;
  //         addr_counter <= 0;
  //     end else if (axi_txn_done == 1'b1) begin
  //         last_read_data <= user_read_data;
  //         axi_txn_init <= 0;
  //     end else begin
  //         axi_txn_init <= 0;
  //     end
  // end
  // 
  // always @(*) begin
  //     last_compare = (last_read_data == last_write_data);
  // end
  
  // This needs the ps7_init functions to run. Until they're run, the PS7
  // system clock output doesn't work. We can do this in the FPGA by building
  // and running a Hello World app, but is there an easier way?
  
  // assign PMOD_LEDS[7:3] = addr_counter[27:24];
  // assign LEDS[3:0] = last_read_data[3:0];
  // assign LEDS[5] = axi_txn_done;
  // assign LEDS[4] = last_compare;

  // -------------------------------------------------------------------------
  // Arbiter
  // -------------------------------------------------------------------------

  // TODO: Your code here.
 
  // -------------------------------------------------------------------------
  // User I/O, including resets
  // -------------------------------------------------------------------------

  // The global system reset is asserted when the RESET button is
  // pressed by the user or when the PLL isn't locked
  wire [2:0] clean_buttons;
  wire reset_button, reset;
  assign reset = reset_button || ~cpu_clk_pll_lock;

  button_parser #(
    .width(4),
    .sample_count_max(B_SAMPLE_COUNT_MAX),
    .pulse_count_max(B_PULSE_COUNT_MAX)
  ) b_parser (
    .clk(cpu_clk_g),
    .in({RESET, BUTTONS}),
    .out({reset_button, clean_buttons})
  );

  wire tone_output_enable;
  wire [23:0] tone_switch_period;
  
  // -------------------------------------------------------------------------
  // HDMI
  // -------------------------------------------------------------------------
  //
  
  wire video_reset = reset || HDMI_TX_HPDN;
  wire [23:0] rgb;
  wire vde, hsync, vsync;
  wire framebuffer_data;
  wire [31:0] framebuffer_addr;
  wire arb_we;
  wire arb_din;
  wire [19:0] arb_addr;

  rgb2dvi_0 hdmi_out (
    .TMDS_Clk_p(HDMI_TX_CLK_P),
    .TMDS_Clk_n(HDMI_TX_CLK_N),
    .TMDS_Data_p(HDMI_TX_D_P),
    .TMDS_Data_n(HDMI_TX_D_N),
    .aRst(video_reset),
    .vid_pData(rgb),
    .vid_pVDE(vde),
    .vid_pHSync(hsync),
    .vid_pVSync(vsync),
    .PixelClk(pixel_clk_g)
  );

  // TODO: Your video controller.
  video_controller vinny (
    .clk(pixel_clk_g),
    .rst(video_reset),
    .framebuffer_addr(framebuffer_addr),
    .framebuffer_data({31'b0, framebuffer_data}),
    .hdmi_data(rgb),
    .hdmi_v(vsync),
    .hdmi_h(hsync),
    .hdmi_de(vde)
  );
  
  frame_buffer_1_786432 frame_buffer (
    //arbiter
    .arb_we(arb_we),
    .arb_clk(cpu_clk_g),
    .arb_din(arb_din),
    .arb_addr(arb_addr), // 19:0
    
    //video
    .vga_clk(pixel_clk_g),
    .vga_addr(framebuffer_addr[19:0]), // 19:0
    .vga_dout(framebuffer_data) // output
  );

  // Insert the rest of your code here: I/O, audio, CPU...

  // -------------------------------------------------------------------------
  // Tone generator
  // -------------------------------------------------------------------------
  tone_generator tony (
      .clk(cpu_clk_g),
      .rst(reset_button),
      .output_enable(tone_output_enable && BUTTONS[0]), // from CPU
      .tone_switch_period(tone_switch_period), // 24 bits from CPU
      .square_wave_out(AUDIO_PWM) // output
  );
    
  // User I/O FIFO
      
  wire [BIT_DEPTH-1:0] dout_to_pcm_data;
  wire pcm_data_ready_to_rd_en;
  wire async_fifo_empty;
    
  i2s_controller #(.BIT_DEPTH(BIT_DEPTH)
  ) connor (
    .sys_reset(reset),
    .sys_clk(cpu_clk_g),            // Source clock, from which others are derived
    
    .pcm_data(dout_to_pcm_data),
    .pcm_data_valid(!async_fifo_empty),
    .pcm_data_ready(pcm_data_ready_to_rd_en),
    
    // I2S control signals
    .mclk(MCLK),              // Master clock for the I2S chip
    .sclk(SCLK),
    .lrck(LRCK),              // Left-right clock, which determines which channel each audio datum is sent to.
    .sdin(SDIN)  
  );

  // -------------------------------------------------------------------------
  // async FIFO
  // -------------------------------------------------------------------------
  //  

  wire [BIT_DEPTH-1:0] async_fifo_din;
  wire async_fifo_wr_en;
  wire async_fifo_full;
  
  async_fifo #(
   .data_width(BIT_DEPTH)
  ) async_FIFO (
   .wr_clk(cpu_clk_g), 
   .rd_clk(cpu_clk_g),
   // Write side
   .wr_en(async_fifo_wr_en),
   .din(async_fifo_din),
   .full(async_fifo_full),
   // Read side
   .rd_en(pcm_data_ready_to_rd_en),
   .dout(dout_to_pcm_data),
   .empty(async_fifo_empty)
  );   

    
  // For the clock, use user_clk_g.
    
  // Your RISC-V 151 CPU
  Riscv151 #(
    .CPU_CLOCK_FREQ(CPU_CLOCK_FREQ),
    .BIT_DEPTH(BIT_DEPTH)
  ) CPU (
    .clk(cpu_clk_g),
    .rst(reset),
    
    .FPGA_SERIAL_RX(FPGA_SERIAL_RX),
    .FPGA_SERIAL_TX(FPGA_SERIAL_TX),
    
    // GPIO FIFO?
    .BUTTONS({reset_button, clean_buttons}),
    // GPIO switches?
    .SWITCHES(SWITCHES),
    // GPIO LEDS?
    .LEDS(LEDS),          // Board LEDs.
    .PMOD_LEDS(),
    
    // Tone generator hookups?
    .tone_output_enable(tone_output_enable),
    .tone_switch_period(tone_switch_period),
    // I2S/ASYNC FIFO hookups?
    .async_fifo_din(async_fifo_din),
    .async_fifo_wr_en(async_fifo_wr_en),
    .async_fifo_full(async_fifo_full),
    
    // framebuffer stuff
    .fb_we(arb_we),
    .fb_data(arb_din),
    .fb_addr(arb_addr)
  );

endmodule

