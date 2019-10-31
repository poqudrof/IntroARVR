////////////////////////////////////////////////////////
///////////////// OpenGL Camera ///////////////////////
//////////////////////////////////////////////////////



void setCamera(PVector p){

    // Processing hack, invert Y axis (part 1/2)
    PVector cameraPos = new PVector(-p.x, -p.y, p.z);

    PGraphicsOpenGL graphics = (PGraphicsOpenGL) g;
    
    graphics.camera(cameraPos.x, cameraPos.y, cameraPos.z,
		    cameraPos.x, cameraPos.y, 0,
		    0, 1, 0);

    float nearFactor = nearPlane / cameraPos.z;
    float left   = nearFactor * (- screenSize.x / 2f - cameraPos.x);
    float right  = nearFactor * (  screenSize.x / 2f - cameraPos.x);
    float top    = nearFactor * (  screenSize.y / 2f - cameraPos.y);
    float bottom = nearFactor * (- screenSize.y / 2f - cameraPos.y);

    graphics.frustum(left, right, bottom, top, nearPlane, farPlane);

    // Processing hack, invert Y axis  (part 2/2)
    graphics.projection.m11 = -graphics.projection.m11;

}



