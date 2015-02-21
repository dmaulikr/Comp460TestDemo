//
//  Unit.swift
//  460Demo
//
//  Created by Olyver on 1/31/15.
//  Copyright (c) 2015 Austin Hudelson. All rights reserved.
//

import SpriteKit
import Foundation
@objc(Unit)
class Unit: SerializableJSON, PType
{
//    var UnitCategory: UInt32 = 0x1 << 0
//    var name: String = ""
    var type: String = "Unit"
    var ID: String = ""
    var health: Int = 0
    var speed: CGFloat = 0.0
    var sprite: SKNode = SKSpriteNode(imageNamed: "Mage")
    var currentOrder: Order = NoneOrder()
    var DS_walkAnim: SKAction = SKAction.alloc()
    var DS_attackAnim: SKAction = SKAction.alloc()
    var DS_standAnim: SKAction = SKAction.alloc()
    
    var DS_health_txt: SKLabelNode = SKLabelNode(text: "")
    var health_txt_y_dspl: CGFloat = 40 // The y displacement of health text relative to this unit's sprite
    
    required init() {
        // take this out eventually
        super.init()
    }
    
    required init(receivedData: Dictionary<String, AnyObject>){
        //Special case for sprite
        super.init(receivedData: receivedData)
        
        var aClass : AnyClass? = Unit.self      //ADJUST FOR EACH CLASS?
        var propertiesCount : CUnsignedInt = 0
        let propertiesInAClass : UnsafeMutablePointer<objc_property_t> = class_copyPropertyList(aClass, &propertiesCount)
        //var propertiesDictionary : NSMutableDictionary = NSMutableDictionary()
        
        for var i = 0; i < Int(propertiesCount); i++ {
            var property = propertiesInAClass[i]
            var propName = NSString(CString: property_getName(property), encoding: NSUTF8StringEncoding)! as String
            var propType = property_getAttributes(property)
            
            //Check if the key is in the dictionary (only DS_ and sprite should not appear here)
            if receivedData[propName] != nil {
                let propValue = receivedData[propName]
                self.setValue(propValue, forKey: propName)
            } else {
                println("Unable to find value for property: "+propName)
            }
        }
        
        /* Configure Health Text (SHOULD MATH OTHER INIT() FUNCTION) */
        self.DS_health_txt.fontColor = UIColor.redColor()
        self.DS_health_txt.text = self.health.description
        self.DS_health_txt.fontSize = 40
        
//        // physics stuff
//        self.sprite.physicsBody = SKPhysicsBody(rectangleOfSize: self.sprite.frame.size)
//        self.sprite.physicsBody?.usesPreciseCollisionDetection = true
//        self.sprite.physicsBody?.categoryBitMask = UnitCategory
//        self.sprite.physicsBody?.collisionBitMask = 0
//        self.sprite.physicsBody?.contactTestBitMask = UnitCategory
    }
    
    init(ID: String, health: Int, speed: CGFloat, spawnLocation: CGPoint) {
        super.init()
        self.health = health
        self.speed = speed
        self.ID = ID
        self.currentOrder = NoneOrder()
        /* Configure our health text */
        self.DS_health_txt.fontColor = UIColor.redColor()
        self.DS_health_txt.text = self.health.description
        self.DS_health_txt.fontSize = 40
        
//        //// physics stuff
//        self.sprite.physicsBody = SKPhysicsBody(rectangleOfSize: self.sprite.frame.size)
//        self.sprite.physicsBody?.usesPreciseCollisionDetection = true
//        self.sprite.physicsBody?.categoryBitMask = UnitCategory
//        self.sprite.physicsBody?.collisionBitMask = 0
//        self.sprite.physicsBody?.contactTestBitMask = UnitCategory
//        //self.sprite.physicsBody?.restitution = 0
//        //self.sprite.physicsBody?.
        
        
        
    }
    
    
    
    /*
        Used to add a unit to the game scene at position 'pos', with sprite.xScale = 'scaleX' & sprite.yScale = 'scaleY'.
        Also displays a health text on top of this unit
    */
    func addUnitToGameScene(gameScene: GameScene, pos: CGPoint, scaleX: CGFloat, scaleY: CGFloat)
    {
        self.sprite.xScale = scaleX
        self.sprite.yScale = scaleY
        self.sprite.position = pos
        gameScene.addChild(self.sprite)
        
        /* Add health text */
        var health_txt_pos: CGPoint = pos
        health_txt_pos.y += self.health_txt_y_dspl
        self.DS_health_txt.position = health_txt_pos
        gameScene.addChild(self.DS_health_txt)
        
        //PRINTLN MYSELF AS JSON
        println("PRINTING SELF AS JSON LOOK HERE!!!!")
        println(self.toJSON())
        
    }
    /* !!!!!!NEED TO CHANGE THESE TWO IN FUTURE!!!!!! */
    func sendOrder(order: Order){
        currentOrder.remove()
        currentOrder = order
        currentOrder.apply()
    }
    /* Apply Move */
    func apply(order: Order)
    {
        println("APPLY")
        if order is Move
        {
            println("APPLYMOVE")
            let moveLoc = (order as Move).moveToLoc
            move(moveLoc, {})
           
        }
    }
    
    func takeDamage(damage:Int)
    {
        health-=damage
        println("\(ID), \(health)")
        self.DS_health_txt.text = self.health.description
    }
    
    func move(destination:CGPoint, complete:(()->Void)!)
    {
        println("MOVING")
        let charPos = sprite.position
        println(charPos)
        let xdif = destination.x-charPos.x
        let ydif = destination.y-charPos.y
        
        //Check facing
        if (xdif < -0.1) {
            self.sprite.runAction(SKAction.scaleXTo(-0.5, duration: 0.0))
        } else if (xdif > 0.1) {
            self.sprite.runAction(SKAction.scaleXTo(0.5, duration: 0.0))
        }
        
        let distance = sqrt((xdif*xdif)+(ydif*ydif))
        let duration = distance/speed
        let movementAction = SKAction.moveTo(destination, duration:NSTimeInterval(duration))
        let walkAnimationAction = self.DS_walkAnim
        //Create action for "Walk to point then do "complete""
        let walkSequence = SKAction.sequence([movementAction, SKAction.runBlock(complete)])
        /* Move the health text */
        var health_txt_des = destination
        
        health_txt_des.y += health_txt_y_dspl
        let moveHealthTxtAction = SKAction.moveTo(health_txt_des, duration: NSTimeInterval(duration))
        DS_health_txt.runAction(moveHealthTxtAction, withKey: "move")
        sprite.runAction(walkSequence, withKey: "move")
        sprite.runAction(self.DS_walkAnim, withKey: "moveAnim")
        
    }
    
    func clearMove(){
        self.sprite.removeActionForKey("move")
        self.sprite.removeActionForKey("moveAnim")
        self.DS_health_txt.removeActionForKey("move")
    }
    
    /*
    * Call the synchronize this unit with the host. Will correct current life and 
    * position if it has deviated too far from the host.
    */
    func synchronize(syncTime: NSTimeInterval, recievedLife: Int, recievedPosition: CGPoint){
        
    }
    
    /*
    * LOCAL DEATH
    * playes the units death animation and prevents further actions
    */
    func death(){
        
    }
    
    /*
    * Actually removes the unit from memory. Should not be called until a negitive update unit is called
    */
    func kill(){
        
    }
    
    
    
}
