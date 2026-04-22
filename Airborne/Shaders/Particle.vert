#version 400

subroutine void RenderPassType();
subroutine uniform RenderPassType RenderPass;

const float HOME_MODE = 0.0;  // sitting at home
const float MOVE_MODE = 1.0;  // moving about
const float WAIT_MODE = 2.0;  // waiting for home to become calm
const float FADE_MODE = 3.0;  // fading in

layout (location = 0) in vec3  VertexPosition;
layout (location = 1) in vec3  VertexHomePos;
layout (location = 2) in vec3  VertexMSTA; // Mode.StartTime,Alpha
layout (location = 3) in float VertexTextureI;

out vec3  Position;  // To transform feedback
out vec3  HomePos;   // To transform feedback
out vec3  MSTA;      // To transform feedback

out float TextureI;  // To transform feedback

out float FragAlpha; // To fragment shader
out float CharI;     // To fragment shader

uniform sampler2D VelocityTexture;
uniform sampler2D DensityTexture;

uniform float RenderW;
uniform float RenderH;

uniform float FadeTime;

uniform int Reset;

uniform float HomeThreshold;
uniform float MoveThreshold;

uniform float Time;

uniform float WaitAlpha;

subroutine (RenderPassType)

void update()
{
  Position = VertexPosition;
  HomePos = VertexHomePos;
  MSTA = VertexMSTA;
  TextureI = VertexTextureI;

// read the velocity
  vec2 texPos;
  texPos.x = (Position.x + 1.0) / 2.0;
  texPos.y = (Position.y + 1.0) / 2.0;

  vec4 v = texture2D(VelocityTexture, texPos);
  float mag = (v.x * v.x) + (v.y * v.y);

// reset if we've been told to
  if (Reset > 0.0) {
    Position = HomePos;
    MSTA.x = HOME_MODE;  // mode
    MSTA.y = 1.0;        // alpha
    return;
  }

// if we're in the home position, see if the velocity is enough to break us free
  if (MSTA.x == HOME_MODE) {
    Position = VertexHomePos;
    MSTA.z = 1.0;
    if (mag >= MoveThreshold) {
      MSTA.x = MOVE_MODE;
    }
  }

// if we're moving update our position
  else if (MSTA.x == MOVE_MODE) {
    Position.x += v.x / RenderW;
    Position.y += v.y / RenderH;

// get the alpha from the density
    MSTA.z = texture2D(DensityTexture, texPos).x;

    if (MSTA.z < WaitAlpha) {
      MSTA.x = WAIT_MODE;
    }
  }

// fading in
  else if (MSTA.x == FADE_MODE) {
    Position = HomePos;
    MSTA.z = (Time - MSTA.y) / FadeTime;
  //  MSTA.z = 1.0;

// if we're completely faded in switch to HOME_MODE
    if (MSTA.z >= 1.0) {
      MSTA.z = 1.0;
      MSTA.x = HOME_MODE;
    }
  }

// waiting for calm at home
  else if (MSTA.x == WAIT_MODE) {
//    MSTA.z = 1.0;

// once the velocity at home is low enough, we can go back
    if (mag <= HomeThreshold) {
      MSTA.x = FADE_MODE;
      MSTA.y = Time;
      Position = VertexHomePos;
    }
  }
}

subroutine (RenderPassType)

void render()
{
  CharI = VertexTextureI;
  FragAlpha = VertexMSTA.z; //Alpha;
  gl_Position = vec4(VertexPosition, 1.0);
}

void main()
{
// This will call either render() or update()
  RenderPass();
}
