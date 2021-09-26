//
//  Renderer.swift
//  TheGame
//
//  Created by Aditya Agrawal on 23/9/21.
//

import MetalKit

struct Vertex {
    var position: vector_float2
    var color: vector_float4
    static var size = MemoryLayout<vector_float2>.size + MemoryLayout<vector_float4>.size
}

let VERTEX_DATA: [Vertex] =
[
    // v0
    Vertex(position: vector_float2(250, -250),
           color: vector_float4(1, 0, 0, 1)),
    // v1
    Vertex(position: vector_float2(-250, -250),
           color: vector_float4(0, 1, 0, 1)),
    // v2
    Vertex(position: vector_float2(0, 250),
           color: vector_float4(0, 0, 1, 1)),
    
]

class Renderer : NSObject
{
    public  var mView:         MTKView
    private var mViewportSize: vector_uint2
    private let mPipeline:     MTLRenderPipelineState
    private let mCommandQueue: MTLCommandQueue
    
    public init(view: MTKView)
    {
        mView = view

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
        commandEncoder?.setViewport(MTLViewport(originX: 0.0, originY: 0.0, width: Double(mViewportSize.x), height: Double(mViewportSize.y), znear: 0.0, zfar: 1.0))
        
        commandEncoder?.setRenderPipelineState(mPipeline)
        commandEncoder?.setVertexBytes(VERTEX_DATA, length: VERTEX_DATA.count * MemoryLayout.size(ofValue: VERTEX_DATA[0]), index: 0)
        commandEncoder?.setVertexBytes(&mViewportSize, length: MemoryLayout<vector_uint2>.size, index: 1)
        commandEncoder?.drawPrimitives(type: .triangle,
                                       vertexStart: 0,
                                       vertexCount: 3)
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
