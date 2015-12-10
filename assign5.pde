int enemyCount=8;
PFont f;
PImage start1, start2, bg1, bg2, fighter, enemy, hp, treasure, shoot, end1, end2;
PImage[] flame=new PImage[5];
int bg2_x;
int hpValue;
int score;
int treasureX, treasureY;
int fighterX, fighterY, fighterSpeed=5;
int enemyState;
int[] enemyX=new int[8], enemyY=new int[8]; 
boolean[] flameFire=new boolean[10];
int flameNum;
int[] flameX=new int[8], flameY=new int[8], flamePicture=new int[8], flameCounter=new int[8];
boolean shootAble, shootFire;
int shootSpeed=2, shootNum;
int[] shootX=new int[5], shootY=new int[5];
boolean upPressed, downPressed, rightPressed, leftPressed;

// game state
final int GAME_START=0;
final int GAME_RUN=1;
final int GAME_END=2;
int gameState=GAME_START;


void setup () {
  size(640, 480);
  frameRate=60;
  f=createFont("Arial",24);
  start1=loadImage("img/start1.png");
  start2=loadImage("img/start2.png");
  bg1=loadImage("img/bg1.png");
  bg2=loadImage("img/bg2.png");
  fighter=loadImage("img/fighter.png");
  enemy=loadImage("img/enemy.png");
  hp=loadImage("img/hp.png");
  treasure=loadImage("img/treasure.png");
  for(int i=0;i<5;i++)
    flame[i]=loadImage("img/flame"+(i+1)+".png");  
  shoot=loadImage("img/shoot.png");
  end1=loadImage("img/end1.png");
  end2=loadImage("img/end2.png");
}

void draw() {  
  switch(gameState){
    case GAME_START:
      bg2_x=0;
      hpValue=40;
      score=0;
      treasureX=floor(random(640-treasure.width));
      treasureY=floor(random(40,480-treasure.height));
      fighterX=580;
      fighterY=240;
      enemyState=0;
      addEnemy(enemyState);
      flameNum=0;
      for(int i=0;i<8;i++){
        flameFire[i]=false;
        flamePicture[i]=0;
        flameCounter[i]=0;
      }
      shootAble=true;
      for(int i=0;i<5;i++){
        shootX[i]=-shoot.width;
        shootY[i]=0;
      }
      upPressed=false;
      downPressed=false;
      rightPressed=false;
      leftPressed=false;

      image(start2,0,0);
      if(mouseX>210 && mouseX<450 && mouseY>380 && mouseY<410){ // detect mouse location
        image(start1,0,0);
        if(mousePressed){
          gameState=GAME_RUN;
        }
      }
      break;
      
      
    case GAME_RUN:
      // background
      image(bg1,bg2_x-640,0);
      image(bg2,bg2_x,0);
      image(bg2,bg2_x-1280,0);
      bg2_x++;
      bg2_x%=1280;
      
      // hp
      colorMode(RGB);
      fill(255,0,0);
      rect(18,15,hpValue,15);
      image(hp,10,10);
      
      // score
      textFont(f,24);
      textAlign(LEFT);
      fill(255);
      text("Score: "+score,10,470);
      
      // treasure
      image(treasure,treasureX,treasureY);
      
      // fighter
      image(fighter,fighterX,fighterY);
      if(rightPressed)
        fighterX+=fighterSpeed;
      if(leftPressed)
        fighterX-=fighterSpeed;
      if(upPressed)
        fighterY-=fighterSpeed;
      if(downPressed)
        fighterY+=fighterSpeed;      
      // limit fighter location
      fighterX=constrain(fighterX,0,width-fighter.width);
      fighterY=constrain(fighterY,0,height-fighter.height);
      
      // enemy movement
      for(int i=0;i<enemyCount;++i){
        if(enemyX[i]!=-1 || enemyY[i]!=-1){
          image(enemy, enemyX[i], enemyY[i]);
          enemyX[i]+=5;
        }
      }
      // change enemyState
      switch(enemyState){
        case 0:
        case 1:
          if(enemyX[0]>640 && enemyX[1]>640 && enemyX[2]>640 && enemyX[3]>640 && enemyX[4]>640){
            enemyState++;
            addEnemy(enemyState);
          }
          break;
        case 2:
          if(enemyX[0]>640 && enemyX[1]>640 && enemyX[2]>640 && enemyX[3]>640 && enemyX[4]>640 && enemyX[5]>640 && enemyX[6]>640 && enemyX[7]>640){
            enemyState=0;
            addEnemy(enemyState);
          }
          break;
      }
      
      // get treasure
      if(isHit(fighterX, fighterY, fighter.width, fighter.height, treasureX, treasureY, treasure.width, treasure.height)){
        hpValue+=20;
        if(hpValue>200) // limit hpValue
          hpValue=200;
        treasureX=floor(random(640-treasure.width));
        treasureY=floor(random(40,480-treasure.height));
      }
            
      // shoot
      if(shootX[0]>0 && shootX[1]>0 && shootX[2]>0 && shootX[3]>0 && shootX[4]>0)
        shootAble=false;
      else
        shootAble=true;
      for(int i=0;i<5;i++){
        if(shootX[i]==-shoot.width){
          shootNum=i;
          break;
        }
      }
      if(shootFire && shootAble){
        shootX[shootNum]=fighterX;
        shootY[shootNum]=fighterY+shoot.height/2;
      }
      for(int i=0;i<5;i++){
        image(shoot,shootX[i],shootY[i]);
        int closestEnemyNum=closestEnemy(shootX[i],shootY[i]);
        if(closestEnemyNum!=-1 && shootX[i]>enemyX[closestEnemyNum]){
          if(enemyY[closestEnemyNum]>shootY[i]+1)
            shootY[i]+=shootSpeed;
          else if(enemyY[closestEnemyNum]<shootY[i]-1)
            shootY[i]-=shootSpeed;
        }
        shootX[i]-=shootSpeed;
        if(shootX[i]<-shoot.width)
          shootX[i]=-shoot.width;
      }
      shootFire=false;
      
      // hit enemy
      for(int i=0;i<8;i++){
        if(flameFire[i]==false){
          flameNum=i;
          break;
        }
      }
      for(int i=0;i<8;i++){
        // fighter hit enemy
        if(isHit(fighterX, fighterY, fighter.width, fighter.height, enemyX[i], enemyY[i], enemy.width, enemy.height)){
          hpValue-=40;
          flameX[flameNum]=enemyX[i];
          flameY[flameNum]=enemyY[i];
          flameFire[flameNum]=true;
          enemyX[i]+=640;
        }
        // bullet hit enemy
        for(int j=0;j<5;j++){
          if(shootX[j]>0 && isHit(shootX[j], shootY[j], shoot.width, shoot.height, enemyX[i], enemyY[i], enemy.width, enemy.height)){
            scoreChange(20);
            flameX[flameNum]=enemyX[i];
            flameY[flameNum]=enemyY[i];
            flameFire[flameNum]=true;
            enemyX[i]+=640;
            shootX[j]-=640;
          }
        }
      }
      
      // flame
      for(int i=0;i<8;i++){
        if(flameFire[i]){
          image(flame[flamePicture[i]],flameX[i],flameY[i]);
          flameCounter[i]++;
          if(flameCounter[i]>6){
            flameCounter[i]=0;
            flamePicture[i]++;
          }
          if(flamePicture[i]>4){
            flamePicture[i]=0;
            flameFire[i]=false;
          }
        }
      }

      // game end
      if(hpValue<=0){
        gameState=GAME_END;
      }
      
      break;     
      
    case GAME_END:
      image(end2,0,0);
      if(mouseX>210 && mouseX<430 && mouseY>315 && mouseY<345){ // detect mouse location
        image(end1,0,0);
        if(mousePressed){
          gameState=GAME_START;
        }
      }
      break;
  }
}


