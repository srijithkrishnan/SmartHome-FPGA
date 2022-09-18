module ds18b20#(
    command_bits = 8, //the length of each command written into DS18B20
    scratchpad_bits = 72, // the total number of bits coming from the scratchpad memory => 9 bytes
    clk_1mhz_divider_size = 7 // size of the counter to divide 100 MHz clk to 1MHz clk
    )(
    input clk, rst,
    input [15:0]temp_storage,    //for simulation purpose only
    output reg [15:0]bcd,
    inout  one_wire,
    output reg [3:0] D0_AN,
    output reg [0:7] D0_SEG
);

//different states for communication
enum {RESET, WAIT_PRESENCE, SKIP_ROM, CONVERT, WRITE, WRITE0, WRITE1, WAIT_CONVERSION, READ_SCRATCHPAD, READ_WIRE, READ_BIT} state, next_state;

reg [15:0]data_storage;  //data storage
assign date_storage = temp_storage;  //for simulation purpose only
reg [command_bits-1:0]command;  //commands passed into sensor
reg presence_signal; //presence signal from sensor
reg [scratchpad_bits-1:0] data; // data from the sensor
reg one_wire_bus; // temperory register to pass data to on wire bus
reg [1:0]read_flag = 2'b00; //flag to
reg [1:0]write_0_flag = 2'b00;
reg [1:0]write_1_flag = 2'b00;
reg t_rst;
integer t; // a counter for providing the required delays

integer bit_count = 0; //to count the bits
integer flag = 0;   //flag to identify the source
integer scratchpad_bit = 0;     //counter for scratchpad memory data bits

logic [clk_1mhz_divider_size-1:0] counter = 0; // counter to make a slow clk of 1 MHz
logic clk_1mhz; //1 MHz clock singal 

//clock reduced to 1MHz
always @(posedge clk)
    if(counter < 100)
        counter = counter + 1;
    else
        counter = 0;

assign clk_1mhz = counter[clk_1mhz_divider_size-1];

always @(posedge clk_1mhz) begin
    case(state)
    RESET: begin
            t_rst <= 1'b0;
            if(t == 0)
                one_wire_bus <= 1'b0;   //sending reset signal
            else if(t == 490)
                one_wire_bus <= 1'bZ;   //releasing bus
            else if(t == 555)
                presence_signal <= one_wire;    //reading presence signal
            else if(t == 855)
                state <= WAIT_PRESENCE;
           end
    WAIT_PRESENCE: begin
                    // sensor responded with a presence signal and pulled back the wire high
                    if(presence_signal == 0 && one_wire == 1)begin
                        t_rst <= 1'b1;
                        state <= SKIP_ROM;
                        flag = (flag == 3)? 3 : 1;
                    end
                    else begin
                        t_rst <= 1'b1;
                        state <= RESET;
                        data_storage <= 16'b1010101010101010;    //setting error option
                        end
                   
                   end
    SKIP_ROM: begin
                command <= 8'b11001100;     //SKIP_ROM command
                state <= WRITE;
                if(flag == 1)
                    next_state <= CONVERT;      //to record and Convert T
                else if(flag == 2)
                    next_state <= WAIT_CONVERSION; //if returning after writing 44h
                else if(flag == 3)
                    next_state <= READ_SCRATCHPAD; //if returning after conversion completed
              end
    WRITE: begin
            if(bit_count >= 0 && bit_count <= 7) begin      // writing each byte/command
                if(command[bit_count] == 0) begin
                    bit_count = bit_count + 1;
                    state <= WRITE0;
                end
                else if(command[bit_count] == 1) begin
                    bit_count = bit_count + 1;
                    state <= WRITE1;
                end
            end
            else if(bit_count == 8)begin    //write complete change to next state 
                    bit_count = 0;
                    state <= next_state;
                end
            else begin
                    bit_count = 0;      //any error return to RESET
                    state <= RESET;
                end
           end
    WRITE0: case(write_0_flag)      //create write 0 time slot
                2'd0: begin
                    one_wire_bus <= 1'b0;
                    t_rst <= 1'b0;
                    if(t == 59) begin   //pull one_wire to 0 for 60 us
                        t_rst <= 1'b1;
                        write_0_flag <= 2'd1;
                    end
                   end
                2'd1: begin
                    one_wire_bus <= 1'bZ;       //release bus
                    t_rst <= 1'b0;
                    if(t == 3)begin
                        t_rst <= 1'b1;
                        write_0_flag <= 2'd2;
                    end
                   end
                2'd2: begin
                    write_0_flag <= 2'd0;   // write 0 complete
                    state <= WRITE;
                   end
            endcase
             
    WRITE1: case(write_1_flag)      // create write 1 time slot
                2'd0: begin
                    one_wire_bus <= 1'b0;       //pull one_wire to 0 for 10 us
                    t_rst <= 1'b0;
                    if(t == 9)begin
                        t_rst <= 1'b1;
                        write_1_flag <= 2'd1;
                    end
                   end
                2'd1: begin
                    one_wire_bus <= 1'bZ;       //release bus
                    t_rst <= 1'b0;
                    if(t == 59)begin
                        t_rst <= 1'b1;
                        write_1_flag <= 2'd2;
                    end
                   end
                2'd2: begin
                    write_1_flag <= 2'd0;       //write 1 complete
                    state <= WRITE; 
                   end
            endcase 
            
    CONVERT: begin
              next_state <= SKIP_ROM;
              command <= 8'b01000100;       //command 44h
              state <= WRITE;
              flag = 2;
             end
    WAIT_CONVERSION: begin
                      t_rst <= 1'b0;
                      if(t == 7999999)      //wait 800 us after conversion / reading data line
                        t_rst <= 1'b1;
                        flag = (flag == 4)? 0 : 3;  //set flag to know previous state
                        state <= RESET;
                     end
    READ_SCRATCHPAD: begin
                      command = 8'b10111110;        //command BEh
                      state <= WRITE;
                      next_state <= READ_WIRE;
                     end
    READ_WIRE: begin
                if(scratchpad_bit >= 0 && scratchpad_bit <= 71) begin   //read scratchpad memory data 72 bits / 9 bytes
                    one_wire_bus <= 1'b0;
                    scratchpad_bit <= scratchpad_bit + 1;
                    state <= READ_BIT;
                end
                else if(scratchpad_bit == 72) begin         //read complete
                    scratchpad_bit <= 0;
                    data_storage <= data[15:0];              //obtaining first two bytes / converted temperature value
                    state <= WAIT_CONVERSION;
                    flag = 4;
                end
               end
    READ_BIT: begin
              case(read_flag)
                2'd0: read_flag <= 2'd1;
                2'd1: begin
                        one_wire_bus <= 1'bZ;       //release bus for sensor to start uploading data
                        t_rst <= 1'b0;
                        if(t == 13)begin
                            t_rst <= 1'b1;
                            read_flag <= 2'd2;
                        end  
                   end
                2'd2: begin
                    data[bit_count] <= one_wire;        //read data bit by bit from one_wire
                    bit_count <= bit_count + 1;
                    read_flag <= 2'd3; 
                   end
                2'd3: begin
                    t_rst <= 1'b0;
                    if(t == 63)begin
                        t_rst <= 1'b1;
                        read_flag <= 2'd0;
                        state <= READ_WIRE;
                    end                          
                   end
              endcase
             end
    endcase
