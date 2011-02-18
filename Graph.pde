//Copyright 2005 Sean McCullough
//banksean at yahoo

public class Graph {
  ArrayList nodes;
  ArrayList edges;
  HashMap edgesFrom;
  HashMap edgesTo;
  
  Node selectedNode = null;
  Node dragNode = null;
  Node hoverNode = null;

  public Graph() {
    nodes = new ArrayList();
    edges = new ArrayList();    
    edgesFrom = new HashMap();
    edgesTo = new HashMap();
  }
  
  public void setSelectedNode(Node n) {
    selectedNode = n;
  }
  
  public Node getSelectedNode() {
    return selectedNode;
  }
  
  public void setHoverNode(Node n) {
    hoverNode = n;
  }
  
  public Node getHoverNode() {
    return hoverNode;
  }
  
  public void setDragNode(Node n) {
    dragNode = n;
  }
  
  public Node getDragNode() {
    return dragNode;
  }
  
  public Vector3D getCentroid() {
    float x = 0;
    float y = 0;
    for (int i=0; i<nodes.size(); i++) {
      Node n = (Node)nodes.get(i);
      x += n.getX();
      y += n.getY();
    }
    
    return new Vector3D(x/nodes.size(), y/nodes.size(), 0);
  }
  
  public void addEdge(Edge e) {
    edges.add(e);
    
    ArrayList f = getEdgesFrom(e.getFrom());
    f.add(e);
    
    ArrayList t = getEdgesTo(e.getTo());
    t.add(e);
    
    e.setGraph(this);    
  }
  
  public ArrayList getEdgesFrom(Node n) {
    ArrayList f = (ArrayList)edgesFrom.get(n);
    if (f == null) {
      f = new ArrayList();
      edgesFrom.put(n, f);
    }
    return f;
  }
  
  public ArrayList getEdgesTo(Node n) {
    ArrayList t = (ArrayList)edgesTo.get(n);
    if (t == null) {
      t = new ArrayList();
      edgesTo.put(n, t);
    }
    return t;    
  }
  
  boolean isConnected(Node a, Node b) {
    Iterator i;
    i = edges.iterator();
    while (i.hasNext()) {
      Edge e = (Edge)i.next();    
      if (e.getFrom() == a && e.getTo() == b ||
          e.getFrom() == b && e.getTo() == a) {
        return true;
      }
    }
    return false;
  }
  
  public void addNode(Node n) {
    nodes.add(n);
    n.setGraph(this);
  }

  public ArrayList getNodes() {
    return nodes;
  }
    
  public void draw(float xOffset,float yOffset,float zoom,PFont font,boolean withText) {
    for (int i=0; i<edges.size(); i++) {
      Edge e = (Edge)edges.get(i);
      e.draw(xOffset,yOffset,zoom);
    }
    
    for (int i=0; i<nodes.size(); i++) {
      Node n = (Node)nodes.get(i);
      n.draw(xOffset,yOffset,zoom,font,withText);
    }

  }
}


