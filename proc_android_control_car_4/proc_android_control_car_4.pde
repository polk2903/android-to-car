import ketai.sensors.*;
import ketai.net.bluetooth.*;
import ketai.ui.*;
import ketai.net.*;
import android.content.Intent;
import android.os.Bundle;

KetaiBluetooth bt;
KetaiSensor sensor;
boolean isConfiguring = true;
KetaiList klist;
String btName="";
 
ArrayList devicesDiscovered = new ArrayList();
float accelerometerX, accelerometerY, accelerometerZ;
color fillUp = color (0);
color fillLeft = color (0);
color fillDown = color (0);
color fillRight = color (0);
color fillSpace = color (0);
color colorActive = color (255,0,0);
color colorDisactive = color (0);
int portNumber = -1;
int touchX=0, touchY=0;
String header="header", footer="footer";
String inBuffer="", outBuffer="";

//--------------------------------------------------------------------------------------

void onCreate(Bundle savedInstanceState) {
 super.onCreate(savedInstanceState);
 bt = new KetaiBluetooth(this);
}
 
void onActivityResult(int requestCode, int resultCode, Intent data) {
 bt.onActivityResult(requestCode, resultCode, data);
}
//----------------------------------------------------------------------------------------
void setup() 
{
  background(255); 
  fullScreen();
  sensor = new KetaiSensor(this);
  sensor.start();
  orientation(PORTRAIT);
  touchX=width/2; touchY=height/2;
  textAlign(CENTER, TOP);
  textSize(20);
  bt.start();
  isConfiguring = true;
  strokeWeight(2);
 }
//--------------------------------------------------------------

int lastSec=59;
boolean pressedUp=false, pressedDown=false;

void draw()
{
 background(255); 
 if (isConfiguring)
 {
//инициализация bluetooth   
  background(78, 93, 75);
  klist = new KetaiList(this, bt.getPairedDeviceNames());
  isConfiguring = false;
 }
 else
 {
//учет секунд и проверка времени после последнего отклика машины
  int newSec=second();
  if (lastSec>newSec) lastSec=newSec;  if(inBuffer==null) inBuffer=""; if(outBuffer==null) outBuffer=""; 
  if(newSec-lastSec>4) {footer=btName+", Car offline"; header=""; outBuffer="status"+'\n'; lastSec=newSec;};  
  
//рисуем хэдер и футер 
  stroke(0,0,0);
  fill(255); rect(1,1,width-2,30);   fill(0); text(header, width/2, 10); 
  fill(255); rect(1, height-30 , width-2,29);  fill(0); text(footer, width/2 , height-20); 
  
// проверяем акселерометр и устанавливаем цвета прямоугольников  
  if (accelerometerY < 3 && accelerometerY > -3 && accelerometerX < 3 && accelerometerX > -3) fillSpace=colorActive; 
    else fillSpace=colorDisactive;
  if (accelerometerY > 3) fillDown=colorActive; else fillDown=colorDisactive;
  if (accelerometerY < -3) fillUp=colorActive; else fillUp=colorDisactive;
  if (accelerometerX > 3) fillLeft=colorActive; else fillLeft=colorDisactive;
  if (accelerometerX < -3) fillRight=colorActive; else fillRight=colorDisactive;
  
//проверяем джостик и устанавливаем цвета прямоугольников
  if(touchY < height/2-70) {fillUp=colorActive;fillDown=colorDisactive;fillSpace=colorDisactive;};

//проверяем изменился ли статус кнопок и посылаем команды в outBuffer
  if(pressedUp==false && fillUp==colorActive) {pressedUp=true; outBuffer+="pressedUp"+'\n';};
  if(pressedUp==true && fillUp==colorDisactive) {pressedUp=false; outBuffer+="releasedUp"+'\n';};

//русуем
  noStroke();
  fill(fillUp);                   
  rect(width/2-50, height/2-100-50-20, 100, 100);
  fill(fillLeft);
  rect(width/2-50-20-100,height/2-50, 100, 100);
  fill(fillSpace);
  rect(width/2-50, height/2-50, 100, 100);
  fill(fillRight);
  rect(width/2+50+20, height/2-50, 100, 100);
  fill(fillDown);
  rect(width/2-50, height/2+50+20, 100, 100);
  noFill();
  stroke(0,0,255);
  ellipse(width/2-int(width/2.0/10.0*accelerometerX), height/2+int(height/2.0/10.0*accelerometerY), 30, 30);
  ellipse(width/2-int(width/2.0/10.0*accelerometerX), height/2+int(height/2.0/10.0*accelerometerY), 15, 15);
  stroke(0,255,0);
  ellipse(int(touchX), int(touchY), 40, 40);
  fill(0);
  text("x: " + nfp(accelerometerX, 1, 1) + " ; " +
       "y: " + nfp(accelerometerY, 1, 1) + " ; " +
       "z: " + nfp(accelerometerZ, 1, 1), width/2, height-50);

//обмен данными с машиной  
  if (outBuffer!="" && outBuffer!=null) 
    { print("Send to car: "+outBuffer); byte[] data = outBuffer.getBytes(); bt.broadcast(data); outBuffer="";};
    
  if (inBuffer!="") 
    { header="Get from car:"+inBuffer; print(header); lastSec=newSec; footer=btName+", Car is ready to drive";inBuffer=""; };
    
//возвращаем джостик в центр    
 if (touchX > width/2)  touchX--; if (touchX < width/2)  touchX++; 
 if (touchY > height/2)  touchY--; if (touchY < height/2)  touchY++; 
// saveFrame("frames/####.tif");  
 }; 
} 

