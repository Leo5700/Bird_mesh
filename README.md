# Bird_mesh

### Как сделать сетку на птицах, не вдаваясь в детали
> На правах рукописи

Осень. Пасмурно, я смотрю на птиц, на фоне серого неба они кажутся точками, разбросанными на листе бумаге. Что если провести между ними линии &minus; наверное, это будет красиво.


Это было давно, во времена, когда по лицу нашей планеты сновали люди с бронебойными nokia, а слово “раскладушка” получало новое значение.
Кто бы мог подумать тогда, что эта задачка может быть решена при помощи мобильника с тачскрином вместо клавиатуры.


Всё делается просто, всё делается в лоб, всё некрасиво &minus; но &minus; это работает, причём, работает путём тупой компиляции из типовых примеров, сделано на ходу, в прямом смысле на ходу, в метро, в электричках, на эскалаторах.


Если Вы не владелец огрызка и хотите немного поразвлекаться реалтайм-триангуляцией Делоне с распознаванием образов &minus; вот всё, что следует проделать:
1. Установить на телефон приложение **APDE** (https://play.google.com/store/apps/details?id=com.calsignlabs.apde)
1. Посмотреть, как добавить в **APDE** новые библиотеки (https://github.com/Calsign/APDE/wiki/Installing-Contributed-Libraries). В моем случае, выбирать `.zip` нужно было при помощи родного проводника телефона, иначе библиотеки приходится ставить врукопашную. Впрочем, по той же инструкции.
1. Скачать и поставить из `.zip` библиотеки: **Ketai** (http://ketai.org/download/) для захвата видео (ну кто бы мог подумать, для захвата видео подошла библиотека прямо из примера), **Blobscanner** (https://sites.google.com/site/blobscanner/Download) для поиска точек на видеокадре и **Mesh** (http://leebyron.com/mesh/) для отрисовки треугольной сетки на обнаруженных точках.
1. Затем, в **APDE** позапускать примеров `Library Examples` из библиотек **Ketai** и **Blobscanner**. Особенное внимание обратить на `CameraGettingStarted` и `blob_centroid\getCentroidX_getCentroidY`. В библиотеке **Mesh** примеров нет, есть куски кода на сайте. Куски хорошие, один минус &minus; из них не следует, что для запуска библиотеки нужно вбить не `import mesh.*`, а `import megamu.mesh.*`
1. Далее, понадобится подобрать разрешение камеры, чтобы всё происходящее не слишком уж тормозило, заколхозить инвертирование кадра, ибо Blobscanner ищет белое на чёрном, а нам нужно строго наоборот, убить лишние куски кода, чтобы всё это хоть немного напоминало программу и написать пару слов о происходящем, чем я сейчас и занимаюсь.

Ниже, привожу код. Если Вы перфекционист хотя бы на 1% &minus; закройте глаза.


```C
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
  cam = new KetaiCamera(this, camwidth, camheight, 10); // размер и частота кадров камеры
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

```
