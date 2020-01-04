/*
Bird_mesh
 Realtime триангуляция на Android.

 Версия 0.2 200103
*/

import ketai.camera.*;
import blobscanner.*;
import megamu.mesh.*;


KetaiCamera cam;
Detector bd;
int camwidth, camheight;
int imgwidth, imgheight;
PImage img;
boolean newFrame=false;

boolean inversion = true; // черные точки (true) или белые точки (false)

void setup() {
  size(640, 480);
  orientation(LANDSCAPE);
  imageMode(CENTER);
  stroke(30); // цвет и толщина линий
  strokeWeight(2);

  camwidth = 640; // размеры кадра видео
  camheight = 480;
  cam = new KetaiCamera(this, camwidth, camheight, 24); // размер и частота кадров, получаемых с камеры
  cam.start();
  imgwidth = 640; // размеры обрабатываемого изображения
  imgheight = 480;
  img = new PImage(imgwidth, imgheight);
  bd = new Detector(this, 255); // порог чувствительности
}

void draw() {

  if (newFrame) {
    newFrame=false;
    img.copy(cam, 0, 0, cam.width, cam.height,
                      0, 0, img.width, img.height);

    image(img, width/2, height/2, width, height); // отображаем кадр

    if (inversion) {
      img.filter(INVERT);
    }

    bd.findBlobs(img.pixels, img.width, img.height); // этот метод пошустрее, чем bd.imageFindBlobs
    bd.loadBlobsFeatures();
    bd.findCentroids();

    int bn = bd.getBlobsNumber();
    float[][] points = new float[bn][2];

    for (int i = 0; i < bn; i++) {
      points[i][0] = bd.getCentroidX(i)*width/imgwidth;
      points[i][1] = bd.getCentroidY(i)*height/imgheight;
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
}

void onCameraPreviewEvent() {
  cam.read();
  newFrame = true;
}
