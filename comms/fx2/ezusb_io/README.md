
http://opencores.org/project,ezusb_io

It's a general purpose Cypress EZUSB communication core which was developed for
[ZTEX FPGA Boards](http://www.ztex.de/)
 and supports the following features:

 * EZ-USB slave FIFO input
 * EZ-USB slave FIFO output
 * buffering and filtering of the interface clock from the EZ-USB
 * Scheduler if both directions are active
 * Automatic committing 'PKTEND' after timeout


# Interface

The usage of this core is best described by a commented port definition:

```verilog
module ezusb_io #(
	parameter CLKBUF_TYPE = "",	// selects the clock preparation method (buffering, filtering, ...)
	                                // "SPARTAN6" for Xilinx Spartan 6, 
	                            	// "SERIES7" for Xilinx Series 7, 
	                            	// all other values: no clock preparation
	parameter OUTEP = 2,            // EP for FPGA -> EZ-USB transfers
	parameter INEP = 6              // EP for EZ-USB -> FPGA transfers 
    ) (
        output ifclk,                   // buffered output of the interface clock
                                        // this is the clock for the user logic
        input reset,                    // asynchronous reset input
        output reset_out, 		// synchronous reset output
 
        // FPGA pins that are connected directly to EZ-USB.
        input ifclk_in,                 // interface clock IFCLK
        inout [15:0] fd,                // 16 bit data bus
	output reg SLWR, PKTEND,        // SLWR (slave write) and PKTEND (packet end) flags
	output SLRD, SLOE,              // SLRD (slave read) and SLOE (slave output enable) flags
	output [1:0] FIFOADDR,          // FIFOADDR pins select the endpoint
	input EMPTY_FLAG, FULL_FLAG,    // EMPTY and FULL flag of the slave FIFO interface
 
	// Signals for FPGA -> EZ-USB transfer. The are controlled by user logic.
        input [15:0] DI,                // data written to EZ-USB
        input DI_valid,			// 1 indicates valid data; DI and DI_valid must be hold if DI_ready is 0
        output DI_ready,  		// 1 if new data are accepted
        input DI_enable,		// setting to 0 disables FPGA -> EZ-USB transfers
        input [15:0] pktend_timeout,	// timeout in multiples of 65536 clocks before a short packet committed
    					// setting to 0 disables this feature
 
	// Signals for EZ-USB -> FPGA transfer. They are controlled by user logic.
        output reg [15:0] DO,           // data read from EZ-USB
        output reg DO_valid,		// 1 indicates valid data
        input DO_ready,			// setting to 1 enables writing new data to DO in next clock
                                        // DO and DO_valid are hold if DO_ready is 0
    					// set to 0 to disable data reads 
        // debug output
        output [3:0] status
    );
```

## Verilog instantiation example

This is an example instantiation in Verilog:

```verilog
ezusb_io #(
	.OUTEP(2),		        // EP2 for FPGA -> EZ-USB transfers
	.INEP(6), 		        // EP6 for EZ-USB -> FPGA transfers 
	.CLKBUF_TYPE("SERIES7")		// selects the clock preparation method (buffering, filtering, ...)
	                                // "SPARTAN6" for Xilinx Spartan 6, 
	                            	// "SERIES7" for Xilinx Series 7, 
	                            	// all other values: no clock preparation
    ) ezusb_io_inst (
        .ifclk(ifclk),
        .reset(reset),   		
        .reset_out(reset_usb),		

        // pins
        .ifclk_in(ifclk_in),
        .fd(fd),
	.SLWR(SLWR),
	.SLRD(SLRD),
	.SLOE(SLOE), 
	.PKTEND(PKTEND),
	.FIFOADDR({FIFOADDR1, FIFOADDR0}), 
	.EMPTY_FLAG(FLAGA),
	.FULL_FLAG(FLAGB),

	// signals for FPGA -> EZ-USB transfer
	.DI(rd_buf[15:0]),		
	.DI_valid(USB_DI_valid),	
	.DI_ready(USB_DI_ready),	
	.DI_enable(1'b1),		
        .pktend_timeout(16'd73),	// timeout in multiples of 65536 clocks (approx. 0.1s @ 48 MHz) before a short packet committed
    					
	// signals for EZ-USB -> FPGA transfer
	.DO(USB_DO),			
	.DO_valid(USB_DO_valid),	
	.DO_ready((mode_buf==2'd0) && !reset_ifclk && !FULL),	
        // debug output
	.status(if_status)	
    );
```


## VHDL instantiation example

A component declaration of the module can be found in file ezusb_io_component.vhdl 
This is the VHDL variant of the instantiation from above.

```vhdl

-- ...
signal reset2      : std_logic;
signal DO_ready    : std_logic;

begin

   ezusb_io_inst : ezusb_io 
    generic map (
	OUTEP => 2,		        -- EP for FPGA -> EZ-USB transfers
	INEP  => 6 		        -- EP for EZ-USB -> FPGA transfers 
    ) 
    port map (
	ifclk     => ifclk,
        reset     => reset,   		-- asynchronous reset input
        reset_out => reset_usb,		-- synchronous reset output
        -- pins
        ifclk_in   => ifclk_in,
        fd	   => fd,
	SLWR	   => SLWR,
	SLRD       => SLRD,
	SLOE       => SLOE, 
	PKTEND     => PKTEND,
	FIFOADDR(0)=> FIFOADDR0, 
	FIFOADDR(1)=> FIFOADDR1, 
	EMPTY_FLAG => FLAGA,
	FULL_FLAG  => FLAGB,
	-- signals for FPGA -> EZ-USB transfer
	DI	       => rd_buf(15 downto 0),	-- data written to EZ-USB
	DI_valid       => USB_DI_valid,		-- 1 indicates data valid; DI and DI_valid must be hold if DI_ready is 0
	DI_ready       => USB_DI_ready,		-- 1 if new data are accepted
	DI_enable      => '1',			-- setting to 0 disables FPGA -> EZ-USB transfers
        pktend_timeout => conv_std_logic_vector(90,16),		-- timeout in multiples of 65536 clocks (approx. 0.1s @ 48 MHz) before a short packet committed
    						-- setting to 0 disables this feature
	-- signals for EZ-USB -> FPGA transfer
	DO       => USB_DO,			-- data read from EZ-USB
	DO_valid => USB_DO_valid,		-- 1 indicated valid data
	DO_ready => DO_ready,			-- setting to 1 enables writing new data to DO in next clock; DO and DO_valid are hold if DO_ready is 0
        -- debug output
	status	 => if_status
    );

    reset2 
```
