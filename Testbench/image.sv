class image;
  
  rand logic [31:0]	size;			// image size in bytes
  rand logic [31:0] width;			// image width in pixels
  rand logic [31:0] height;			// image width in pixels
  logic 			header[][];		// header data
  rand logic 		pixels[][];		// pixels data
  int bus_size;						// bus size (32 or 64)

  constraint size_con {
    width  inside {[8:10]};
    height inside {[8:10]};
    size == (width * height * 3) + 56;
  }
  
  function new (int bus_size);
    this.bus_size = bus_size;
    
    // init the header size
    header = new[56 * 8 / bus_size];
    foreach (header[i]) header[i] = new[bus_size];
    
    // random size
    void'(this.randomize());
    
    // init the pixel size
    pixels = new[(size - 56) * 8 / bus_size];
    foreach (pixels[i]) pixels[i] = new[bus_size];
    
    // randomize the pixels
   	this.size.rand_mode(0);			// need to randomize pixels only
    this.width.rand_mode(0);
    this.height.rand_mode(0);
    this.pixels.rand_mode(1);
    void'(this.randomize());
    
    void'(set_header());
  endfunction : new
  
  function set_header;
    
    logic [447:0] tmp_header = 448'h424d0002b8aa0000000036000000280000001b010000d20000000100180000000000e8ba0200000000000000000000000000000000000000;
    
    
    tmp_header[447-16-:32] = size;		// set file size
    tmp_header[447-144-:32] = width;	// set image width
    tmp_header[447-176-:32] = height;	// set image height
    
    //$display("tmp_header = %0h", tmp_header);
    
    for (int i=0; i<448 / bus_size; i++) begin
      for (int j=0; j<bus_size; j++) begin
        header[i][j] = tmp_header[447-(i*bus_size)-j];
      end
    end
    
  endfunction : set_header
  
  static function image create(int bus_size);
    image bmp_image;
    bmp_image = new(bus_size);
    return bmp_image;
  endfunction
  
  function print_me;
    bit [`DATA_WIDTH-1:0] tmp;
    $display("Size = %0h", 				size);
    $display("Width = %0d", 			width);
    $display("Height = %0d", 			height);
    $display("Header Dim = %0d, %0d", 	header.size, header[0].size);
    $display("Pixels Dim = %0d, %0d", 	pixels.size, pixels[0].size);
    // --- print the header values ---
    for (int i=0; i<448 / bus_size; i++) begin
      for (int j=0; j<bus_size; j++) begin
        tmp[`DATA_WIDTH-j-1] = header[i][j];
      end
      $display("header[%0d] = %0h", 	i, tmp);
    end
  endfunction : print_me
  
endclass : image