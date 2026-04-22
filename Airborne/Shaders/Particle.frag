#version 400
#extension GL_EXT_texture_array : enable

uniform sampler2DArray ParticleTex;
uniform vec3 FillColor;

in float CharI;
in float FragAlpha;

layout ( location = 0 ) out vec4 FragColor;

void main()
{
  vec3 param = vec3(gl_PointCoord, CharI);

// discard black pixels from the source texture
  FragColor = texture2DArray(ParticleTex, param);
  if ((FragColor.r == 0) && (FragColor.g == 0) && (FragColor.b == 0)) {
    discard;
  }

  if (FragAlpha == 0.0) {
    FragColor = vec4(1.0,0.0,0.0,1.0);
  }
  else if (FragAlpha == 1.0) {
    FragColor = vec4(0.0,1.0,0.0,1.0);
  }
  else if (FragAlpha == 2.0) {
    FragColor = vec4(0.0,0.0,1.0,1.0);
  }
  else if (FragAlpha == 1.0) {
    FragColor = vec4(1.0,1.0,0.0,1.0);
  }

// set the color to the fill color plus the FragAlpha
  FragColor = vec4(FillColor,FragAlpha);
}
