PImage[] layersBack = new PImage[4];
float[] layerXBack = new float[4];
PImage[] layersFore = new PImage[2];
float[] layerXFore = new float[2];
PImage[] kucing = new PImage[5];
PImage kereta, upgradeKereta, upgradeStasiun, splashArt, koin, 
gondangdiaUI, cikiniUI, keretaUI, barKoin;

boolean isGameStart = false;
float speed = 0;
int capacityStasiun = 10;
int capacityKereta = 5;
// Array jumlah penumpang
int[] stasiunCikini = new int[capacityStasiun];
int[] stasiunGondangdia = new int[capacityStasiun];
int[] penumpangKereta = new int[capacityKereta];

// Posisi X kucing di setiap stasiun
float[] kucingXCikini = new float[capacityStasiun];
float[] kucingXGondangdia = new float[capacityStasiun];

// Counter untuk jumlah penumpang
int penumpangDiCikini, penumpangDiGondangdia, penumpangDiKereta = 0;
// Tracking penumpang dari stasiun asal
int penumpangDariCikini = 0, penumpangDariGondangdia = 0;

// Timer untuk spawn penumpang dan boarding masuk kereta
float lastSpawnTimeCikini, lastSpawnTimeGondangdia, lastBoardingTime = 0;
float minSpawnTime = 5.0;
float maxSpawnTime = 10.0; 
float enterInterval = 1;

// Sistem poin
int totalPoin = 0;
int poinPerPenumpang = 10;
int biayaUpgrade = 100;

// Posisi dan ukuran upgrade
int upgradeKeretaX = 890, upgradeKeretaY = 800;
int upgradeStasiunX = 1030, upgradeStasiunY = 800;
int tombolWidth = 92, tombolHeight = 110;

// sound
import ddf.minim.*;
Minim minim;
AudioPlayer coinSound, bgm, kucingNaik, koinKurang, trainHorn;

// lighting
boolean isMovingRight = false;
boolean isMovingLeft = false;

// Firefly
int numFireflies = 500;
float[] x = new float[numFireflies];
float[] y = new float[numFireflies];
float[] opacity = new float[numFireflies];
int[] targetOpacity = new int[numFireflies];
boolean allFirefliesDimmed = true; // Kontrol hanya panggil jika semua redup

void setup() {
  size(1920, 940);
  frameRate(24);
  PFont font;
  font = createFont("Poppins-Bold.otf", 20);
  textFont(font, 20);

  // layer parallax
  for (int i = 0; i < layersBack.length; i++) {
    layersBack[i] = loadImage("Asset/layer" + (i+1) + ".png");
    layerXBack[i] = width / 2;
  }

  for (int i = 0; i < layersFore.length; i++) {
    layersFore[i] = loadImage("Asset/layer" + (i+5) + ".png");
    layerXFore[i] = width / 2;
  }
  
  for (int i = 0; i < kucing.length; i++) {
    kucing[i] = loadImage("Character/kucing" + (i+1) + ".png");
  }
  
  kereta = loadImage("Asset/kereta.png");
  splashArt = loadImage("Asset/splashscreen.png");

  upgradeKereta = loadImage("UI/UpgradeKereta.png");
  upgradeKereta.resize(tombolWidth, tombolHeight);

  upgradeStasiun = loadImage("UI/UpgradeStasiun.png");
  upgradeStasiun.resize(tombolWidth, tombolHeight);
  koin = loadImage("UI/Koin.png");
  barKoin = loadImage("UI/BarKoin.png");
  keretaUI = loadImage("UI/KeretaUI.png");
  gondangdiaUI = loadImage("UI/GondangdiaUI.png");
  cikiniUI = loadImage("UI/CikiniUI.png");

  // inisialisasi minim dan load audio
  minim = new Minim(this);
  bgm = minim.loadFile("Nyan_Cat.mp3");
  coinSound = minim.loadFile("coinSound.wav");
  kucingNaik = minim.loadFile("kucingNaik.mp3");
  koinKurang = minim.loadFile("koinKurang.mp3");
  trainHorn = minim.loadFile("TrainHorn.mp3");

  bgm.setGain(-8);
  coinSound.setGain(0);
  kucingNaik.setGain(8);
  koinKurang.setGain(2);

  bgm.loop();
}

