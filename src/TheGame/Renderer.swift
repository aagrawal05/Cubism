//
//  Renderer.swift
//  TheGame
//
//  Created by Aditya Agrawal on 23/9/21.
//

import MetalKit
import cglm

let NUM_VOXELS = 100

/*struct instanceUniform {
    var model: mat4
    var color: vec3
}*/

struct Vertex {
    var position: vec3
    //TODO --> Normal
    var color: vec4
}

/*struct Voxel {
    //var isEmpty: Bool
    var color: vec3
    
}
struct VoxelMesh {
    var x, y, z : Int
    var s : Float
    var Voxels: [Voxel]
}*/

let Cube: [Vertex] =
[
    Vertex(position: vec3(-0.5, -0.5, 0), color: vec4(1, 1, 1, 1)), //Bottom
    Vertex(position: vec3(-0.5, 0.5, 0), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(0.5, 0.5, 0), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(0.5, 0.5, 0), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(0.5, -0.5, 0), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(-0.5, -0.5, 0), color: vec4(1, 1, 1, 1)),
    
    Vertex(position: vec3(-0.5, -0.5, 0), color: vec4(1, 1, 1, 1)), //Back
    Vertex(position: vec3(0.5, -0.5, 0), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(0.5, -0.5, 0.5), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(0.5, -0.5, 0.5), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(-0.5, -0.5, 0.5), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(-0.5, -0.5, 0), color: vec4(1, 1, 1, 1)),
    
    Vertex(position: vec3(-0.5, -0.5, 0.5), color: vec4(1, 1, 1, 1)), //Top
    Vertex(position: vec3(-0.5, 0.5, 0.5), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(0.5, 0.5, 0.5), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(0.5, 0.5, 0.5), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(0.5, -0.5, 0.5), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(-0.5, -0.5, 0.5), color: vec4(1, 1, 1, 1)),
    
    Vertex(position: vec3(-0.5, 0.5, 0), color: vec4(1, 1, 1, 1)), //Back
    Vertex(position: vec3(0.5, 0.5, 0), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(0.5, 0.5, 0.5), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(0.5, 0.5, 0.5), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(-0.5, 0.5, 0.5), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(-0.5, 0.5, 0), color: vec4(1, 1, 1, 1)),
    
    Vertex(position: vec3(-0.5, 0.5, 0), color: vec4(1, 1, 1, 1)), //Left
    Vertex(position: vec3(-0.5, -0.5, 0), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(-0.5, -0.5, 0.5), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(-0.5, -0.5, 0.5), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(-0.5, 0.5, -0.5), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(-0.5, 0.5, 0), color: vec4(1, 1, 1, 1)),
    
    Vertex(position: vec3(0.5, 0.5, 0), color: vec4(1, 1, 1, 1)), //Right
    Vertex(position: vec3(0.5, -0.5, 0), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(0.5, -0.5, 0.5), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(0.5, -0.5, 0.5), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(0.5, 0.5, -0.5), color: vec4(1, 1, 1, 1)),
    Vertex(position: vec3(0.5, 0.5, 0), color: vec4(1, 1, 1, 1)),
]

//var instanceUniforms: [instanceUniform] = Array(repeating: instanceUniform(model: glms_mat4_identity().raw, color: vec3(1.0, 1.0, 1.0)), count: NUM_VOXELS*NUM_VOXELS*NUM_VOXELS)

class Renderer : NSObject
{
    public  var mView:             MTKView
    private var mViewportSize:     vector_uint2
    private let mPipeline:         MTLRenderPipelineState
    private let mCommandQueue:     MTLCommandQueue
    private let mModelMatrix:      mat4s
    private let mViewMatrix:       mat4s
    private let mWorldMatrix:      mat4s
    private let mProjectionMatrix: mat4s
    private var mVPMatrix:         mat4s
    
    //private let mVoxelMesh:        VoxelMesh
    public init(view: MTKView)
    {
        
        mView = view

        //Init Matricies
        mModelMatrix = glms_rotate(glms_mat4_identity(), glm_rad(-55), vec3s(raw: (1.0, 0.0, 0.0)))
        mViewMatrix = glms_translate(glms_mat4_identity(), vec3s(raw: (0.0, 0.0, -3.0)))
        mWorldMatrix = glms_mat4_identity()
        mProjectionMatrix = glms_perspective(glm_rad(45), 4/3, 0.1, 100)
        mVPMatrix = glms_mat4_mul(glms_mat4_mul(mProjectionMatrix, mViewMatrix), mModelMatrix)

        //Generate Voxel Data
        /*mVoxelMesh = VoxelMesh(x: NUM_VOXELS, y: NUM_VOXELS, z: NUM_VOXELS, s: Float(1/NUM_VOXELS), Voxels: Array(repeating: Voxel(color: vec3(1.0, 1.0, 1.0)), count: NUM_VOXELS*NUM_VOXELS*NUM_VOXELS))
        
        for i in 0..<mVoxelMesh.x {
            for j in 0..<mVoxelMesh.y {
                for k in 0..<mVoxelMesh.z {
                    let ind = i*NUM_VOXELS*NUM_VOXELS + j*NUM_VOXELS + k
                    let voxelPos = glms_vec3_scale(vec3s(raw: (Float(i), Float(j), Float(k))), mVoxelMesh.s)
                    let model = glms_scale_uni(glms_translate(glms_mat4_identity(), voxelPos), mVoxelMesh.s)
                    instanceUniforms[i].model = model.raw;
                    instanceUniforms[i].color = vec3(1.0, 1.0, 1.0);
                }
            }
        }*/
        
        //Build Pipeline
        guard let cq = mView.device?.makeCommandQueue() else
        {
            fatalError("Could not create command queue")
        }
        mCommandQueue = cq
        guard let library = mView.device?.makeDefaultLibrary() else
        {
            fatalError("No shader library!")
        }
        let vertexFunction   = library.makeFunction(name: "vertexShader")
        let fragmentFunction = library.makeFunction(name: "fragmentShader")

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = mView.colorPixelFormat
        pipelineDescriptor.vertexFunction                  = vertexFunction
        pipelineDescriptor.fragmentFunction                = fragmentFunction

        guard let ps = try! mView.device?.makeRenderPipelineState(descriptor: pipelineDescriptor) else
        {
            fatalError("Couldn't create pipeline state")
        }
        mPipeline = ps
        mViewportSize = vector_uint2(2*uint(WIDTH), 2*uint(HEIGHT))
        super.init()
        mView.delegate = self
    
    }

    private func update()
    {
        let commandBuffer  = mCommandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: mView.currentRenderPassDescriptor!)
        commandEncoder?.setRenderPipelineState(mPipeline)
        commandEncoder?.setVertexBytes(Cube, length: Cube.count * MemoryLayout<Vertex>.size, index: 0)
        commandEncoder?.setVertexBytes(&(mVPMatrix.raw), length: 64, index: 1)//--> 16 alignment
        //commandEncoder?.setVertexBytes(instanceUniforms, length: instanceUniforms.count * MemoryLayout<instanceUniform>.size, index: 2)
        commandEncoder?.drawPrimitives(type: .triangleStrip,
                                       vertexStart: 0,
                                       vertexCount: 18)
        commandEncoder?.endEncoding()

        commandBuffer.present(mView.currentDrawable!)
        commandBuffer.commit()
    }
}

extension Renderer: MTKViewDelegate
{
    public func draw(in view: MTKView)
    {
        // Called every frame
        self.update()
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize)
    {
        // This will be called on resize
        mViewportSize.x = uint(size.width)
        mViewportSize.y = uint(size.height)
    }
}
