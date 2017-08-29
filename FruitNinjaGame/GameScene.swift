//
//  GameScene.swift
//  FruitNinjaGame
//
//  Created by Steve Kerney on 8/28/17.
//  Copyright © 2017 Steve Kerney. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene
{
    //SwipeNodes
    var activeSliceBG: SKShapeNode!;
    var activeSliceFG: SKShapeNode!;
    
    //Gameplay
    var gameScore: SKLabelNode!;
    var score: Int = 0
    {
        didSet
        {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var livesImages = [SKSpriteNode]();
    var livesRemaining = 3;
    
    override func didMove(to view: SKView)
    {
        initScene();
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {

    }
    
}

//MARK: Helper Funcs
extension GameScene
{
    fileprivate func initScene()
    {
        createBG();
        setWorldProperties();
        createScore();
        createLives();
        createSlices();
    }
    
    fileprivate func createBG()
    {
        guard let vViewFrame = view?.frame else { return; }
        
        let background = SKSpriteNode(imageNamed: "sliceBackground");
        background.position = CGPoint(x: vViewFrame.width / 2, y: vViewFrame.height / 2)
        background.blendMode = .replace;
        background.zPosition = -1;
        addChild(background);
    }
    
    fileprivate func setWorldProperties()
    {
        physicsWorld.gravity = CGVector(dx: 0, dy: -6);
        physicsWorld.speed = 0.85;
    }
    
    fileprivate func createScore()
    {
        gameScore = SKLabelNode(fontNamed: "Chalkduster");
        gameScore.text = "Score: 0";
        gameScore.horizontalAlignmentMode = .left;
        gameScore.fontSize = 48;
        gameScore.position = CGPoint(x: 8, y: 8);
        addChild(gameScore);
    }
    
    fileprivate func createLives()
    {
        for index in 0..<3
        {
            let lifeSprite = SKSpriteNode(imageNamed: "sliceLife");
            lifeSprite.position = CGPoint(x: CGFloat(834 + (index * 70)), y: 720);
            addChild(lifeSprite);
            
            livesImages.append(lifeSprite);
        }
    }
    
    fileprivate func createSlices()
    {
        activeSliceBG = SKShapeNode();
        activeSliceBG.zPosition = 2;
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1.0);
        activeSliceBG.lineWidth = 9;
        
        
        activeSliceFG = SKShapeNode();
        activeSliceFG.zPosition = 2;
        activeSliceFG.strokeColor = UIColor.white;
        activeSliceFG.lineWidth = 5;
        
        addChild(activeSliceBG);
        addChild(activeSliceFG);

    }
}
