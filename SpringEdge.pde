//Copyright 2005 Sean McCullough
//banksean at yahoo

public class SpringEdge extends Edge {
  float k=0.1; //stiffness
  float a=100; //natural length.  ehmm uh, huh huh stiffness. natural length ;-)
  
  //This edge sublcass apples a spring force between the two nodes it connects
  //The spring force formula is F = k(currentLength-a)
  //This equation is one-dimensional, and applies to the straight line
  //between the two nodes.
  
  public SpringEdge(Node a, Node b) {
    super(a, b);
  }

  public void setNaturalLength(float l) {
    a = l;
  }
  
  public float getNaturalLength() {
    return a;
  }
  
  public Vector3D getForceTo() {
    float dx = dX();
    float dy = dY();
    float l = sqrt(dx*dx + dy*dy);
    float f = k*(l-a);
    
    return new Vector3D(-f*dx/l, -f*dy/l, 0);
  }
    
  public Vector3D getForceFrom() {
    float dx = dX();
    float dy = dY();
    float l = sqrt(dx*dx + dy*dy);
    float f = k*(l-a);
    
    return new Vector3D(f*dx/l, f*dy/l, 0);
  }

  public void draw(float xOffset,float yOffset,float zoom) {
    float dx = dX();
    float dy = dY();
    Vector3D f = getForceFrom();
    
    stroke(255,255,255,64);
    strokeWeight(100/a);
    line((from.getX()*zoom)+xOffset, (from.getY()*zoom)+yOffset, (to.getX()*zoom)+xOffset, (to.getY()*zoom)+yOffset);
    //text(s, from.getX() + dx/2 - textWidth(s)/2, from.getY() + dy/2);
    //smooth();
  }
}
