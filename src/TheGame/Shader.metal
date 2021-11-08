//
//  WindowController.swift
//  TheGame
//
//  Created by Aditya Agrawal on 22/9/21.
//

#include <metal_stdlib>
#include <metal_matrix>

using namespace metal;

// Include header shared between this Metal shader code and C code executing Metal API commands.
typedef struct {
    packed_float3 position;
} Vertex;

struct instanceUniform
{
    float4x4 modelMatrix;
    packed_float4 color;
};

// Vertex shader outputs and fragment shader inputs
struct RasterizerData
{
    // The [[position]] attribute of this member indicates that this value
    // is the clip space position of the vertex when this structure is
    // returned from the vertex function.
    float4 position [[position]];

    // Since this member does not have a special attribute, the rasterizer
    // interpolates its value with the values of the other triangle vertices
    // and then passes the interpolated value to the fragment shader for each
    // fragment in the triangle.
    float4 color;
};

vertex RasterizerData
vertexShader(uint vertexID [[vertex_id]],
             uint instanceID [[instance_id]],
             constant Vertex *vertices [[buffer(0)]],
             constant float4x4 &vpMatrix [[buffer(1)]],
             constant instanceUniform *instanceUniforms [[buffer(2)]])
{
    RasterizerData out;
    out.position = vpMatrix * instanceUniforms[instanceID].modelMatrix * float4(vertices[vertexID].position, 1.0);
    // Pass the input color directly to the rasterizer.
    out.color = instanceUniforms[instanceID].color;

    return out;
}

fragment float4 fragmentShader(RasterizerData in [[stage_in]])
{
    // Return the interpolated color.
    return in.color;
}
