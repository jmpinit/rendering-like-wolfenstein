int WIDTH = 100;
int HEIGHT = 100;
int FOV = 2;

int camX = WIDTH/2;
int camY = HEIGHT/2;
float camRot = 0;

boolean world[] = new boolean[WIDTH*HEIGHT];
color textures[] = new color[WIDTH*HEIGHT];

class WorldPixel {
  private int xVal = 0;
  private int yVal = 0;
  private color col = color(0, 0, 0);
  
  public WorldPixel(int x, int y, color c)
  {
    xVal = x;
    yVal = y;
    col = c;
  }
  
  int getXPos()
  {
    return xVal;
  }
  
  int getYPos()
  {
    return yVal;
  }
  
  color getColor()
  {
    return col;
  }
}

void setup()
{
  size(500, 500);
  
  loadWorld(loadImage("world.bmp"));
  loadTextures(loadImage("textures.bmp"));
  
  background(0);
}

void draw()
{
  background(0);
  topDown();
}

void keyPressed()
{
  if(key=='w')
  {
    camX += int(cos(camRot)*5);
    camY += int(sin(camRot)*5);
  } else if(key=='s')
  {
    camX -= int(cos(camRot)*5);
    camY -= int(sin(camRot)*5);
  } else if(key=='a')
  {
    camRot -= PI/32;
  } else if(key=='d')
  {
    camRot += PI/32;
  }
  
  if(key=='q')
  {
    if(FOV<10)
    {
      FOV++;
    }
  } else if(key=='e')
  {
    if(FOV>1)
    {
      FOV--;
    }
  }
  
  if(key=='p')
  {
    println(camRot);
  }
  
  key = ' ';
}

void topDown()
{
  //draw the map
  for(int y=0; y<WIDTH; y++)
  {
    for(int x=0; x<HEIGHT; x++)
    {
      if(isSolid(x, y))
      {
        stroke(getTexture(x, y));
        point(x, y);
      }
    }
  }
  
  //draw sight
  for(int i=0; i<width; i++)
  {
    WorldPixel current = shootRay(camX, camY, camRot+(PI/width/2)*(i-width/FOV));
    int distance = int(dist(camX, camY, current.getXPos(), current.getYPos()));
    distance = min(distance, height/2);
    drawSegment(i, height/2-distance, current.getColor());
    
    stroke(100, 100, 100);
    line(camX, camY, current.getXPos(), current.getYPos());
    
    float d = height/dist(camX, camY, current.getXPos(), current.getYPos());
    stroke(255);
    line(i, height/2-d, i, height/2+d);
  }
  
  //exit();
  
  //draw player
  smooth();
  noStroke();
  fill(255, 255, 255);
  ellipse(camX, camY, 3, 3);
  noSmooth();
  stroke(255, 255, 255);
  line(camX, camY, camX+cos(camRot)*5, camY+sin(camRot)*5);
}

void rayTrace()
{
  for(int i=0; i<width; i++)
  {
    WorldPixel current = shootRay(camX, camY, camRot+(PI/width/FOV)*(i-width/FOV));
    int distance = int(dist(camX, camY, current.getXPos(), current.getYPos()))*4;
    distance = min(distance, height/2);
    drawSegment(i, height/2-distance, current.getColor());
  }
}

void loadWorld(PImage src)
{
  for(int y=0; y<HEIGHT; y++)
  {
    for(int x=0; x<WIDTH; x++)
    {
      if(brightness(src.get(x, y))<128)
      {
        setWorld(x, y, true);
      } else {
        setWorld(x, y, false);
      }
    }
  }
}

void loadTextures(PImage src)
{
  for(int y=0; y<HEIGHT; y++)
  {
    for(int x=0; x<WIDTH; x++)
    {
      setTexture(x, y, src.get(x, y));
    }
  }
}

void drawSegment(int x, int h, color c)
{
  stroke(c);
  //stroke(255, 255, 255);
  line(x, height/2-h/2, x, height/2+h/2);
}

WorldPixel shootRay(int xOrigin, int yOrigin, float rotation)
{
  float x = xOrigin;
  float y = yOrigin;
  
  float xVel = cos(rotation)*2;
  float yVel = sin(rotation)*2;
  
  if(abs(xVel)>abs(yVel))
  {
    xVel /= abs(xVel);
    yVel /= abs(xVel);
  } else {
    xVel /= abs(yVel);
    yVel /= abs(yVel);
  }
  
  while((!isSolid(int(x+xVel), int(y+yVel)))&&int(x+xVel)>0&&int(y+yVel)>0&&int(x+xVel)<WIDTH&&int(y+yVel)<HEIGHT)
  {
    x += xVel;
    y += yVel;
  }
  
  if(x>0&&y>0&&x<=WIDTH&&y<HEIGHT)
  {
    return new WorldPixel(int(x), int(y), getTexture(int(x), int(y)));
  } else {
    return new WorldPixel(0, 0, color(0, 0, 0));
  }
}

boolean isSolid(int x, int y)
{
  if(x<0||x>=WIDTH||y<0||y>=HEIGHT)
  {
    return true;
  }
  
  return world[y*WIDTH+x];
}

void setWorld(int x, int y, boolean value)
{
  world[y*WIDTH+x] = value;
}

color getTexture(int x, int y)
{
  return textures[y*WIDTH+x];
}

void setTexture(int x, int y, color value)
{
  textures[y*WIDTH+x] = value;
}