end

//timer to obtain delay in us
always @(posedge clk_1mhz)begin
    if(t_rst == 1)
        t <= 0;
    else if(t_rst == 0)
        t <= t + 1;
end

assign one_wire = one_wire_bus;

//7 segment display
reg [3:0] dec;  //decimal value
reg [19:0] regN;
reg [3:0] tmp;  //temperory bcd storage for seven segment
reg [11:0] tmp_sw;
integer i;
always @(data_storage) begin
    dec = data_storage[3:0];
    tmp_sw <= data_storage[15:4];
    if(data_storage[11] == 1'b1)
        tmp_sw <= ~data_storage[15:4] + 1'b1;
    bcd=0;		 	
    for (i=0;i<12;i=i+1) begin					//Iterate once for each bit in input number
       if (bcd[3:0] >= 5) bcd[3:0] = bcd[3:0] + 3;		//If any BCD digit is >= 5, add three    
	   if (bcd[7:4] >= 5) bcd[7:4] = bcd[7:4] + 3;
	   if (bcd[11:8] >= 5) bcd[11:8] = bcd[11:8] + 3;
	   bcd = {bcd[13:0],tmp_sw[11-i]};				//Shift one bit, and shift in proper bit from input 
    end

end

//100 MHz clock
always @(posedge clk) begin
		if(rst)
			regN <= 0;
		else
			regN <= regN + 1;
	end
	
always @( * )
	begin
		case(regN[19:18])
		2'b00:begin
			D0_AN = 4'b1110; //Select 1st Anode
			tmp = dec; //The decimal part of the number to be displayed
		end
		2'b01:begin
			D0_AN = 4'b1101; //Select 2nd Anode
			tmp = bcd[3:0];  // first digit of the number
		end
		2'b10:begin
			D0_AN = 4'b1011; //Select 3rd Anode
			tmp = bcd[7:4];  // second digit of the number
		end
		2'b11:begin
			D0_AN = 4'b0111;     //Select 4th Anode
			tmp = bcd[11:8];     // third digit of the number
		end
		default:begin
			D0_AN = 4'b0111;
			tmp = bcd[15:12];
		end
		
		endcase
	
	end

always@(posedge clk) begin 
    case(tmp)
    4'd0:begin
            if(D0_AN == 4'b1101) D0_SEG <= 8'b00000010;     //if the 2nd Anode then display number with decimal point
            else D0_SEG <= 8'b00000011;
         end
    4'd1:begin
            if(D0_AN == 4'b1101) D0_SEG <= 8'b10011110;
            else D0_SEG <= 8'b10011111;
          end
    4'd2:begin
            if(D0_AN == 4'b1101) D0_SEG <= 8'b00100100;
            else D0_SEG <= 8'b00100101;
         end
    4'd3:begin
            if(D0_AN == 4'b1101) D0_SEG <= 8'b00001100;
            else D0_SEG <= 8'b00001101;
         end
    4'd4:begin
            if(D0_AN == 4'b1101) D0_SEG <= 8'b10011000;
            else D0_SEG <= 8'b10011001;
         end
    4'd5:begin
            if(D0_AN == 4'b1101) D0_SEG <= 8'b01001000;
            else D0_SEG <= 8'b01001001;
         end
    4'd6:begin
            if(D0_AN == 4'b1101) D0_SEG <= 8'b11000000;
            else D0_SEG <= 8'b11000001;
         end
    4'd7:begin
            if(D0_AN == 4'b1101) D0_SEG <= 8'b00011110;
            else D0_SEG <= 8'b00011111;
         end
    4'd8:begin
            if(D0_AN == 4'b1101) D0_SEG <= 8'b00000000;
            else D0_SEG <= 8'b00000001;
         end
    4'd9:begin
            if(D0_AN == 4'b1101) D0_SEG <= 8'b00011000;
            else D0_SEG <= 8'b00011001;
         end
    default:begin
            if(D0_AN == 4'b1101) D0_SEG <= 8'b00000010;
            else D0_SEG <= 8'b00000011;
            end
    endcase  
end


endmodule