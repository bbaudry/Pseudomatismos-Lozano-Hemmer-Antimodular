#import "Shader.h"

@implementation Shader

- (id) init
{
  [super init];
	
  return self;
}

- (void) initLazy
{
  initialized = TRUE;
}

- (void) dealloc
{
  [super dealloc];
}

- (NSString *) name
{
  return @"?";
}

- (NSString *) descriptionFilename
{
	return NULL;
}

- (void) loadVertexShader: (NSString *) vertexString andFragmentShader: (NSString *) fragmentString
{
  GLhandleARB vertex_shader, fragment_shader;

  const GLcharARB *vertex_string, *fragment_string;
  GLint vertex_compiled, fragment_compiled;
  GLint linked;
  
// delete any existing program object 
  if (programObject) {
	glDeleteObjectARB(programObject);
	programObject = NULL;
  }
  
// load and compile the fragment shader
  if (vertexString) {
 	vertex_shader   = glCreateShaderObjectARB(GL_VERTEX_SHADER_ARB);
	vertex_string   = (GLcharARB *) [vertexString cString];
	glShaderSourceARB(vertex_shader, 1, &vertex_string, NULL);
	glCompileShaderARB(vertex_shader);
	glGetObjectParameterivARB(vertex_shader, GL_OBJECT_COMPILE_STATUS_ARB, &vertex_compiled);
  }
  else return; 

// load and compile the fragment shader
  if (fragmentString) {
	fragment_shader   = glCreateShaderObjectARB(GL_FRAGMENT_SHADER_ARB);
	fragment_string   = [fragmentString cString];
	glShaderSourceARB(fragment_shader, 1, &fragment_string, NULL);
	glCompileShaderARB(fragment_shader);
	glGetObjectParameterivARB(fragment_shader, GL_OBJECT_COMPILE_STATUS_ARB, &fragment_compiled);
  } 
  else {
	if (vertex_shader) glDeleteObjectARB(vertex_shader);
    return;
  }
	
// create a new program object and link both shaders 
  programObject = glCreateProgramObjectARB();
  
// attach the vertex shader  
  if (vertex_shader) {
	glAttachObjectARB(programObject, vertex_shader);
	glDeleteObjectARB(vertex_shader);   /* Release */
  }
  
// attach the frament shader  
  if (fragment_shader) {
	glAttachObjectARB(programObject, fragment_shader);
	glDeleteObjectARB(fragment_shader); /* Release */
  }
  glLinkProgramARB(programObject);
  glGetObjectParameterivARB(programObject, GL_OBJECT_LINK_STATUS_ARB, &linked);
	
  if (!linked) {
 	glDeleteObjectARB(programObject);
	programObject = NULL;
  }
}

@end



