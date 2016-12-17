color grey = color(153);
color black = color(0);
color red = color(204, 0, 0);

Dots dots;
float min_distance = 30.0;

void setup(){
  size(600,600);
  smooth(8);
  int amount = 180;
  dots = new Dots(amount);
  dots.dots[ floor( random(amount)) ].infect() ;
  
}

void draw(){
 background (grey);
 for( Dot i : dots.dots ){
    for( Dot j: dots.dots ){
      if( i.pos.dist(j.pos) < min_distance ){
        i.wander();
        i.flee( j );
        i.bounce();
        Connection c = new Connection( i, j );
        if( i.infected || j.infected ){
          j.infect();
          i.infect();
          c.infect();
        }
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
    return random( max - 2 * min_distance) + min_distance ;
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
  boolean infected = false;
  
  Connection( Dot start_dot_param, Dot end_dot_param ){
    start_dot = start_dot_param;
    end_dot = end_dot_param;
  }
  
  Connection( Dot start_dot_param, Dot end_dot_param, int distance_param ){
    start_dot = start_dot_param;
    end_dot = end_dot_param;
    distance = distance_param;
  }
  
  void infect(){
    infected = true;
  }
  
  void draw (){
    PVector v1 = getStartingPoint();
    PVector v2 = getEndPoint();
    line = createShape( LINE, v1.x, v1.y, v2.x, v2.y );
    color c = infected ? red : black ;
    stroke( c );
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
  boolean infected = false;
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
    if( pos.x < min_distance ){
      pos = new PVector( pos.x + 1, pos.y );
    }
    else if ( pos.x > width - min_distance ){
      pos = new PVector( pos.x - 1, pos.y );
    }
    if( pos.y < min_distance ){
      pos = new PVector( pos.x, pos.y + 1 );
    }
    else if( pos.y > height - min_distance ){
      pos = new PVector( pos.x, pos.y - 1 );
    }
  }
  
  void infect (){
    infected = true;
  }
  
  void draw (){
    PShape circle = createShape( ELLIPSE, pos.x, pos.y, r, r);
    color c = infected ? red : black;
    circle.setFill( c );
    circle.setStroke( c );
    shape( circle );
  }
}