void draw() {
  background(194, 194, 194);

  ParallaxEffect();
  DrawUI();
  HandleSpawn();
  HandleBoarding();
}

void ParallaxEffect() {
  for (int i = 0; i < layersBack.length; i++) {
    imageMode(CENTER);
    image(layersBack[i], layerXBack[i], height / 2);

    float layerSpeed = speed * (i) / 5.0; // Kecepatan: 25, 20, 15, 10, 5
    layerXBack[i] += layerSpeed;

    // batas kiri dan kanan untuk layer
    float maxKiri = layersBack[i].width / 2; // x = 4560px, 3840px, 3120px, 2400px, 1680px
    float maxKanan = -layersBack[i].width / 2 + width; // x = -2640px, -1920px, -1200px, -480px,
    layerXBack[i] = constrain(layerXBack[i], maxKanan, maxKiri);
  }
  
  if (allFirefliesDimmed) {
    GenerateFirefly(); 
  }
  DrawFireflies(); 
  
  if (isMovingRight == true) {
    LightingRight();  
  } else if (isMovingLeft == true) {
    LightingLeft();  
  }
  
  image(kereta, width / 2, height / 2);

  for (int i = 0; i < layersFore.length; i++) {
    imageMode(CENTER);
    image(layersFore[i], layerXFore[i], height / 2);

    float layerSpeed = speed * (i + 4) / 5.0; // Kecepatan: 25, 20, 15, 10, 5
    layerXFore[i] += layerSpeed;

    // batas kiri dan kanan untuk layer
    float maxKiri = layersFore[i].width / 2; // x = 4560px, 3840px, 3120px, 2400px, 1680px
    float maxKanan = -layersFore[i].width / 2 + width; // x = -2640px, -1920px, -1200px, -480px,
    layerXFore[i] = constrain(layerXFore[i], maxKanan, maxKiri);
  }
}

void LightingRight() { 
  int lightX = (width / 2) + 330; 
  int lightY = (height / 2) + 130; 
  int lightWidth = width / 2; 
  int lightHeight = height / 2;

  // Warna dasar dengan efek transisi lembut
  for (int i = 0; i < 20; i++) {
    float alpha = map(i, 0, 19, 40, 0); 
    fill(239, 221, 99, alpha); 
    noStroke(); 
    beginShape();
    vertex(lightX, lightY); 
    vertex(lightX + lightWidth - (i * 20), lightY - lightHeight + (i * 25)); 
    vertex(lightX + lightWidth - (i * 20), lightY + lightHeight - 400 - (i * 25)); 
    endShape(CLOSE);
  }
}

void LightingLeft() { 
  int lightX = (width / 2) - 330; 
  int lightY = (height / 2) + 130; 
  int lightWidth = width / 2; 
  int lightHeight = height / 2;

  // Warna dasar dengan efek transisi lembut
  for (int i = 0; i < 20; i++) {
    float alpha = map(i, 0, 19, 40, 0); 
    fill(239, 221, 99, alpha); 
    noStroke(); 
    beginShape();
    vertex(lightX, lightY); 
    vertex(lightX - lightWidth + (i * 20), lightY - lightHeight + (i * 25)); 
    vertex(lightX - lightWidth + (i * 20), lightY + lightHeight - 400 - (i * 25)); 
    endShape(CLOSE);
  }
}

void GenerateFirefly() {
  allFirefliesDimmed = false; // Hanya panggil lagi setelah redup semua
  for (int i = 0; i < numFireflies; i++) {
    // Set posisi baru
    x[i] = random(9120);
    y[i] = random(940);
    opacity[i] = 0; 
    targetOpacity[i] = 100; 
  }
}

