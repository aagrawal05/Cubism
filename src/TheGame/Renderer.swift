//
//  Renderer.swift
//  TheGame
//
//  Created by Aditya Agrawal on 23/9/21.
//

import MetalKit
import cglm

let NUM_VOXELS = 100

struct instanceUniform {
    var model: mat4
}

struct Vertex {
    var position: vec3
    //TODO --> Normal
    var color: vec4
}

struct Voxel {
    //var isEmpty: Bool
    var color: vec3
}

struct VoxelMesh {
    var x, y, z : Int
    var s : Float
    var Voxels: [Voxel]
}

let Cube: [Vertex] =
[
    Vertex(position: vec3(-0.5, -0.5, -0.5), color: vec4(0, 1, 1, 1)), //Bottom
    Vertex(position: vec3(-0.5, -0.5, 0.5), color: vec4(1, 0, 1, 1)),
    Vertex(position: vec3(0.5, -0.5, 0.5), color: vec4(1, 1, 0, 1)),
    Vertex(position: vec3(0.5, -0.5, 0.5), color: vec4(1, 1, 0, 1)),
    Vertex(position: vec3(0.5, -0.5, -0.5), color: vec4(0, 1, 1, 1)),
    Vertex(position: vec3(-0.5, -0.5, -0.5), color: vec4(1, 0, 1, 1)),
    
    Vertex(position: vec3(0.5, -0.5, -0.5), color: vec4(0, 1, 1, 1)), //Back
    Vertex(position: vec3(0.5, 0.5, -0.5), color: vec4(1, 0, 1, 1)),
    Vertex(position: vec3(-0.5, 0.5, -0.5), color: vec4(1, 1, 0, 1)),
    Vertex(position: vec3(-0.5, 0.5, -0.5), color: vec4(1, 1, 0, 1)),
    Vertex(position: vec3(-0.5, -0.5, -0.5), color: vec4(0, 1, 1, 1)),
    Vertex(position: vec3(0.5, -0.5, -0.5), color: vec4(1, 0, 1, 1)),
    
    Vertex(position: vec3(-0.5, -0.5, -0.5), color: vec4(0, 1, 1, 1)), //Left
    Vertex(position: vec3(-0.5, -0.5, 0.5), color: vec4(1, 0, 1, 1)),
    Vertex(position: vec3(-0.5, 0.5, 0.5), color: vec4(1, 1, 0, 1)),
    Vertex(position: vec3(-0.5, 0.5, 0.5), color: vec4(1, 1, 0, 1)),
    Vertex(position: vec3(-0.5, 0.5, -0.5), color: vec4(0, 1, 1, 1)),
    Vertex(position: vec3(-0.5, -0.5, -0.5), color: vec4(1, 0, 1, 1)),
    
    Vertex(position: vec3(-0.5, 0.5, 0.5), color: vec4(0, 1, 1, 1)), //Top
    Vertex(position: vec3(0.5, 0.5, 0.5), color: vec4(1, 0, 1, 1)),
    Vertex(position: vec3(0.5, 0.5, -0.5), color: vec4(1, 1, 0, 1)),
    Vertex(position: vec3(0.5, 0.5, -0.5), color: vec4(1, 1, 0, 1)),
    Vertex(position: vec3(-0.5, 0.5, -0.5), color: vec4(0, 1, 1, 1)),
    Vertex(position: vec3(-0.5, 0.5, 0.5), color: vec4(1, 0, 1, 1)),
    
    Vertex(position: vec3(-0.5, -0.5, 0.5), color: vec4(0, 1, 1, 1)), //Front
    Vertex(position: vec3(0.5, -0.5, 0.5), color: vec4(1, 0, 1, 1)),
    Vertex(position: vec3(0.5, 0.5, 0.5), color: vec4(1, 1, 0, 1)),
    Vertex(position: vec3(0.5, 0.5, 0.5), color: vec4(1, 1, 0, 1)),
    Vertex(position: vec3(-0.5, 0.5, 0.5), color: vec4(0, 1, 1, 1)),
    Vertex(position: vec3(-0.5, -0.5, 0.5), color: vec4(1, 0, 1, 1)),
    
    Vertex(position: vec3(0.5, -0.5, 0.5), color: vec4(0, 1, 1, 1)), //Right
    Vertex(position: vec3(0.5, -0.5, -0.5), color: vec4(1, 0, 1, 1)),
    Vertex(position: vec3(0.5, 0.5, -0.5), color: vec4(1, 1, 0, 1)),
    Vertex(position: vec3(0.5, 0.5, -0.5), color: vec4(1, 1, 0, 1)),
    Vertex(position: vec3(0.5, 0.5, 0.5), color: vec4(0, 1, 1, 1)),
    Vertex(position: vec3(0.5, -0.5, 0.5), color: vec4(1, 0, 1, 1)),
]

var instanceUniforms: [instanceUniform] = Array(repeating: instanceUniform(model: glms_mat4_identity().raw), count: NUM_VOXELS*NUM_VOXELS*NUM_VOXELS)

class Renderer : NSObject
{
    public  var mView:             MTKView
    
