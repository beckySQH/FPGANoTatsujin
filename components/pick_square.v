/**
 * This module picks what square should be drawn and outputs its co-ordinates as well as its colour based
 * on the note stream input (the lowest bits of a shifter)
 *
 * @input notes the lowest notes from the shifter
 * @input clock the clock for timing
 * @output squareX the x-coordinate of the square to draw
 * @output colour the colour the VGA module should draw
 */
module pick_square(
          input [9:0] notes,
          input clock,
          output [7:0] squareX,
          output [2:0] colour);
  
  wire [7:0] counter_value;
  wire reset_counter;
  assign reset_counter = (counter_value == 8'd16); // Reset counter when it gets to 16
  
  counter ticks(
    .clock(clock),
    .q(counter_value),
    .enable(1'b1),
    .clear_b(!reset_counter)
  );
  
  // Connecting wires
  wire [7:0] x_coordinate;
  assign squareX = x_coordinate;
  wire [9:0] input_notes;
  assign input_notes = notes;
  wire [2:0] colour_wire;
  assign colour = colour_wire;
  
  // Finite state machine
  pick_square_fsm square_picker(
    .go(1'b1), // Will always be running
    .clock(reset_counter), // This essentially makes the finite state machine clock run only every 17 ticks
    .notes(input_notes),
    .squareX(x_coordinate),
    .colour(colour_wire)
  );
endmodule

/**
 * Finite state machine for the square picker.
 *
 * @input go the signal to start the FSM if it 
 * @input clock the clock signal for timing
 * @input notes the lowest bits from the note register, used to determine output colour
 * @output squareX the x-coordinate of the current square
 * @output the colour of the current square
 */
module pick_square_fsm(
          input go,
          input clock,
          input [9:0] notes,
          output [7:0] squareX,
          output [2:0] colour);
  reg [5:0] current_state, next_state;
  
  // States
  localparam  RESTING = 5'd0,
              S0 = 5'd1,
              S1 = 5'd2,
              S2 = 5'd3,
              S3 = 5'd4,
              S4 = 5'd5,
              S5 = 5'd6,
              S6 = 5'd7,
              S7 = 5'd8,
              S8 = 5'd9,
              S9 = 5'd10;
  
  // Colour
  localparam RED = 3'b100,
             BLACK = 3'b000;
  reg [2:0] curr_colour;
  assign colour = curr_colour;

  // Coordinates
  reg [7:0] coordinates;
  localparam initialX = 7'b0000001, // X-coordinate of first square
             squareOffset = 7'b0000101; // How far the origin of each square should be from each other
  assign squareX = coordinates;
  
  // State transitions
  always @(posedge clock) begin: state_table
    case (current_state)
      S0: next_state = S1;
      S1: next_state = S2;
      S2: next_state = S3;
      S3: next_state = S4;
      S4: next_state = S5;
      S5: next_state = S6;
      S6: next_state = S7;
      S7: next_state = S8;
      S8: next_state = S9;
      S9: next_state = RESTING;
      RESTING: next_state = go ? S0 : RESTING;
		default: next_state = RESTING;
    endcase
  end
  // change states
  always@(posedge clock)
    current_state <= next_state;
  
  // Assign outputs
  always @(*) begin: output_assignment
    case (current_state)
      default: begin
        curr_colour <= notes[0] ? RED : BLACK;
        coordinates <= initialX;
        end
      S1: begin
        curr_colour <= notes[1] ? RED : BLACK;
        coordinates <= {initialX + squareOffset};
        end
      S2: begin
        curr_colour <= notes[2] ? RED : BLACK;
        coordinates <= {initialX + {squareOffset * 2}};
        end
      S3: begin
        curr_colour <= notes[3] ? RED : BLACK;
        coordinates <= {initialX + {squareOffset * 3}};
        end
      S4: begin
        curr_colour <= notes[4] ? RED : BLACK;
        coordinates <= {initialX + {squareOffset * 4}};
        end
      S5: begin
        curr_colour <= notes[5] ? RED : BLACK;
        coordinates <= {initialX + {squareOffset * 5}};
        end
      S6: begin
        curr_colour <= notes[6] ? RED : BLACK;
        coordinates <= {initialX + {squareOffset * 6}};
        end
      S7: begin
        curr_colour <= notes[7] ? RED : BLACK;
        coordinates <= {initialX + {squareOffset * 7}};
        end
      S8: begin
        curr_colour <= notes[8] ? RED : BLACK;
        coordinates <= {initialX + {squareOffset * 8}};
        end
      S9: begin
        curr_colour <= notes[9] ? RED : BLACK;
        coordinates <= {initialX + {squareOffset * 9}};
        end
    endcase
  end
endmodule
