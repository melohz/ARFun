//
//  ViewController.swift
//  ARFun2
//
//  Created by 板垣智也 on 2019/12/17.
//  Copyright © 2019 板垣智也. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var tagetView: UIView!
    @IBOutlet weak var measurementLabel: UILabel!
    @IBOutlet weak var startingPointButton: UIButton!
    
    var firstBox: SCNNode?
    var secondBox: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        for node in sceneView.scene.rootNode.childNodes {
            let moveShip = SCNAction.moveBy(x: 0, y: 0.5, z: 0.5, duration: 5)
            let fadeOut = SCNAction.fadeOpacity(by: 0.5, duration: 1)
            let fadeIn = SCNAction.fadeOpacity(by: 1.0, duration: 1)
            
            let routine = SCNAction.sequence([fadeOut, fadeIn, moveShip])
            
            let foreverRoutine = SCNAction.repeatForever(routine)
            node.runAction(foreverRoutine)
        }
        measurementLabel.text = ""
    }
    @IBAction func tapSetStartingPoint(_ sender: Any) {
        
        if firstBox == nil {
            firstBox = addBox()
            if firstBox != nil {
                startingPointButton.setTitle("Set End Point", for: .normal)
            }
        } else if secondBox == nil {
            secondBox = addBox()
            if secondBox != nil {
                calcDistance()
                startingPointButton.setTitle("Reset", for: .normal)
            }
        } else {
            firstBox?.removeFromParentNode()
            secondBox?.removeFromParentNode()
            firstBox = nil
            secondBox = nil
            measurementLabel.text = ""
            startingPointButton.setTitle("Set Start Point", for: .normal)
        }
        
        
    }
    
    func calcDistance() {
        if let firstBox = firstBox, let secondBox = secondBox {
            let vector = SCNVector3Make(secondBox.position.x - firstBox.position.x,
                                        secondBox.position.y - firstBox.position.y,
                                        secondBox.position.z - firstBox.position.z)
            let distance = sqrtf(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
            
            measurementLabel.text = "\(distance)m"
        }
    }
    
    func addBox() -> SCNNode? {
        let userTouch = sceneView.center
        
        let testResults = sceneView.hitTest(userTouch, types: .featurePoint)
        
        if let theResult = testResults.first {
            let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0.05)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.green
            box.firstMaterial = material
            
            let boxNode = SCNNode(geometry: box)
            boxNode.position = SCNVector3(theResult.worldTransform.columns.3.x,
                                          theResult.worldTransform.columns.3.y,
                                          theResult.worldTransform.columns.3.z)
            sceneView.scene.rootNode.addChildNode(boxNode)
            return boxNode
        }
        
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    

    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("added")
        if let plane = anchor as? ARPlaneAnchor {
            print("X: \(plane.extent.x)m, Z: \(plane.extent.z)m")
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        print("updated")
        if let plane = anchor as? ARPlaneAnchor {
            print("X: \(plane.extent.x)m, Z: \(plane.extent.z)m")
        }
    }
}
