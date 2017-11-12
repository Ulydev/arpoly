//
//  PopoverLocationNode.swift
//  PolyAR
//
//  Created by Ulysse on 12/11/2017.
//  Copyright © 2017 Ulysse. All rights reserved.
//

import Foundation
import ARCL
import SceneKit
import CoreLocation

class PopoverLocationNode: LocationNode {
    
    public let image: UIImage
    public var scaleRelativeToDistance = true
    
    public let annotationNode: SCNNode
    
    public init(location: CLLocation?, title: NSString) {
        
        let view = PopoverLocationNode.generateView(title: title)
        let image = PopoverLocationNode.generateImageFromView(inputView: view)
        self.image = image
        
        let plane = SCNPlane(width: 20, height: 20)
        plane.firstMaterial!.diffuse.contents = self.image
        plane.firstMaterial!.lightingModel = .constant
        plane.firstMaterial!.transparency = 1
        
        annotationNode = SCNNode()
        annotationNode.geometry = plane
        
        super.init(location: location)
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        constraints = [billboardConstraint]
        
        addChildNode(annotationNode)
    }
    
    static func generateView(title: NSString) -> UIView {
        let image = UIImage(named: "popover")
        let view = UIView(frame: CGRect(x: 0, y: 0, width: (image?.size.width)!, height: (image?.size.height)!))
        
        let imageView = UIImageView(frame: view.frame)
        imageView.image = image
        imageView.backgroundColor = UIColor.clear.withAlphaComponent(0)
        imageView.isOpaque = false
        
        let titleLabel = UILabel(frame: view.frame)
        titleLabel.center = CGPoint(x: view.frame.width/2, y: view.frame.height/2 - 10)
        titleLabel.textAlignment = .center
        titleLabel.text = title as String
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: ".SFUIText", size: 80)
        titleLabel.adjustsFontSizeToFitWidth = true
        
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        
        return view
    }
    
    static func generateImageFromView(inputView: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        inputView.drawHierarchy(in: inputView.bounds, afterScreenUpdates: true)
        let uiImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return uiImage
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
