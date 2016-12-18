Population population;

float min_distance = 40.0;
float reproduction_rate = 2.8;
int max_life = 45;

boolean diseases = true;
int frames_until_infection = 140;

void setup(){
  size(600,600);
  smooth(8);
  population = new Population( 100 );
}

int dir = -1;
int val = 255;
color getColor( int v ){
  if( v >= 255 ){
    dir = -1;
  }
  if( v <= 0 ){
    dir = 1;
  }
  return v + dir;
}

void draw(){
  reproduction_rate = 255.0 / float( population.persons.length );
  
  ArrayList<Connection> connections = population.update();

  background( 204 );

  for( Connection c : connections ){  
      if( null != c.disease ){
        c.disease.sicken(c);
      }
      PVector v1 = c.getStartingPoint();
      PVector v2 = c.getEndPoint();
     
      stroke( 0 );
      
      line( v1.x, v1.y, v2.x, v2.y );
  }
  
  for ( Person p : population.persons ){
      stroke( 0 );
      fill( 0 );
      ellipse( p.pos.x, p.pos.y, p.r , p.r  );
  }
  
}

class Disease {
  int severity = 1;
  color c = color(204, 0 , 0) ;
  int variant = 0;
    
  void sicken( Person person ){    
    person.col = c ;
  }
  
  void sicken( Connection connection ){
    connection.col = c;
  }
}

class Population {
  Person[] persons;
  
  Population( int size ){
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
  
  ArrayList<Connection> socialize(){
    ArrayList<Connection> connections = new ArrayList<Connection>();
    for( Person i : persons ){
      i.move_ambiently();
      for( Person j: persons ){
        if( i != j && i.pos.dist(j.pos) < min_distance ){
           connections.add( i.meets( j ) );
          }
        }
      i.check_health();
    }
    return connections;
  }
  
  void age(){
    for ( Person p : persons ){
      p.age();
    }
  }
  
  void bury_the_dead(){
    ArrayList<Person> survivors = new ArrayList<Person>();
    for ( Person p : persons ){
      if( p.is_alive() ){
        survivors.add(p);
      }
    }
    persons = survivors.toArray(new Person[survivors.size()]);
  }
  
  void reproduce(){
    ArrayList<Person> new_pop = new ArrayList<Person>();
    for ( Person p :persons ){
      new_pop.add( p );
      if( p.connected ){
        float prob = random( 100 );
        if( prob < reproduction_rate ){
          new_pop.add( new Person( p.pos.x, p.pos.y ) );
        }
      }
    }
    persons = new_pop.toArray(new Person[new_pop.size()]);
  }
    
  void check_for_infection(){
    if ( diseases ){
    if( frames_until_infection-- < 1 ){
      Disease disease = new Disease();
      persons[ floor( random(persons.length)) ].infect(disease) ;
      frames_until_infection = 100;
    }
    }
  }

  ArrayList<Connection> update (){
    if( persons.length == 0 ){
      return null;
    }
    age();
    check_for_infection();
    reproduce();
    ArrayList<Connection> connections = socialize();
    bury_the_dead();
    return connections;
  }
}

class Person {
  int life = max_life ;
  
  boolean connected = false;
  int shape = ELLIPSE;
  color col = color( 0 );
  
  PVector pos = new PVector(0, 0);
  float r = 5.0;
  ArrayList<Disease> diseases  = new ArrayList<Disease>() ; 
  
  Person ( float x_param, float y_param ){
    pos = new PVector( x_param, y_param );
  }
  
  void age(){
    life--;
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
    if( ! diseases.contains( d ) ){
      diseases.add(d);
    }
  }
  
  boolean is_infected (){
    return diseases.size() > 0;
  }
  
  boolean is_alive () {
    return life > 0;
  }

  void check_health(){
    if( is_infected() ){
      for( Disease d : diseases ){
        d.sicken(this);
      }
    }
  }
  
  void move_ambiently (){
    wander();
    bounce();
  }
  
  Connection meets( Person b ){
    connected = true ;
    flee( b );
    Connection c = new Connection( this, b );
    
    if( is_infected() ){
      for( Disease d : diseases ){
        b.infect( d );
        c.infect( d );
      }
    }
    
    if( b.is_infected() ){
      for( Disease d : b.diseases ){
        infect( d );
        c.infect( d );
      }
    }
         
      return c;
  }
}

class Connection {
  Person start_person;
  Person end_person;
  Disease disease;
  
  color col = color ( 0 );
  
  int distance = 0;
  
  Connection( Person start_person_param, Person end_person_param ){
    start_person = start_person_param;
    end_person = end_person_param;
  }
  
  void infect(Disease d){
    disease = d;
  }
  
  boolean is_infected () {
    return null != disease;
  }
  
  PVector getMarginalPoint (Person d1, Person d2) {
    PVector v = PVector.sub(d2.pos, d1.pos);
    v.normalize();
    v.mult(d1.r - 1);
    return PVector.add(d1.pos , v);
  }
  
  PVector getStartingPoint() {
    return getMarginalPoint( start_person, end_person );
  }
  
  PVector getEndPoint (){
    return getMarginalPoint( end_person, start_person );
  }
}