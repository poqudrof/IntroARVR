

int imageWidth = 310; // mm
int imageHeight = 268; // mm 

void settings(){
    size(1920, 1080, P3D);
}

float r1, r2;
float pxPerMm = (float) imageWidth / 1920.0;

void setup(){
    println( pxPerMm);
}

void draw(){

    // Idée: 3 post-its sélectionnés par un 4ième.
    scale(1f / pxPerMm);
    rect(42, 42, 76, 76);
}

    
