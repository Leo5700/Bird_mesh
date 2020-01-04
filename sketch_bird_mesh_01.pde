/*
Bird_mesh
  Realtime триангуляция на Android.
 
  Версия 0.1 101229
*/

import ketai.camera.*;
import blobscanner.*;
import megamu.mesh.*;


KetaiCamera cam;
Detector bd;
int camwidth, camheight;

boolean inversion = true; // черные точки (true) или белые точки

void setup() {
  size(640, 480);
  orientation(LANDSCAPE);
  imageMode(CENTER);
  stroke(220); // цвет и толщина линий
  strokeWeight(2);

  camwidth = 176;
  camheight = 144;
  cam = new KetaiCamera(this, camwidth, camheight, 10); // размер и частота кадров, получаемых с камеры
  cam.start();

  bd = new Detector(this, 255); // порог чувствительности
}

void draw() {
  image(cam, width/2, height/2, width, height); // отображаем кадр
  if (inversion) {
    filter(INVERT); // инвертируем кадр для отображения
  }
  //bd.imageFindBlobs(cam);
  bd.findBlobs(cam.pixels, cam.width, cam.height); // этот метод пошустрее, чем bd.imageFindBlobs
  bd.loadBlobsFeatures();
  bd.findCentroids();

  int bn = bd.getBlobsNumber();
  float[][] points = new float[bn][2];

  for (int i = 0; i < bn; i++) {
    points[i][0] = bd.getCentroidX(i)*width/camwidth;
    points[i][1] = bd.getCentroidY(i)*height/camheight;
  }

  Delaunay myDelaunay = new Delaunay( points );
  float[][] myEdges = myDelaunay.getEdges();

  for (int i=0; i<myEdges.length; i++)
  {
    float startX = myEdges[i][0];
    float startY = myEdges[i][1];
    float endX = myEdges[i][2];
    float endY = myEdges[i][3];
    line( startX, startY, endX, endY );
  }
}

void onCameraPreviewEvent() {
  cam.read();
  if (inversion) {
    cam.filter(INVERT); // инвертируем кадр для анализа
  }
}
