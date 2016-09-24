//
//  GameViewController.swift
//  Cell Shading
//
//  Created by Evan Bacon on 7/28/15.
//  Copyright (c) 2015 Evan Bacon. All rights reserved.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLight.LightType.omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLight.LightType.ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        let currentNode = SCNNode(geometry: SCNTorus(ringRadius: 1, pipeRadius: 0.5))
        currentNode.position = SCNVector3Zero
        scene.rootNode.addChildNode(currentNode)
        
        
        let shaderUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "cel", ofType: "shader")!)
        
        var data:String!
        do {
            data = try String(contentsOf: shaderUrl, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        var shaders = [SCNShaderModifierEntryPoint:String]()
        shaders[SCNShaderModifierEntryPoint.fragment] = data
        
        let mod = "float flakeSize = sin(u_time * 0.2);\n" + "float flakeIntensity = 0.7;\n" + "vec3 paintColor0 = vec3(0.9, 0.4, 0.3);\n" + "vec3 paintColor1 = vec3(0.9, 0.75, 0.2);\n" + "vec3 flakeColor = vec3(flakeIntensity, flakeIntensity, flakeIntensity);\n" + "vec3 rnd =  texture2D(u_diffuseTexture, _surface.diffuseTexcoord * vec2(1.0) * sin(u_time*0.1) ).rgb;\n" + "vec3 nrm1 = normalize(0.05 * rnd + 0.95 * _surface.normal);\n" + "vec3 nrm2 = normalize(0.3 * rnd + 0.4 * _surface.normal);\n" + "float fresnel1 = clamp(dot(nrm1, _surface.view), 0.0, 1.0);\n" + "float fresnel2 = clamp(dot(nrm2, _surface.view), 0.0, 1.0);\n" + "vec3 col = mix(paintColor0, paintColor1, fresnel1);\n" + "col += pow(fresnel2, 106.0) * flakeColor;\n" + "_surface.normal = nrm1;\n" + "_surface.diffuse = vec4(col.r,col.b,col.g, 1.0);\n" + "_surface.emission = (_surface.reflective * _surface.reflective) * 2.0;\n" + "_surface.reflective = vec4(0.0);\n"
        
        shaders[SCNShaderModifierEntryPoint.surface] = mod
        currentNode.geometry?.firstMaterial?.shaderModifiers = shaders
        
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        // set the scene to the view
        scnView.scene = scene
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        // configure the view
        scnView.backgroundColor = UIColor.blue
        // add a tap gesture recognizer
    }
}
