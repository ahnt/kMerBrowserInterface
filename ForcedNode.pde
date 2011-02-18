//Copyright 2005 Sean McCullough
//banksean at yahoo

public class ForcedNode extends Node {
  Vector3D f = new Vector3D(0,0,0);
  float mass = 1;
  
  public ForcedNode(Vector3D v) {
    super(v);
    h = 20;
    w = 20;
  }
  
  public float getMass() {
    return mass;
  }
  
  public void setMass(float m) {
    mass = m;
    h = m*20;
    w = m*20;
  }
  
  public void setForce(Vector3D v) {
    f = v;
  }
  
  public Vector3D getForce() {
    return f;
  }
  
  public void applyForce(Vector3D v) {
    if(delayCounter<=0)
      f = f.add(v);
  }

  public void draw(float xOffset,float yOffset,float zoom,PFont font,boolean withText) {
    //super.draw();
    int localFontSize=8;
    int localAlpha=80;
    if (g.getSelectedNode() == this) {
      localFontSize=24;
      localAlpha=255;
      stroke(32,64,255,128);
      strokeWeight(10);
      fill(255,255,255,128);
    } else if (g.getHoverNode() == this) {
      localFontSize=18;
      localAlpha=160;
      noStroke();
      fill(255,255,255,128);
    } else {
      noStroke();
      fill(255,255,255,64);
    }
    
    ellipse((getX()*zoom)+xOffset, (getY()*zoom)+yOffset, h, w);
    if(withText){
      fill(255,255,255,localAlpha);
      textFont(font, localFontSize); 
      text(label,(getX()*zoom)+xOffset, (getY()*zoom)+yOffset);
    }      
  }
}