    private var mViewportSize:     vector_uint2
    
    private let mPipeline:         MTLRenderPipelineState
    private let mDepth:            MTLDepthStencilState
    private let mCommandQueue:     MTLCommandQueue
    
    private var mViewMatrix:       mat4s
    private let mProjectionMatrix: mat4s
    private var mVPMatrix:         mat4s
    
    private let mVoxelMesh:        VoxelMesh
    
    private let mInstanceBuffer:   MTLBuffer
    
    public init(view: MTKView)
    {
        
        mView = view

        //Init Matricies
        mViewMatrix =  glms_lookat(vec3s(raw: (0, 1, 5)), vec3s(raw: (0, 0, 0)), vec3s(raw: (0, 1, 0)))
        mProjectionMatrix = glms_perspective(Float(Double.pi/4), 1.0, 0.1, 100)
        mVPMatrix = glms_mat4_mul(mProjectionMatrix, mViewMatrix)
        
        //Init Voxel Data
        mVoxelMesh = VoxelMesh(x: NUM_VOXELS, y: NUM_VOXELS, z: NUM_VOXELS, s: 1/Float(NUM_VOXELS), Voxels: Array(repeating: Voxel(color: vec3(1.0, 1.0, 1.0)), count: NUM_VOXELS*NUM_VOXELS*NUM_VOXELS))
        
        for i in 0..<mVoxelMesh.x {
            for j in 0..<mVoxelMesh.y {
                for k in 0..<mVoxelMesh.z {
                    let ind = i*NUM_VOXELS*NUM_VOXELS + j*NUM_VOXELS + k
                    let voxelPos = glms_vec3_scale(vec3s(raw: (Float(i), Float(j), Float(k))), mVoxelMesh.s)
                    let model = glms_scale_uni(glms_translate(glms_mat4_identity(), voxelPos), mVoxelMesh.s)
                    instanceUniforms[ind].model = model.raw;
                }
            }
        }
        
        //Build Command Queue
        guard let cq = mView.device?.makeCommandQueue() else
        {
            fatalError("Could not create command queue")
        }
        mCommandQueue = cq
        
        //Load Shader Library
        guard let library = mView.device?.makeDefaultLibrary() else
        {
            fatalError("No shader library!")
        }
        //Load shaders from metal file
        let vertexFunction   = library.makeFunction(name: "vertexShader")
        let fragmentFunction = library.makeFunction(name: "fragmentShader")

        //Build Pipeline
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = mView.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat      = MTLPixelFormat.depth32Float
        pipelineDescriptor.vertexFunction                  = vertexFunction
        pipelineDescriptor.fragmentFunction                = fragmentFunction

        guard let ps = try! mView.device?.makeRenderPipelineState(descriptor: pipelineDescriptor) else
        {
            fatalError("Couldn't create pipeline state")
        }
        mPipeline = ps
        
        // Build Depth State
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = MTLCompareFunction.lessEqual
        depthDescriptor.isDepthWriteEnabled = true

        guard let dd = try! mView.device?.makeDepthStencilState(descriptor: depthDescriptor) else
        {
            fatalError("Couldn't create depth state")
        }
        mDepth = dd
        
        //Build Buffers
        guard let ib = try! mView.device?.makeBuffer(bytes: instanceUniforms, length: instanceUniforms.count * MemoryLayout<instanceUniform>.size, options: MTLResourceOptions.cpuCacheModeWriteCombined) else
        {
            fatalError("Couldn't create uniform buffer")
        }
        mInstanceBuffer = ib
        
        //Set inital variables
        mView.depthStencilPixelFormat = MTLPixelFormat.depth32Float;
        mViewportSize = vector_uint2(2*uint(WIDTH), 2*uint(HEIGHT))
        
        super.init()
        mView.delegate = self
    }

    private func update()
    {
        let commandBuffer  = mCommandQueue.makeCommandBuffer()!
        
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: mView.currentRenderPassDescriptor!)
        
        commandEncoder?.setDepthStencilState(mDepth)
        commandEncoder?.setRenderPipelineState(mPipeline)
        commandEncoder?.setVertexBytes(Cube, length: Cube.count * MemoryLayout<Vertex>.size, index: 0)
        commandEncoder?.setVertexBytes(&(mVPMatrix.raw), length: 64, index: 1)//--> 16 alignment
        commandEncoder?.setVertexBuffer(mInstanceBuffer, offset: 0, index: 2)
        commandEncoder?.drawPrimitives(type: MTLPrimitiveType.triangle, vertexStart: 0, vertexCount: 36, instanceCount: NUM_VOXELS*NUM_VOXELS*NUM_VOXELS)
        commandEncoder?.endEncoding()

        commandBuffer.present(mView.currentDrawable!)
        commandBuffer.commit()
        
        //Update Matricies
        mViewMatrix =  glms_lookat(vec3s(raw: (5*sin(deg), 5*sin(deg2), 5*cos(deg))), vec3s(raw: (0, 0, 0)), vec3s(raw: (0, 1, 0)))
        mVPMatrix = glms_mat4_mul(mProjectionMatrix, mViewMatrix)
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
