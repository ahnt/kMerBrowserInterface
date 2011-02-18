int depth=10;
int xDim=600;
int yDim=600;
int sx,sy;
HashMap nodeNames;
boolean textIsOn=true;

String theURL="http://vertex.beacon.msu.edu:8080/kmerNeighborhood";
//String startingKmer="TACTGAAGGAGGAA";
//  String startingKmer="TTTTCTATAACTGAAGGAGGA"; 21
  String startingKmer="TTTTCTATAACTGAAGG";


Graph g = buildGraph(theURL+"?kmer="+startingKmer+"&n="+depth);

int centralNodeID;
float localXOffset=(float)xDim/2;
float localYOffset=(float)yDim/2;

float scaleFactor = 1.0;
float localZoom=0.1;
PFont font;

// returns 1 or -1 depending on direction
void mouseWheel(int delta) {
  if(delta>=1)
    localZoom*=1.2;
  else
    localZoom/=1.2;
}

void keyPressed() {
  if((key=='t')||(key=='T'))
    textIsOn=!textIsOn;
  if (key == '[') {
    localZoom *= 2.0;
  } else if (key == ']') {
    localZoom /= 2.0;
  }
  if(key == '.'){
    depth++;
      if(g.getSelectedNode()!=null){
        Node n = (Node)g.getSelectedNode();
        String filename=theURL+"?kmer="+(String)n.getLabel()+"&n="+str(depth);
        g=buildGraphUsingTemplateGraph(g,filename);
      }
  }
  if(key == ',')
    if(depth>1){
      depth--;
      if(g.getSelectedNode()!=null){
        Node n = (Node)g.getSelectedNode();
        String filename=theURL+"?kmer="+(String)n.getLabel()+"&n="+str(depth);
        g=buildGraphUsingTemplateGraph(g,filename);
      }
    }
}


void mousePressed() {
 if((mouseX>xDim-64)&&(mouseY<48)&&(g.getSelectedNode()!=null)){
    Node n = (Node)g.getSelectedNode();
    String filename=theURL+"?kmer="+(String)n.getLabel()+"&n="+str(depth);
    g=buildGraphUsingTemplateGraph(g,filename);
  }
  else{
    g.setSelectedNode(null);
    g.setDragNode(null);
    for(int i=0; i<g.getNodes().size(); i++) {
      Node n = (Node)g.getNodes().get(i);
      if (n.containsPoint((mouseX-localXOffset)/localZoom, (mouseY-localYOffset)/localZoom)) {
        g.setSelectedNode(n);
        g.setDragNode(n);
      }
    }
  }
  sx=mouseX;
  sy=mouseY;

}

void mouseMoved() {
  if (g.getDragNode() == null) {
    g.setHoverNode(null);
    for(int i=0; i<g.getNodes().size(); i++) {
      Node n = (Node)g.getNodes().get(i);
      if (n.containsPoint((mouseX-localXOffset)/localZoom, (mouseY-localYOffset)/localZoom)) {
        g.setHoverNode(n);
      }
    }
  }
}

void mouseReleased() {
  g.setDragNode(null);
}

void mouseDragged() {
  if (g.getDragNode() != null) {
    g.getDragNode().setPosition(new Vector3D((mouseX-localXOffset)/localZoom, (mouseY-localYOffset)/localZoom, 0));
  }
  else{
    localXOffset+=(mouseX-sx)*0.8;
    localYOffset+=(mouseY-sy)*0.8;
    sx=mouseX;
    sy=mouseY;
  }
}

void setup() {
  size(xDim,yDim);
  addMouseWheelListener(new java.awt.event.MouseWheelListener() {
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) {
    mouseWheel(evt.getWheelRotation());
    }});
  font = loadFont("ArialRoundedMTBold-20.vlw"); 
//  font=null;
  smooth();
}

void draw() {
  background(0);
  if (g != null) {
    doLayout();
    g.draw(localXOffset,localYOffset,localZoom,font,textIsOn);  
  }
  fill(128,128,128,255);
  rect(xDim-64,0,64,48);
  fill(255,255,255,255);
  textFont(font,32);
  text("GO!",xDim-64,32);
  textFont(font,16);
  text(depth,16,16);
}

