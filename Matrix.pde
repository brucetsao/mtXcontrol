
class Matrix {

  ArrayList frames  = new ArrayList();

  public int rad    = 70;
  int border = 10;

  public int rows = 0;
  public int cols = 0;
  public PixelColor current_color;

  Frame copy_frame;

  int current_frame_nr;

  Matrix(int cols, int rows ) {
    this.cols = cols; //X
    this.rows = rows; //Y
    this.current_color = new PixelColor().invert();
    add_frame();
  }

  public int width() {
    return cols * rad;
  }

  public int height() {
    return rows * rad;
  }

  public PGraphics current_frame_image() {
    return this.current_frame_image(rad, border);
  }

  public PGraphics current_frame_image(int draw_rad, int draw_border) {
    return this.current_frame().draw_full(draw_rad, draw_border);
  }

  public boolean click(int x, int y, boolean dragged) {
    if( x < 0 || y < 0) return false; //25 pixel right and bottom for row editing
    if( x > this.width() + 25 || y > this.height() + 25) return false; //25 pixel right and bottom for row editing
    PixelColor pc = this.current_frame().update(x / rad, y / rad, current_color, !dragged);
    if( pc == null ) return false;
    current_color = pc;
    return true;
  }

  int num_frames() {
    return frames.size();
  }

  Frame next_frame() {
    current_frame_nr = (current_frame_nr + 1 ) % num_frames();
    return current_frame();
  }

  Frame previous_frame() {
    current_frame_nr = ( current_frame_nr == 0 ) ? num_frames() - 1 : current_frame_nr - 1;
    return current_frame();
  }

  Frame first_frame() {
    current_frame_nr = 0;
    return current_frame();
  }

  /* +++++++++++++++ DATA STRUCTURE +++++++++++++++ */
  Frame current_frame() {
    return frame(current_frame_nr);
  }

  Frame frame(int f) {
    try {
      return (Frame) frames.get(f);
    }
    catch(Exception e ) {
      return (Frame) frames.get(0);
    }
  }

  void set_pixel(int f, int x, int y, PixelColor pc) {
    frame(f).set_colored_pixel(x, y, pc);
  }

  /* +++++++++++++++ FRAME +++++++++++++++ */
  Frame copy_frame() {
    copy_frame = current_frame().clone();
    return current_frame();
  }

  /* +++++++++++++++ FRAME +++++++++++++++ */
  Frame paste_frame() {
    if( copy_frame != null) frames.set(current_frame_nr, copy_frame.clone()); // better use set_pixel here!?
    return current_frame();
  }

  Frame add_frame() {
    if( !frames.isEmpty()) current_frame_nr++;
    frames.add( current_frame_nr, new Frame(this.cols, this.rows)); //init first frame
    return current_frame();
  }

  Frame delete_frame() {
    if(current_frame_nr != 0) {
      frames.remove(current_frame_nr);
      current_frame_nr--;
    }
    return current_frame();
  }

  /* +++++++++++++++ FILE +++++++++++++++ */
  void save_to_file() {
    String savePath = selectOutput();  // Opens file chooser
    if(savePath == null) {
      println("No output file was selected...");
      return;
    }
    PrintWriter output = createWriter(savePath);
    // output.println(rows+","+cols+","+speed);

    for(int f = 0; f < this.num_frames(); f++) {
      Frame frame = this.frame(f);
      for(int y=0; y<frame.rows; y++) {
        int[] row = frame.get_row(y);
        output.print(row[0] + "," + row[1] + "," + row[2] + ",");
      }
      output.println();
    }

    output.flush(); // Writes the remaining data to the file
    output.close(); // Finishes the file
    println("SAVED to " + savePath);
  }

  Matrix load_from_file() {
    String loadPath = selectInput("Choose a Matrix File to load");  // Opens file chooser
    if(loadPath == null) {
      println("No file was selected...");
      return this;
    }

    Matrix matrix = new Matrix( this.cols, this.rows); //actually we have to read values from File!
    BufferedReader reader = createReader(loadPath);
    String line = "";
    while( line != null ) {
      try {
        line = reader.readLine();
        if( line != null && line.length() > 0) {
          Frame frame = matrix.add_frame();
          String[] str = line.split(",");
          for(int y = 0; y < frame.rows; y++) {
            frame.set_row(y, Integer.parseInt(str[y*3]), Integer.parseInt(str[y*3 + 1]), Integer.parseInt(str[y*3 + 2]));
          }
        }
      }
      catch (IOException e) {
        e.printStackTrace();
        return matrix;
      }
    }
    return matrix;
  }

}



