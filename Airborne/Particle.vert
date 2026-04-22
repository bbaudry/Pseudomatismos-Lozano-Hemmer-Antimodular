#version 400

subroutine void RenderPassType();
subroutine uniform RenderPassType RenderPass;

layout (location = 0) in vec3  VertexPosition;
layout (location = 1) in vec3  VertexVelocity;
layout (location = 2) in float VertexTextureI;

out vec3  Position;  // To transform feedback
out vec3  Velocity;  // To transform feedback
out float TextureI;  // To transform feedback

out float CharI;     // To fragment shader

uniform float TimeStep; // Elapsed time between frames
uniform float Speed;

subroutine (RenderPassType)

void update()
{
  Position = VertexPosition;
  Velocity = VertexVelocity;
  TextureI = VertexTextureI;

// if the particle is offscreen, reset it to the origin
  if ((Position.x > 1.0) || (Position.x < -1.0) ||
      (Position.y > 1.0) || (Position.y < -1.0))
  {
    Position = vec3(0.0);
  }

// otherwise update it
  else {
    Position += Velocity * TimeStep *Speed;
  }
}

subroutine (RenderPassType)

void render()
{
  CharI = VertexTextureI;
  gl_Position = vec4(VertexPosition, 1.0);
  gl_FrontColor = vec4(1.0);
  gl_BackColor = vec4(1.0);
}

void main()
{
// This will call either render() or update()
  RenderPass();
} 
