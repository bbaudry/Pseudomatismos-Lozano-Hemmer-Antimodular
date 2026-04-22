#version 150

out vec4 FragColor;

uniform vec2 CtrPt;

uniform float A;
uniform float B;

uniform float CosRz;
uniform float SinRz;

uniform vec3 FillColor;

void main()
{
// rotate this point about the center point

// offset it
  vec2 pt = (gl_FragCoord - CtrPt);

// rotate it
  float temp = (pt.y * CosRz) - (pt.x * SinRz);
  pt.x = pt.x * CosRz + pt.y * SinRz;
  pt.y = temp;

// add the offset back
  pt = pt + CtrPt;

// see if we're inside the ellipse
  float v1 = (gl_FragCoord.x - CtrPt.x)/A;
  float v2 = (gl_FragCoord.y - CtrPt.y)/B;

  float d = (v1*v1)+(v2*v2);

  if (d <= 1.0f) {
    FragColor = vec4(FillColor, d);
  }
  else {
    FragColor = vec4(0);
  }
}