void doLayout() {
  
  //calculate forces on each node
  //calculate spring forces on each node
  for (int i=0; i<g.getNodes().size(); i++) {
    ForcedNode n = (ForcedNode)g.getNodes().get(i);
    ArrayList edges = (ArrayList)g.getEdgesFrom(n);
    n.setForce(new Vector3D(0,0,0));
    for (int j=0; edges != null && j<edges.size(); j++) {
      SpringEdge e = (SpringEdge)edges.get(j);
      Vector3D f = e.getForceFrom();
      n.applyForce(f);
    }
    
    edges = (ArrayList)g.getEdgesTo(n);
    for (int j=0; edges != null && j<edges.size(); j++) {
      SpringEdge e = (SpringEdge)edges.get(j);
      Vector3D f = e.getForceTo();
      n.applyForce(f);
    }
  }
  
  //calculate the anti-gravitational forces on each node
  //this is the N^2 shittiness that needs to be optimized
  //TODO: at least make it N^2/2 since forces are symmetrical
  
  for (int i=0; i<g.getNodes().size(); i++) {
    ForcedNode a = (ForcedNode)g.getNodes().get(i);
    for (int j=0; j<g.getNodes().size(); j++) {
      ForcedNode b = (ForcedNode)g.getNodes().get(j);
      if (b != a) {
        float dx = b.getX() - a.getX();
        float dy = b.getY() - a.getY();
        float r = sqrt(dx*dx + dy*dy);
        //F = G*m1*m2/r^2  
        
        if (r != 0) { //don't divide by zero.
          float f = 100*(a.getMass()*b.getMass()/(r*r));
          Vector3D vf = new Vector3D(-dx*f, -dy*f, 0);
          a.applyForce(vf);
        }              
      }
    }
  }
  
  //move nodes according to forces
  for (int i=0; i<g.getNodes().size(); i++) {
    ForcedNode n = (ForcedNode)g.getNodes().get(i);
    if (n != g.getDragNode()) {
      n.setPosition(n.getPosition().add(n.getForce()));
    }
  }
  for (int i=0; i<g.getNodes().size(); i++) {
    ForcedNode n = (ForcedNode)g.getNodes().get(i);
    n.reduceDelayCounter();
  }
  /*
  ForcedNode n = (ForcedNode)g.getNodes().get(centralNodeID);
  n.setXPosition((float)0);
  n.setYPosition((float)0);
  */
}

Graph buildGraphUsingTemplateGraph(Graph original,String filename){
  Graph g;
  HashMap oldNames=new HashMap(nodeNames);
  nodeNames=new HashMap();
  g = new Graph();
  int IDCounter=0;
  String lines[] = loadStrings(filename);
  
  for(int i=1;i<int(lines[0])+1;i++){
    String[] sublist=split(lines[i],'\t');
    ForcedNode n = new ForcedNode(new Vector3D(xDim/4 + random(xDim/2), yDim/4 + random(yDim/2), 0));
    nodeNames.put(sublist[0],IDCounter);
    if(int(sublist[1])==0) centralNodeID=IDCounter;
    IDCounter++;
    n.setLabel(sublist[0]);
    n.setMass(random(1.1,1.5));
    if(oldNames.get(sublist[0])!=null){
      Node dn=(Node)original.getNodes().get((Integer)oldNames.get(sublist[0]));
      n.setXPosition(dn.getX());
      n.setYPosition(dn.getY());
      n.setDelayCounter(100);
    }
    g.addNode(n);
  }
  for(int i=int(lines[0])+1;i<lines.length;i++){
    String[] sublist=split(lines[i],'\t');
    if((nodeNames.get(sublist[0])!=null)&&(nodeNames.get(sublist[1])!=null)){
    	Node a = (Node)g.getNodes().get((Integer)nodeNames.get(sublist[0]));
    	Node b = (Node)g.getNodes().get((Integer)nodeNames.get(sublist[1]));
    	SpringEdge e = new SpringEdge(a, b);
    	e.setNaturalLength(random(20,22));
    	g.addEdge(e);
    }
  }
  return g;
}

Graph buildGraph(String filename) {
  Graph g;
  nodeNames=new HashMap();
  g = new Graph();
  int IDCounter=0;
  String lines[] = loadStrings(filename);
  
  for(int i=1;i<int(lines[0])+1;i++){
    String[] sublist=split(lines[i],'\t');
    ForcedNode n = new ForcedNode(new Vector3D(xDim/4 + random(xDim/2), yDim/4 + random(yDim/2), 0));
    nodeNames.put(sublist[0],IDCounter);
    if(int(sublist[1])==0) centralNodeID=IDCounter;
    IDCounter++;
    n.setLabel(sublist[0]);
    n.setMass(random(1.1,1.8));
    g.addNode(n);
  }
  for(int i=int(lines[0])+1;i<lines.length;i++){
    String[] sublist=split(lines[i],'\t');
    if((nodeNames.get(sublist[0])!=null)&&(nodeNames.get(sublist[1])!=null)){
    	Node a = (Node)g.getNodes().get((Integer)nodeNames.get(sublist[0]));
    	Node b = (Node)g.getNodes().get((Integer)nodeNames.get(sublist[1]));
    	SpringEdge e = new SpringEdge(a, b);
    	e.setNaturalLength(random(20,22));
    	g.addEdge(e);
    }
  }
  return g;
}
