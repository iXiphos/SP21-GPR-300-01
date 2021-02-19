/*
	Copyright 2011-2021 Daniel S. Buckstein

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

/*
	animal3D SDK: Minimal 3D Animation Framework
	By Daniel S. Buckstein
	
	passTangentBasis_shadowCoord_transform_vs4x.glsl
	Calculate and pass tangent basis, and shadow coordinate.
*/

#version 450

// ****TO-DO:
// 1) core transformation and lighting setup:
//	-> declare data structures for projector and model matrix stacks
//		(hint: copy and slightly modify demo object descriptors)
//	-> declare uniform block for matrix data
//		(hint: must match how it is uploaded in update function)
//	-> use matrix data for current object to perform relevant transformations
//		(hint: model-view-projection sequence may be split up like last time, 
//		but per usual the final clip-space result is assigned to gl_Position)
//	-> declare relevant attributes for lighting
//	-> perform any additional transformations and write varyings for lighting
// 2) shadow mapping
//	-> using the above setup, perform additional transformation to generate a 
//		"shadow coordinate", which is a "biased clip-space" coordinate from 
//		the light's point of view
//		(hint: transformation sequence is model-view-projection-bias)
//	-> declare and write varying for shadow coordinate


//matrix stack strucks 
struct sProjectorMatrixStack
{
	mat4 projectionMat;					// projection matrix (viewer -> clip)
	mat4 projectionMatInverse;			// projection inverse matrix (clip -> viewer)
	mat4 projectionBiasMat;				// projection-bias matrix (viewer -> biased clip)
	mat4 projectionBiasMatInverse;		// projection-bias inverse matrix (biased clip -> viewer)
	mat4 viewProjectionMat;				// view-projection matrix (world -> clip)
	mat4 viewProjectionMatInverse;		// view-projection inverse matrix (clip -> world)
	mat4 viewProjectionBiasMat;			// view projection-bias matrix (world -> biased clip)
	mat4 viewProjectionBiasMatInverse;	// view-projection-bias inverse matrix (biased clip -> world)
};

struct sModelMatrixStack
{
	mat4 modelMat;						// model matrix (object -> world)
	mat4 modelMatInverse;					// model inverse matrix (world -> object)
	mat4 modelMatInverseTranspose;		// model inverse-transpose matrix (object -> world skewed)
	mat4 modelViewMat;					// model-view matrix (object -> viewer)
	mat4 modelViewMatInverse;				// model-view inverse matrix (viewer -> object)
	mat4 modelViewMatInverseTranspose;	// model-view inverse transpose matrix (object -> viewer skewed)
	mat4 modelViewProjectionMat;			// model-view-projection matrix (object -> clip)
	mat4 atlasMat;						// atlas matrix (texture -> cell)
};

layout (location = 0) in vec4 aPosition;

flat out int vVertexID;
flat out int vInstanceID;

uniform int uIndex;

//ubo_transform
// -> projector stack for camera, light
// -> model stack for all objects

uniform ubTransformStack
{
	sProjectorMatrixStack  uCameraMatrixStack, uLightMatrixStack;
	sModelMatrixStack uModelMatrixStack[16];
};

void main()
{
	// DUMMY OUTPUT: directly assign input position to output position
	gl_Position = uCameraMatrixStack.projectionMat * uModelMatrixStack[uIndex].modelViewMat * aPosition; //aPosition;

	vVertexID = gl_VertexID;
	vInstanceID = gl_InstanceID;
}