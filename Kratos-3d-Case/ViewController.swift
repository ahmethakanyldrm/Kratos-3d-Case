//
//  ViewController.swift
//  Kratos-3d-Case
//
//  Created by AHMET HAKAN YILDIRIM on 23.11.2023.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController, ARSCNViewDelegate {
    var sceneView: ARSCNView!
    var lastDistance: Float?

    override func viewDidLoad() {
        super.viewDidLoad()

        // ARSCNView oluşturuluyor ve view'a ekleniyor
        sceneView = ARSCNView(frame: view.bounds)
        view.addSubview(sceneView)

        // ARFaceTrackingConfiguration kullanılarak ARSession başlatılıyor
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)

        sceneView.delegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    // ARSCNViewDelegate metodu: Yüz güncellendiğinde çağrılır
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        // Kameradan yüzün ortasına olan mesafeyi ve yüz dönüş açısını hesapla
        let distance = calculateDistance(from: node.worldPosition, to: faceAnchor.transform)
        let angle = calculateAngle(for: faceAnchor.transform)

        // Hesaplanan değerleri ekrana yazdırma
        print("Distance to face: \(distance) cm")
        print("Angle to face: \(angle) degrees")
    }

    // Kameradan yüzün ortasına olan mesafeyi hesapla
    func calculateDistance(from cameraPosition: SCNVector3, to faceTransform: matrix_float4x4) -> Float {
        let facePosition = SCNVector3(faceTransform.columns.3.x, faceTransform.columns.3.y, faceTransform.columns.3.z)
        let distance = distanceBetween(vector1: cameraPosition, vector2: facePosition)
        return distance * 100  // Cm'ye dönüştürme
    }

    // Yüz dönüş açısını hesapla
    func calculateAngle(for faceTransform: matrix_float4x4) -> Float {
        // Yaw, pitch ve roll açılarını dönüş matrisinden çıkartarak hesapla
            let yaw = atan2(-faceTransform.columns.0.z, faceTransform.columns.0.x)
            let pitch = atan2(faceTransform.columns.1.y, faceTransform.columns.1.z)
            let roll = atan2(faceTransform.columns.2.x, faceTransform.columns.2.y)

            // Yaw, pitch ve roll değerlerini dereceden radiana çevir
            let yawDegrees = GLKMathDegreesToRadians(yaw)
            let pitchDegrees = GLKMathDegreesToRadians(pitch)
            let rollDegrees = GLKMathDegreesToRadians(roll)

            // Yaw değerini döndür (yaw değeri yatay dönüşü temsil eder)
            return yawDegrees
    }

    // Ekran üzerine dokunulduğunda çağrılan metot
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        // Dokunulan noktayı al
        let touchLocation = gesture.location(in: sceneView)
        // ARKit'ten bir frame al
        guard let currentFrame = sceneView.session.currentFrame else { return }
        // Dokunulan noktaya ray gönder
        let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
        // Ray'in dünya koordinatlarındaki ucu
        guard let hitTestResult = hitTestResults.first else { return }
        // Dünya koordinatlarındaki noktayı al
        let hitTransform = hitTestResult.worldTransform
        // Hesaplanan noktayı al
        let hitVector = SCNVector3(hitTransform.columns.3.x, hitTransform.columns.3.y, hitTransform.columns.3.z)
        // Hesaplanan noktaya küre ekle
        let sphere = SCNSphere(radius: 0.01)
        // Küreyi ekrana ekle
        let sphereNode = SCNNode(geometry: sphere)
        // Kürenin konumunu ayarla
        sphereNode.position = hitVector
        sceneView.scene.rootNode.addChildNode(sphereNode)
    }

    // İki vektör arasındaki uzaklığı hesapla
    func distanceBetween(vector1: SCNVector3, vector2: SCNVector3) -> Float {
        let dx = vector2.x - vector1.x
        let dy = vector2.y - vector1.y
        let dz = vector2.z - vector1.z
        return sqrt(dx * dx + dy * dy + dz * dz)
    }
}