void DrawFireflies() {
  boolean allDimmedCheck = true; 

  for (int i = 0; i < numFireflies; i++) {
    opacity[i] += (targetOpacity[i] - opacity[i]) * 0.15;

    if (opacity[i] >= 99.9) { // Ubah target jika mencapai batas
      targetOpacity[i] = 0; 
    } else if (opacity[i] <= 0.1) {
      targetOpacity[i] = 100;
    }
    
    if (opacity[i] > 0.1) { // Cek apakah semua sudah redup
      allDimmedCheck = false; 
    }
    
    x[i] += speed / 3; // **Gerakan Kunang-kunang**

    noStroke();
    fill(239, 221, 99, opacity[i]);
    ellipse(x[i], y[i], 10, 10);
  }

  // Set status jika semua redup
  allFirefliesDimmed = allDimmedCheck;
}

void DrawUI() {
  // upgrade
  imageMode(CENTER);
  fill(255);
  textSize(16);
  textAlign(CENTER, TOP);

  image(upgradeKereta, upgradeKeretaX, upgradeKeretaY);
  image(upgradeStasiun, upgradeStasiunX, upgradeStasiunY);
  text("100 Koin", upgradeKeretaX + 20, upgradeKeretaY + 54);
  text("100 Koin", upgradeStasiunX + 20, upgradeKeretaY + 54);
  image(koin, upgradeKeretaX - 30, upgradeKeretaY + 60);
  image(koin, upgradeStasiunX - 30, upgradeStasiunY + 60);

  image(gondangdiaUI, (width/2) - 850, height/2);
  image(cikiniUI, (width/2) + 850, height/2);
  fill(53, 121, 122);
  textSize(34);
  text(penumpangDiGondangdia, (width/2) - 840, (height/2) + 10);
  text(penumpangDiCikini, (width/2) + 840, (height/2) + 10);

  textSize(50);
  image(keretaUI, (width/2) - 120, (height/2) - 100);
  text((penumpangDariGondangdia + penumpangDariCikini), (width/2) - 120, (height/2) - 130);

  fill(255);
  textSize(34);
  textAlign(RIGHT, TOP);
  image(barKoin, (200), 50);
  text(totalPoin, (200) + 80, 38);

  if (isGameStart == false) {
    image(splashArt, width / 2, height / 2);
  }
}

ArrayList<PImage> kucingGondangdia = new ArrayList<PImage>();
ArrayList<PImage> kucingCikini = new ArrayList<PImage>();
void HandleSpawn() { 
  // Cek spawn di stasiun Gondangdia
  if (millis() - lastSpawnTimeGondangdia > random(minSpawnTime * 1000, maxSpawnTime * 1000) && isGameStart) {
    if (penumpangDiGondangdia < stasiunGondangdia.length) {
      kucingGondangdia.add(RandomCat());
      penumpangDiGondangdia++;
      lastSpawnTimeGondangdia = millis();
    }
  }

  // Cek spawn di stasiun Cikini
  if (millis() - lastSpawnTimeCikini > random(minSpawnTime * 1000, maxSpawnTime * 1000) && isGameStart) {
    if (penumpangDiCikini < stasiunCikini.length) {
      kucingCikini.add(RandomCat());
      penumpangDiCikini++;
      lastSpawnTimeCikini = millis();
    }
  }

  imageMode(CENTER);
  // Tampilkan kucing yang sudah di-spawn
  for (int i = 0; i < kucingGondangdia.size(); i++) {
    image(kucingGondangdia.get(i), kucingXGondangdia[i], height / 2 + 200);
    kucingXGondangdia[i] = layerXFore[0] - 3000 + (100 - (i * 60));
  }

  for (int i = 0; i < kucingCikini.size(); i++) {
    image(kucingCikini.get(i), kucingXCikini[i], height / 2 + 200);
    kucingXCikini[i] = layerXFore[0] + 2650 + (100 + (i * 60));
  }
}

// Fungsi untuk memilih kucing secara acak
PImage RandomCat() {
  int nomorKucing = int(random(1, 6));  // Angka 1-5
  switch (nomorKucing) {
    case 1: return kucing[0];
    case 2: return kucing[1];
    case 3: return kucing[2];
    case 4: return kucing[3];
    case 5: return kucing[4];
    default: return kucing[0];  // Default jika error
  }
}


