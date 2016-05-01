import processing.serial.*;
import processing.video.*;

Movie mainMovie;
Movie introMovie;
Movie zoomMovie;
Movie endMovie;

Zoom activeZoom;

Zoom[] zooms;

Serial serial;

int step = 0;

int x = -100;
float speed = 0.0;

int w = 1280;//1067;
int cw = 1280;//800;
int h = 800;

boolean beep = false;
boolean presence = false;

/*
Steps :
* 0 => Pause
* 1 => Présence : vidéo intro
* 2 => Main vidéo
* 3 => Vidéo de contenu
*/

void setup() {
  size(cw, h);

  introMovie = new Movie(this, "intro.mov");
  mainMovie = new Movie(this, "main.mov");
  endMovie = new Movie(this, "end.mov");  

  serial = new Serial(this, Serial.list()[Serial.list().length-1], 9600);
  
  zooms = new Zoom[9];  
  zooms[0] = new Zoom(this, "1A.png", "1A.mov", 44., 49., -100, -33);
  zooms[1] = new Zoom(this, "1B.png", "1B.mov", 44., 49., -33, 33);
  zooms[2] = new Zoom(this, "1C.png", "1C.mov", 44., 49., 33, 100);
  zooms[3] = new Zoom(this, "2D.png", "2D.mov", 94., 99., -100, 0);
  zooms[4] = new Zoom(this, "2E.png", "2E.mov", 94., 99., 0, 100);
  zooms[5] = new Zoom(this, "3F.png", "3F.mov", 251., 256., -100, 100);
  zooms[6] = new Zoom(this, "4G.png", "4G.mov", 303., 308., -100, 0);
  zooms[7] = new Zoom(this, "4H.png", "4H.mov", 303., 308., 0, 100);
  zooms[8] = new Zoom(this, "5I.png", "5I.mov", 395., 400., -100, 100);
}


void draw() {
  
  println("draw " + step); 
  
  introMovie.read();
  image(introMovie, 0, 0, cw, h);
  
  if(serial.available() > 0)
   {
     String str = serial.readStringUntil('\n');
     println(str);
     
     if (str != null) {
       String[] parts = str.split(",");
     
       if (parts.length == 3) {       
         presence = (parts[0].equals("1"));
         //int speedParam = Integer.parseInt(parts[1]);
         //speed = (speedParam -50) / 25.; // entre 0 et 100. 50 = je bouge pas
         //if (speed == 0) {
         //  speed = .5;
         //}
         speed = 2.5;
         int xParam = Integer.parseInt(parts[2].trim());
         x = 2*xParam; // entre 0 et 100. 50 = au milieu
         beep = (Integer.parseInt(parts[0]) == 1); // 0 ou 1. 1 = on beep
       }
     }
   }

  if (step == 0) {
    //if (presence || beep) {
      toStep1();
    //}
  }
  
  if (step == 1) {
    if (beep) {
      toStep2();
    }
    
    // Vieux hack tout pourri pour détecter la fin de la vidéo
    // La duration ne semble dispo qu'après quelques frames
    float remaining = introMovie.duration() - introMovie.time();
    if (introMovie.time() < 2 || remaining > 0.1) { 
      introMovie.read();
      image(introMovie, 0, 0, cw, h);
    } else {
      toStep2();
    }
  }  
  
  if (step == 2) {
    
    mainMovie.speed(speed);
    println(speed);

    float remaining = mainMovie.duration() - mainMovie.time();
    if (mainMovie.time() < 2 || remaining > 0.1) {
      mainMovie.read();
      image(mainMovie, x, 0, w, h);
    } else {
      toStep4();
    }
    
    for (int i=0; i<zooms.length; i++) {
      activeZoom = null;
      if (zooms[i].hasOverlay(mainMovie.time(), x)) {
        activeZoom = zooms[i];
        image(activeZoom.overlay, x, 0, w, h);
        if (beep) {
          toStep3();
        }
        i = zooms.length; // Trick pour faire un break;
      }
    }
  }
  
  if (step == 3) {
    activeZoom.movie.read();
    image(activeZoom.movie, x, 0, w, h);
    
    if (speed < 0 || beep) {
      toStep2();
    }
  }
  
  if (step == 4) {
    float remaining = endMovie.duration() - endMovie.time();
    println(remaining);
    if (endMovie.time() < 2 || remaining > 0.1) {
      endMovie.read();
      image(endMovie, 0, 0, w, h);
    } else {
      toStep0();
    }
  }
}

void toStep0() {
  println("Mise en veille");                        
  step = 0;
  endMovie.stop();
  mainMovie.stop();
    
  if (activeZoom != null) {
    activeZoom.movie.stop();
  }
  
  introMovie.stop();
}

void toStep1() {
  println("Démarrage de la vidéo intro");                        
  step = 1;
  introMovie.play();
}

void toStep2() {
  print("Passage en main");     
  step = 2;
  
  introMovie.stop();
  mainMovie.play();
  
  if (activeZoom != null) {
    activeZoom.movie.stop();
  }
}

void toStep3() {
  print("Passage en annecdote");
  step = 3;
  
  mainMovie.pause();
  activeZoom.movie.play();      
}

void toStep4() {
  print("Passage en vidéo de fin");
  step = 4;
  
  mainMovie.stop();
  if (activeZoom != null) {
    activeZoom.movie.stop();
  }
  
  endMovie.play();
}


class Zoom {
  
  PImage overlay;
  Movie movie;
  
  float timeFrom;
  float timeTo;
  
  int fromX;
  int toX;

  Zoom(PApplet main, String overlayName, String movieName, float ptimeFrom, float ptimeTo, int pfromX, int ptoX) {
    overlay = loadImage(overlayName);
    movie = new Movie(main, movieName);
    timeFrom = ptimeFrom;
    timeTo = ptimeTo;
    fromX = pfromX;
    toX = ptoX;
  }

  boolean hasOverlay(float time, int x) {
    
    // Time
    if (time < timeFrom || time > timeTo) {
      return false;
    }
    
    // Angle
    if (x < fromX || x > toX) {
      return false;
    }
    
    return true;
  }
}

/*
boolean sketchFullScreen() {
  return true;
}
*/
