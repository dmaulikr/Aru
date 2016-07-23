//
//  GameScene.swift
//  Aru
//
//  Created by Trevin Wisaksana on 6/26/16.
//  Copyright (c) 2016 Trevin Wisaksana. All rights reserved.
//  In GameScene, only place the Gaming properties and attributes. Place different chapters in different scenes or different states as a state machine is set up.

import SpriteKit

///////////////////////////////////////////////////////
let arrayOfLevels: Array = ["IntroLvl1", // 0
                            "IntroLvl2", // 1
                            "IntroLvl3", // 2
                            "Level1",    // 3
                            "Level2",    // 4
                            "Level3",    // 5
                            "Level4",    // 6
                            "Level5",    // 7
                            "Level7",    // 8
                            "Level8",    // 9
                            "Level9",    // 10
                            "Level10"]   // 11

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // This helps make sure that the level is only run once
    var alreadyRan = false
    
    // Delcaring joystick property
    var base: SKSpriteNode!
    var stick: SKSpriteNode!
    // Declaring stick active property
    var stickActive: Bool! = false
    var xValue: CGFloat = 0
    var yValue: CGFloat = 0
    
    // Declaring character property
    var blueCharacter: Character!
    var pinkCharacter: Character!
    
    // Declaring the switchButton property
    var switchButton: MSButtonNode!
    var buttonFunctioning: Bool = true
    var jumpButton: MSButtonNode!
    var alreadyTapped: Bool = true
    
    // Allows the button to be pressed once every 1 second
    var canJump = true
    
    // Array to contain the links of the joints 
    var links: [SKSpriteNode]!
    
    // Creating the checkpoint object
    var target: Checkpoint!
    
    // Create camera 
    var characterCamera = SKCameraNode()
    
    // Distance between each character
    var distanceOfCharacterDifference: CGFloat!
    
    // Separate Button
    var separateButton: MSButtonNode!
    
    // Separate button executed 
    var separationExecuted: Bool = true
    
    // Two characters made contact 
    var madeContact: Bool = false
    
    override func didMoveToView(view: SKView) {
        
        // Sets the physics world so that it can detect contact
        self.physicsWorld.contactDelegate = self
        
        // From the Character class, the characters gets its position set and is added to the scene
        blueCharacter = Character(characterColor: .Blue)
        pinkCharacter = Character(characterColor: .Pink)
        blueCharacter.position = CGPoint(x: 70, y: 125)
        pinkCharacter.position = CGPoint(x: 50, y: 125)
        addChild(blueCharacter)
        addChild(pinkCharacter)
        
        // From the Checkpoint class, the checkpoint gets its position set and is added to the scene
        target = childNodeWithName("//checkpoint") as! Checkpoint
        target.setup()
        
        // Creates the joystick
        base = SKSpriteNode(imageNamed: "base")
        base.size = CGSize(width: 100, height: 100)
        base.zPosition = 10
        base.position.x = -200
        base.position.y = -90
        stick = SKSpriteNode(imageNamed: "stick")
        stick.size = CGSize(width: 80, height: 80)
        base.alpha = 0.1
        base.hidden = true
        base.addChild(stick)
        
        // Creates the jump and switch button
        switchButton = MSButtonNode(imageNamed: "blueSwitchButton")
        jumpButton = MSButtonNode(imageNamed: "blueJumpButton")
        switchButton.size = CGSize(width: switchButton.size.width / 7, height: switchButton.size.height / 7)
        switchButton.zPosition = 101
        switchButton.state = .Active
        jumpButton.size = CGSize(width: jumpButton.size.width / 7, height: jumpButton.size.height / 7)
        switchButton.position.x = 110
        switchButton.position.y = -110
        jumpButton.position.x = 210
        jumpButton.position.y = -90
        separateButton = MSButtonNode(imageNamed: "separateBlueButton")
        separateButton.size = CGSize(width: separateButton.size.width / 16, height: separateButton.size.height / 16)
        separateButton.zPosition = 101
        separateButton.position = CGPoint(x: 20, y: -110)
        separateButton.state = .Active
        
        jumpButton.zPosition = 101
        jumpButton.state = .Active
        characterCamera.addChild(switchButton)
        characterCamera.addChild(jumpButton)
        characterCamera.addChild(base)
        characterCamera.addChild(separateButton)
        
        // Assuring that the target of the camera is the character's position
        addChild(characterCamera)
        self.camera = characterCamera
        characterCamera.xScale = 0.4
        characterCamera.yScale = 0.4

        activateJumpButton()
        activateSwitchButton()
        createChain()
        activateSeparateButton()
        
        // Creating a physical boundary to the edge of the scene
        physicsBody = SKPhysicsBody(edgeLoopFromRect: view.frame)
        physicsBody?.categoryBitMask = PhysicsCategory.Platform
        physicsBody?.collisionBitMask = 1
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == PhysicsCategory.BlueCharacter | PhysicsCategory.Checkpoint {
            // This goes to the LevelCompleteScene after making contact and the distance between the two objects is less than 50 pixels
            if distanceOfCharacterDifference < 60 && distanceOfCharacterDifference > -60 {
                levelChanger += 1
                changeScene()
            }
        } else if collision == PhysicsCategory.PinkCharacter | PhysicsCategory.Checkpoint {
            // This goes to the LevelCompleteScene scene after making contact and the distance between the two objects is less than 50 pixels
            if distanceOfCharacterDifference < 60 && distanceOfCharacterDifference > -60 {
                levelChanger += 1
                changeScene()
            }
        }
    }
    
    // Note: When the screen is tapped on, this code runs
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        // The cameraLocation means that the touch will be relative to the characterCamera's position
        let cameraLocation = touch.locationInNode(characterCamera)
        if cameraLocation.x < 0 {
            base.alpha = 0.5
            base.hidden = false
            base.position = cameraLocation
        }
        
        // MARK: To do: Fix the two touches problem
        // The problem is that there are two touches began. This means that two different touches will run the touchesBegan twice!
        // touches.count == 2 needs two fingers on the screen at the same time which is not correct
    
        // If the other half of the screen is tapped, this will run
        if (CGRectContainsPoint(base.frame, cameraLocation)) {
            stickActive = true
        }
    }
    
    // This is used for detecting when a player moves their finger on the screen
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let location = touch.locationInNode(base)
        // The cameraLocation means that the touch will be relative to the characterCamera's position
        let cameraLocation = touch.locationInNode(characterCamera)
        
        // This is for the X axis
        var x = location.x
        if x > 30 {
            x = 30
        } else if x < -30 {
            x = -30
        }
        
        // This is for the Y axis
        var y = location.y
        if y > 30 {
            y = 30
        } else if y < -30 {
            y = -30
        }
        xValue = x / 30
        yValue = y / 30
        
        if cameraLocation.x < 0 {
            stick.position = CGPoint(x: x, y: y)
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if stickActive == true {
            let move = SKAction.moveTo(CGPoint(x: 0, y: 0), duration: 0.1)
            move.timingMode = .EaseOut
            stick.runAction(move)
            base.hidden = true
        }
        xValue = 0
        yValue = 0
    }

    override func update(currentTime: CFTimeInterval) {
        // Called before each frame is rendered
        if buttonFunctioning == true {
            if stickActive == true {
                let vector = CGVector(dx: 400 * xValue, dy: 0)
                blueCharacter.physicsBody?.applyForce(vector)
            }
        } else {
            if stickActive == true {
                let vector = CGVector(dx: 400 * xValue, dy: 0)
                pinkCharacter.physicsBody?.applyForce(vector)
            }
        }
        if buttonFunctioning {
            characterCamera.position = blueCharacter.position
        } else if buttonFunctioning == false {
            characterCamera.position = pinkCharacter.position
        }
        // This prevents the camera from going beyond the frame
        characterCamera.position.x.clamp(115, 455)
        
        // Calculates the difference between the two characters
        distanceOfCharacterDifference = blueCharacter.position.x - pinkCharacter.position.x
        print(distanceOfCharacterDifference)
      }
    
    ///////////////////////////////////////////////////////
    

    ///////////////////////////////
    // Inside here are functions //
    ///////////////////////////////
    
    ///////////////////////////////
    // Function to create Chain ///
    ///////////////////////////////
    
    func createChain() {
        var positionOne = pinkCharacter.position
        links = [SKSpriteNode]()
        for _ in 0..<8 {
            let link = SKSpriteNode(imageNamed: "link")
            link.size = CGSize(width: 2, height: 2)
            link.physicsBody = SKPhysicsBody(rectangleOfSize: link.size)
            link.physicsBody?.affectedByGravity = true
            link.position = pinkCharacter.position
            link.zPosition = 1
            link.physicsBody?.categoryBitMask = 0
            link.physicsBody?.collisionBitMask = 0
            link.physicsBody?.contactTestBitMask = 1
            addChild(link)
            // Distance between each chain
            positionOne.x += 2
            link.position = positionOne
            links.append(link)
        }
        
        for i in 0..<links.count {
            if i == 0 {
                // This pins the joint to the pinkCharacter
                let pin = SKPhysicsJointPin.jointWithBodyA(pinkCharacter.physicsBody!,bodyB: links.first!.physicsBody!, anchor: pinkCharacter.position)
                self.physicsWorld.addJoint(pin)
            } else {
                var anchor = links[i].position
                anchor.x -= 0
                let pin = SKPhysicsJointPin.jointWithBodyA(links[i - 1].physicsBody!,bodyB: links[i].physicsBody!, anchor: anchor)
                self.physicsWorld.addJoint(pin)
            }
           
        }
        // This pins the joint to the blueCharacter
        let pin = SKPhysicsJointPin.jointWithBodyA(blueCharacter.physicsBody!, bodyB: links.last!.physicsBody!, anchor: blueCharacter.position)
               self.physicsWorld.addJoint(pin)
    }
    
    ////////////////////////////
    // Change Level Function ///
    ////////////////////////////
    
    // This function is designed to load the level to the game
    func changeLevel(Name: String, Type: String) {
        let changeScene = SKAction.runBlock({
            let path = NSBundle.mainBundle().pathForResource(Name, ofType: Type)
            let node = SKReferenceNode (URL: NSURL (fileURLWithPath: path!))
            self.addChild(node)
        })
        self.runAction(changeScene)
    }

    ////////////////////////////
    // Activates Jump Button ///
    ////////////////////////////
    
    func activateJumpButton() {
        // Jump button allows the character to jump
        jumpButton.selectedHandler = {
            if self.buttonFunctioning {
                if self.canJump {
                    self.canJump = false
                    self.blueCharacter.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 405))
                    let reset = SKAction.runBlock({
                        self.canJump = true
                    })
                    let wait = SKAction.waitForDuration(1)
                    self.runAction(SKAction.sequence([wait, reset]))
                }
            } else if self.buttonFunctioning == false {
                if self.canJump {
                    self.canJump = false
                    self.pinkCharacter.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 405))
                    let reset = SKAction.runBlock({
                        self.canJump = true
                    })
                    let wait = SKAction.waitForDuration(0.8)
                    self.runAction(SKAction.sequence([wait, reset]))
                }
            }
        }
    }
    
    //////////////////////////////
    // Activates Switch Button ///
    //////////////////////////////
    
    func activateSwitchButton() {
        // Switch button allows the player to switch between characters
        switchButton.selectedHandler = {
            if self.buttonFunctioning {
                // Switch to the pinkCharacter
                self.buttonFunctioning = false
                // This is used to change the color of the buttons from blue to pink
                self.jumpButton.texture = SKTexture(imageNamed: "pinkJumpButton")
                self.switchButton.texture = SKTexture(imageNamed: "pinkSwitchButton")
            } else if self.buttonFunctioning == false {
                // Switch to the blueCharacter
                self.buttonFunctioning = true
                // This is used to change the color of the buttons from pink to blue
                self.jumpButton.texture = SKTexture(imageNamed: "blueJumpButton")
                self.switchButton.texture = SKTexture(imageNamed: "blueSwitchButton")
            }
        }
    }
    
    ////////////////////////////////////////////////////////
    // This function changes scene when collision occurs ///
    ////////////////////////////////////////////////////////
    
    func changeScene() {
        // Check for max levels because the this will always increase
        let reveal = SKTransition.fadeWithColor(SKColor.whiteColor(), duration: 2)
        let scene = GameScene(fileNamed: arrayOfLevels[levelChanger])
        scene!.scaleMode = .AspectFill
        self.view?.presentScene(scene!, transition: reveal)
        print(levelChanger)
    }
    
    //////////////////////
    // Separate button ///
    //////////////////////
    
    func activateSeparateButton() {
        separateButton.selectedHandler = {
            if self.separationExecuted {
                self.physicsWorld.removeAllJoints()
                self.separationExecuted = false
            } else if self.separationExecuted == false && self.distanceOfCharacterDifference <= 23 && self.distanceOfCharacterDifference >= -23 {
                self.createChain()
                self.separationExecuted = true
            }
        }
    }
}
