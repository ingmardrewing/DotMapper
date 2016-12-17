color grey = color(153);
color black = color(0);
color red = color(204, 0, 0);

Disease disease;
Population population;

float min_distance = 30.0;

void setup(){
  size(600,600);
  smooth(8);
  
  disease = new Disease();
  population = new Population( 200 );
  disease.set_population(population);
}



void draw(){
 background (grey);
 disease.check_for_infection();
 for( Person i : population.persons ){
   if ( ! i.dead ){
    for( Person j: population.persons ){
      if( ! j.dead ){
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
    }
   i.check_health();
   i.draw();
   }
 }
}

class Disease {
  int severity = 1;
  int frames_until_infection = 200;
  Population population;
  
  void set_frames_until_infection(int frames_param ){
    frames_until_infection = frames_param;
  }
  
  void set_severity( int severity_param ){
    severity = severity_param;
  }
  
  void set_population( Population population_param ){
    population = population_param;
  }
  
  void check_for_infection(){
  if( frames_until_infection-- < 1 ){
    population.persons[ floor( random(population.size)) ].infect() ;
    frames_until_infection = 200;
  }
}
}

class Population {
  int size = 20;
  Person[] persons;
  
  Population( int size_param ){
    size = size_param;
    init();
  }
  
  Population(){
    init();
  } 

  void init(){
    persons = new Person[size];
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
    for( int i=0; i < persons.length; i++ ){
      persons[i] = new Person( next_x(), next_y() );
    }
  }
}

class Connection {
  Person start_person;
  Person end_person;
  PShape line;
  
  int distance = 2;
  boolean infected = false;
  
  Connection( Person start_person_param, Person end_person_param ){
    start_person = start_person_param;
    end_person = end_person_param;
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
  
  PVector getMarginalPoint (Person d1, Person d2) {
    PVector v = PVector.sub(d2.pos, d1.pos);
    v.normalize();
    v.mult(d1.r + distance);
    return PVector.add(d1.pos , v);
  }
  
  PVector getStartingPoint() {
    return getMarginalPoint( start_person, end_person );
  }
  
  PVector getEndPoint (){
    return getMarginalPoint( end_person, start_person );
  }
}


class Person {
  boolean infected = false;
  boolean dead = false;
  int life = 50 ;
  
  PVector pos = new PVector(0 , 0);
  float r = 5.0;
  
  Person ( float x_param, float y_param ){
    pos = new PVector( x_param, y_param );
  }
  
  void flee( Person d ){
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

  void check_health(){
    if( infected ){
      if( life < 1 ){
        dead = true;
      }
      life -= disease.severity;
    }
  }
  
  void draw (){
    PShape circle = createShape( ELLIPSE, pos.x, pos.y, r, r);
    color c = infected ? red : black;
    circle.setFill( c );
    circle.setStroke( c );
    shape( circle );
  }
}