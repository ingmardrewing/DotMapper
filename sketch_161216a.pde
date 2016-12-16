void setup(){
  size(600,600);
  smooth(8);
}

color grey = color(153);
color black = color(0);

void draw(){
 background (grey);
 Dot d1 = new Dot( 184, 234 );
 Dot d2 = new Dot( 387, 100 );
 Connection c1 = new Connection( d1, d2);
 d1.draw();
 d2.draw();
 c1.draw();
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
  PVector pos = new PVector(0,0);
  int r = 5;
  
  Dot ( int x_param, int y_param ){
    pos = new PVector( x_param, y_param );
  }
  
  Dot ( int x_param, int y_param, int radius_param ){
    pos = new PVector( x_param, y_param );
    r = radius_param;
  }
  
  void draw (){
    PShape circle = createShape( ELLIPSE, pos.x, pos.y, r, r);
    fill( black );
    stroke( black );
    shape( circle );
  }
}