void HandleBoarding() {
  // Di stasiun Gondangdia (kiri)
  if (layerXFore[1] >= 4560) {
    isMovingLeft = false;
    // Hanya menurunkan penumpang dari Cikini
    if (penumpangDariCikini > 0) {
      if (millis() - lastBoardingTime > enterInterval * 1000) {
        penumpangDariCikini--;
        totalPoin += poinPerPenumpang;
        coinSound.rewind();
        coinSound.play();
        lastBoardingTime = millis();
      }
    }
    // Menaikkan penumpang baru dari Gondangdia
    else if (penumpangDiGondangdia > 0 && (penumpangDariCikini + penumpangDariGondangdia) < penumpangKereta.length) {
      if (millis() - lastBoardingTime > enterInterval * 1000) {
        penumpangDiGondangdia--;
        penumpangDariGondangdia++;
        kucingNaik.rewind();
        kucingNaik.play();
        lastBoardingTime = millis();
        kucingGondangdia.remove(0);
      }
    }
  }

  // Di stasiun Cikini (kanan)
  if (layerXFore[1] <= -2640) {
    isMovingRight = false;
    // Hanya menurunkan penumpang dari Gondangdia
    if (penumpangDariGondangdia > 0) {
      if (millis() - lastBoardingTime > enterInterval * 1000) {
        penumpangDariGondangdia--;
        totalPoin += poinPerPenumpang;
        coinSound.rewind();
        coinSound.play();
        lastBoardingTime = millis();
      }
    }
    // Menaikkan penumpang baru dari Cikini
    else if (penumpangDiCikini > 0 && (penumpangDariCikini + penumpangDariGondangdia) < penumpangKereta.length) {
      if (millis() - lastBoardingTime > enterInterval * 1000) {
        penumpangDiCikini--;
        penumpangDariCikini++;
        kucingNaik.rewind();
        kucingNaik.play();
        lastBoardingTime = millis();
        kucingCikini.remove(0);  
    }
    }
  }
}

void keyPressed() {
  isGameStart = true;

  if (keyCode == LEFT && isGameStart == true) {
    speed = 15;
    isMovingLeft = true;
    isMovingRight = false;
    trainHorn.rewind();
    trainHorn.play();
  } else if (keyCode == RIGHT && isGameStart == true) {
    speed = -15;
    isMovingLeft = false;
    isMovingRight = true;
    trainHorn.rewind();
    trainHorn.play();
  }
}

void mousePressed() {
  isGameStart = true;

  // Tombol Upgrade Kereta
  if (mouseX > upgradeKeretaX - tombolWidth / 2 && mouseX < upgradeKeretaX + tombolWidth / 2 &&
    mouseY > upgradeKeretaY - tombolHeight / 2 && mouseY < upgradeKeretaY + tombolHeight / 2) {
    if (totalPoin >= biayaUpgrade) {
      totalPoin -= biayaUpgrade;
      capacityKereta += 5;

      penumpangKereta = new int[capacityKereta];
    } else {
      koinKurang.rewind();
      koinKurang.play();
    }
  }

  // Tombol Upgrade Stasiun
  if (mouseX > upgradeStasiunX - tombolWidth / 2 && mouseX < upgradeStasiunX + tombolWidth / 2 &&
    mouseY > upgradeStasiunY - tombolHeight / 2 && mouseY < upgradeStasiunY + tombolHeight / 2) {
    if (totalPoin >= biayaUpgrade) {
      totalPoin -= biayaUpgrade;
      capacityStasiun += 5;

      stasiunCikini = new int[capacityStasiun];
      stasiunGondangdia = new int[capacityStasiun];
      kucingXCikini = new float[capacityStasiun];
      kucingXGondangdia = new float[capacityStasiun];
    } else {
      koinKurang.rewind();
      koinKurang.play();
    }
  }
}
