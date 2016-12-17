color grey;
color black;
Dots dots;

void setup(){
  size(300,300);
  smooth(8);
  grey = color(153);
  black = color(0);
  dots = new Dots(60);
}

void draw(){
 background (grey);
 for( Dot i : dots.dots ){
    for( Dot j: dots.dots ){
      if( i.pos.dist(j.pos) < Dot.MIN_DISTANCE ){
        i.wander();
        i.flee( j );
        i.bounce();
        Connection c = new Connection( i, j );
        c. draw();
      }
    }
   i.draw();
 }
}

class Dots {
  int amount = 20;
  Dot[] dots;
  
  Dots( int amount_param ){
    amount = amount_param;
    init();
  }
  
  Dots(){
    init();
  } 

  void init(){
    dots = new Dot[amount];
    populate();
  }
  
  float next_x(){
    return get_random_num( width );
  }
  
  float next_y () {
    return get_random_num( height );
  }
  
  float get_random_num ( float max ){
    return random( max - 2 * Dot.PADDING) + Dot.PADDING ;
  }
  
  void populate(){
    for( int i=0; i < dots.length; i++ ){
      dots[i] = new Dot( next_x(), next_y() );
    }
  }
}

class Connection {
  Dot start_dot;
  Dot end_dot;
  PShape line;
  
  int distance = 2;
  
  Connection( Dot start_dot_param, Dot end_dot_param ){
    start_dot = start_dot_param;
    end_dot = end_dot_param;
  }
  
  Connection( Dot start_dot_param, Dot end_dot_param, int distance_param ){
    start_dot = start_dot_param;
    end_dot = end_dot_param;
    distance = distance_param;
  }
  
  void draw (){
    PVector v1 = getStartingPoint();
    PVector v2 = getEndPoint();
    line = createShape( LINE, v1.x, v1.y, v2.x, v2.y );
    stroke(black);
    shape(line);
  }
  
  PVector getMarginalPoint (Dot d1, Dot d2) {
    PVector v = PVector.sub(d2.pos, d1.pos);
    v.normalize();
    v.mult(d1.r + distance);
    return PVector.add(d1.pos , v);
  }
  
  PVector getStartingPoint() {
    return getMarginalPoint( start_dot, end_dot );
  }
  
  PVector getEndPoint (){
    return getMarginalPoint( end_dot, start_dot );
  }
}


class Dot {
  static final float MIN_DISTANCE = 30.0 ;
  static final float PADDING = 30.0;

  PVector pos = new PVector(0 , 0);
  float r = 5.0;
  
  Dot ( float x_param, float y_param ){
    pos = new PVector( x_param, y_param );
  }
  
  Dot ( float x_param, float y_param, float radius_param ){
    pos = new PVector( x_param, y_param );
    r = radius_param;
  }
  
  void flee( Dot d ){
    PVector v = PVector.sub(pos, d.pos);
    v.normalize();
    pos = PVector.add(pos , v);
  }
  
  void wander(){
    PVector r = PVector.random2D();
    pos = PVector.add(pos, r);
  }
  
  void bounce(){
    if( pos.x < PADDING ){
      pos = new PVector( pos.x + 1, pos.y );
    }
    else if ( pos.x > width - PADDING ){
      pos = new PVector( pos.x - 1, pos.y );
    }
    if( pos.y < PADDING ){
      pos = new PVector( pos.x, pos.y + 1 );
    }
    else if( pos.y > height - PADDING ){
      pos = new PVector( pos.x, pos.y - 1 );
    }
  }
  
  void draw (){
    PShape circle = createShape( ELLIPSE, pos.x, pos.y, r, r);
    fill( black );
    stroke( black );
    shape( circle );
  }
}