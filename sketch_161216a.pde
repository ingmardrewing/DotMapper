color grey = color(153);
color black = color(0);
color red = color(204, 0, 0);
color blue = color(0, 0, 204);
color green = color(0, 153, 0);

Population population;

float min_distance = 30.0;

void setup(){
  size(600,600);
  smooth(8);
  population = new Population( 200 );
}

void draw(){
  background (grey);
  population.check_for_infection();
  population.socialize();
  population.bury_the_dead();
}

class Disease {
  int severity = 1;
  color c ;
  
  Disease(){
    color[] colors = {red, green, blue};
    c = colors[ floor( random(colors.length)) ] ;
  }
}

class Population {
  int size = 20;
  int frames_until_infection = 90;
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
  
  void socialize(){
    for( Person i : persons ){
      i.move_ambiently();
      for( Person j: persons ){
        if( i != j ){
          i.meets( j );
        }
      }
      i.check_health();
      i.draw();
    }
  }
  
  void bury_the_dead(){
    ArrayList<Person> survivors = new ArrayList<Person>();
    for ( Person p : persons ){
      if( p.alive ){
        survivors.add(p);
      }
    }
    persons = survivors.toArray(new Person[survivors.size()]);
  }
    
  void check_for_infection(){
    if( frames_until_infection-- < 1 ){
      Disease disease = new Disease();
      persons[ floor( random(persons.length)) ].infect(disease) ;
      frames_until_infection = 200;
    }
  }
}



class Person {
  boolean infected = false;
  boolean alive = true;
  int life = 100 ;
  
  PVector pos = new PVector(0, 0);
  float r = 5.0;
  Disease disease;
  
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
  
  void infect (Disease d){
    disease = d;
    infected = true;
  }

  void check_health(){
    if( infected ){
      if( life < 1 ){
        alive = false;
      }
      life -= disease.severity;
    }
  }
  
  void move_ambiently (){
    wander();
    bounce();
  }
  
  void meets( Person b ){
    if( pos.dist(b.pos) < min_distance ){
      flee( b );
      Connection c = new Connection( this, b );
      
      if( infected ){
        b.infect(disease);
        c.infect(disease);
      }
      
      if( b.infected ){
        infect( b.disease );
        c.infect( b.disease );
      }
      
      c. draw();
  }
}
  
  void draw (){
    PShape circle = createShape( ELLIPSE, pos.x, pos.y, r, r);
    color c = infected ? disease.c : black;
    circle.setFill( c );
    circle.setStroke( c );
    shape( circle );
  }
}



class Connection {
  Person start_person;
  Person end_person;
  PShape line;
  color c;
  
  int distance = 2;
  boolean infected = false;
  
  Connection( Person start_person_param, Person end_person_param ){
    start_person = start_person_param;
    end_person = end_person_param;
  }
  
  void infect(Disease d){
    infected = true;
    c = d.c;
  }
  
  void draw (){
    PVector v1 = getStartingPoint();
    PVector v2 = getEndPoint();
    line = createShape( LINE, v1.x, v1.y, v2.x, v2.y );
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