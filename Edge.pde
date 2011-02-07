//Copyright 2005 Sean McCullough
//banksean at yahoo

public class Edge {
  Node to;
  Node from;
  Graph g;
  
  public Edge(Node t, Node f) {
    to = t;
    from = f;
  }
  
  public void setGraph(Graph h) {
    g = h;
  }
    
  public void draw(float xOffset,float yOffset,float zoom) {
    stroke(255);
    line(from.getX(), from.getY(), to.getX(), to.getY());
  }
  
  public Node getTo() {
    return to;
  }
  
  public Node getFrom() {
    return from;
  }
  
  public void setTo(Node n) {
    to = n;
  }
  
  public void setFrom(Node n) {
    from = n;
  }
  
  public float dX() {
    return to.getX() - from.getX();
  }
  
  public float dY() {
    return to.getY() - from.getY();
  }
    
}
