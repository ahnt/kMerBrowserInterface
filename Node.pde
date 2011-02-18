//Copyright 2005 Sean McCullough
//banksean at yahoo

public class Node {
  Vector3D position;
  float h = 20;
  float w = 20;
  String label = "";
  Graph g;
  int delayCounter=0;
  
  public Node() {
    position= new Vector3D();
  }

  public void setGraph(Graph h) {
    g = h;
  }
    
  public void setLabel(String s) {
    label = s;
  }
  
  public String getLabel(){
    return label;
  }
  
  public void setDelayCounter(int theDelay){
    delayCounter=theDelay;
  }
  
  public void reduceDelayCounter(){
    if(delayCounter>0)
      delayCounter--;
  }
  
  public boolean containsPoint(float x, float y) {
    float dx = position.getX()-x;
    float dy = position.getY()-y;
    
    return (abs(dx) < w/0.2 && abs(dy)<h/0.2);
  }
  
  public Node(Vector3D v) {
    position = v;
  }
  
  public Vector3D getPosition() {
    return position;
  }
  
  public void setPosition(Vector3D v) {
    position = v;
  }
  
  public void setXPosition(float X){
    position.setX(X);
  }

  public void setYPosition(float Y){
    position.setY(Y);
  }
  
  public float getX() {
    return position.getX();
  }
  
  public float getY() {
    return position.getY();
  }
  
  public void draw(float xOffset,float yOffset,float zoom,PFont font,boolean withText) {
    stroke(0);
    fill(255);
    ellipse(getX(), getY(), h, w);
  }
}