void onAccelerometerEvent(float x, float y, float z)
{
  accelerometerX = x;
  accelerometerY = y;
  accelerometerZ = z;
}
//--------------------------------------------------------------
/*
void keyPressed() {  
  
  if (keyCode == UP || key == 'w' || key == 'W' || key == 'Ц' || key == 'ц') {fillUp = colorActive; mywrite("pressedUp"+'\n');}; 
  if (keyCode == LEFT || key == 'a' || key == 'A' || key == 'Ф' || key == 'ф') {fillLeft = colorActive; mywrite("pressedLeft"+'\n');}; 
  if (keyCode == DOWN || key == 's' || key == 'S' || key == 'Ы' || key == 'ы') {fillDown = colorActive; mywrite("pressedDown"+'\n');}; 
  if (keyCode == RIGHT || key == 'd' || key == 'D' || key == 'В' || key == 'в') {fillRight = colorActive; mywrite("pressedRight"+'\n');};  
  if (key == ' ')    {println("Нажат пробел"); mywrite("pressedSpace"+'\n'); fillSpace = colorActive;};
    
//  if (int(keyCode) >=48 && int(keyCode)<=57) {stopSerialPort(); portNumber=int(keyCode) - 48; println(portNumber); openSerialPort();};
  
  }
//--------------------------------------------------------------
  
void keyReleased() {
    if (keyCode == UP || key == 'w'|| key == 'W' || key == 'Ц' || key == 'ц') {fillUp = colorDisactive; mywrite("releasedUp"+'\n');};
    if (keyCode == LEFT || key == 'a' || key == 'A' || key == 'Ф' || key == 'ф') {fillLeft = colorDisactive; mywrite("releasedLeft"+'\n');};
    if (keyCode == DOWN || key == 's' || key == 'S' || key == 'Ы' || key == 'ы') {fillDown = colorDisactive; mywrite("releasedDown"+'\n');}; 
    if (keyCode == RIGHT || key == 'd' || key == 'D' || key == 'В' || key == 'в') {fillRight = colorDisactive; mywrite("releasedRight"+'\n');}; 
    if (key == ' ')    {println("Отпущен пробел"); mywrite("releasedSpace"+'\n'); fillSpace = colorDisactive;}; 
  }
  
//--------------------------------------------------------------
  
void mywrite (String s) {
  
  if (outBuffer.length()>150) outBuffer=""; outBuffer+=s; 
       
}
*/
//--------------------------------------------------------------
void mouseClicked(){
  
   touchX = mouseX;
   touchY = mouseY;
  
}

void mouseDragged(){
  
   touchX = mouseX;
   touchY = mouseY;
  
}
//--------------------------------------------------------------

void onKetaiListSelection(KetaiList klist) {
 
 String selection = klist.getSelection();
 bt.connectToDeviceByName(selection);
 btName=selection;
 klist = null;
 
}

//-------------------------------------------------------------- 
 
void onBluetoothDataEvent(String who, byte[] data) {
 
 if (isConfiguring) return;
 inBuffer = new String(data);
 if(inBuffer.length() > 150) inBuffer = "";
 if(inBuffer==null) inBuffer="";
 
}
//--------------------------------------------------------------