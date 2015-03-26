//
//  Flamestrike.swift
//  460Demo
//
//  Created by Austin Hudelson on 3/25/15.
//  Copyright (c) 2015 Austin Hudelson. All rights reserved.
//


import SpriteKit

@objc(Flamestrike)
class Flamestrike: Order, PType, Transient
{
    var DS_moveState = false
    
    init(receiverIn: Unit){
        super.init()
        self.DS_receiver = receiverIn
        ID = receiverIn.ID
        type = "Flamestrike"
    }
    
    required init(receivedData: Dictionary<String, AnyObject>) {
        super.init(receivedData: receivedData)
        restoreProperties(Attack.self, receivedData: receivedData)
        DS_receiver = Game.global.getUnit(self.ID!)
    }
    
    override func apply(){
        let flamestrike: Projectile = FlamestrikeProjectile(caster: DS_receiver!)
    }
    
    override func remove(){
        
    }
}