void keyPressed(){
  // fighter movement
  if(key==CODED){
    switch(keyCode){
      case UP:
        upPressed=true;
        break;
      case DOWN:
        downPressed=true;
        break;
      case LEFT:
        leftPressed=true;
        break;
      case RIGHT:
        rightPressed=true;
        break;
    }
  }
    
  // shoot
  if(key==' ')
    shootFire=true;
}

void keyReleased(){
  if(key==CODED){
    switch(keyCode){
      case UP:
        upPressed=false;
        break;
      case DOWN:
        downPressed=false;
        break;
      case LEFT:
        leftPressed=false;
        break;
      case RIGHT:
        rightPressed=false;
        break;
    }
  }
}


void scoreChange(int value){
  score+=value;
}


// 0-straight, 1-slope, 2-dimond
void addEnemy(int type)
{  
  for(int i=0;i<enemyCount;++i){
    enemyX[i]=-1;
    enemyY[i]=-1;
  }
  switch(type){
    case 0:
      addStraightEnemy();
      break;
    case 1:
      addSlopeEnemy();
      break;
    case 2:
      addDiamondEnemy();
      break;
  }
}

void addStraightEnemy()
{
  float t=random(height-enemy.height);
  int h=int(t);
  for(int i=0; i<5; ++i){
    enemyX[i]=(i+1)*-80;
    enemyY[i]=h;
  }
}

void addSlopeEnemy()
{
  float t=random(height-enemy.height * 5);
  int h=int(t);
  for(int i=0;i<5;++i){
    enemyX[i]=(i+1)*-80;
    enemyY[i]=h+i*40;
  }
}

void addDiamondEnemy()
{
  float t=random(enemy.height*3,height-enemy.height*3);
  int h=int(t);
  int x_axis=1;
  for(int i=0;i<8;++i){
    if (i==0 || i==7){
      enemyX[i]=x_axis*-80;
      enemyY[i]=h;
      x_axis++;
    }
    else if (i==1 || i==5){
      enemyX[i]=x_axis*-80;
      enemyY[i]=h+1*40;
      enemyX[i+1]=x_axis*-80;
      enemyY[i+1]=h-1*40;
      i++;
      x_axis++;      
    }
    else{
      enemyX[i]=x_axis*-80;
      enemyY[i]=h+2*40;
      enemyX[i+1]=x_axis*-80;
      enemyY[i+1]=h-2*40;
      i++;
      x_axis++;
    }
  }
}


boolean isHit(int ax, int ay, int aw, int ah, int bx, int by, int bw, int bh){
  if(ax+aw>=bx && ax<=bx+bw && ay+ah>=by && ay<=by+bh)
    return true;
  else
    return false;
}


int closestEnemy(int x, int y){
  int distance=10000;
  int closestEnemy=-1;
  for(int i=0;i<8;i++){
    if(enemyX[i]>0){
      if(dist(x,y,enemyX[i],enemyY[i])<distance)
        distance=(int)dist(x,y,enemyX[i],enemyY[i]);
        closestEnemy=i;
    }
  }
  return closestEnemy;
}
