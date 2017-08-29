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
    //TouchPoints
    var activeSlicePoints = [CGPoint]();
    
    //Slash Mechanic
    var activeSliceBG: SKShapeNode!;
    var activeSliceFG: SKShapeNode!;
    let sliceLength = 8;
    var isSwooshSFXPlaying = false;
    
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
    
    
    //MARK: Game Init
    override func didMove(to view: SKView)
    {
        initScene();
    }
    
}

//MARK: Touch Input
extension GameScene
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        activeSlicePoints.removeAll(keepingCapacity: true);
        
        guard let vTouch = touches.first else { return; }
        let touchLocation = vTouch.location(in: self);
        activeSlicePoints.append(touchLocation);
        
        //Bezier Curve Construction
        redrawActiveSlice();
        
        activeSliceBG.removeAllActions();
        activeSliceFG.removeAllActions();
        
        activeSliceBG.alpha = 1.0;
        activeSliceFG.alpha = 1.0;
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let vTouch = touches.first else { return; }
        let touchLocation = vTouch.location(in: self);
        activeSlicePoints.append(touchLocation);
        
        //Bezier Curve Construction
        redrawActiveSlice();
        
        if !isSwooshSFXPlaying { playSwooshSFX(); }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>?, with event: UIEvent?)
    {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25));
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25));
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?)
    {
        guard let vTouches = touches else { return; }
        touchesEnded(vTouches, with: event);
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
        activeSliceBG.strokeColor = UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 0.8);
        activeSliceBG.lineWidth = 9;
        
        
        activeSliceFG = SKShapeNode();
        activeSliceFG.zPosition = 2;
        activeSliceFG.strokeColor = UIColor.red;
        activeSliceFG.lineWidth = 5;
        
        addChild(activeSliceBG);
        addChild(activeSliceFG);
    }
    
    //Create path based on slice points positions.
    fileprivate func redrawActiveSlice()
    {
        //Not enough data - early out
        guard activeSlicePoints.count > 2 else { self.activeSliceFG.path = nil; self.activeSliceBG.path = nil; return; }
        
        while activeSlicePoints.count > sliceLength
        {
            //Pop oldest points
            activeSlicePoints.remove(at: 0);
        }
        
        //Construct path
        let path = UIBezierPath();
        path.move(to: activeSlicePoints[0]);
        
        for index in 1..<activeSlicePoints.count
        {
            path.addLine(to: activeSlicePoints[index]);
        }
        
        //Assign path
        activeSliceBG.path = path.cgPath;
        activeSliceFG.path = path.cgPath;
    }
}

//MARK: SFX Functions
extension GameScene
{
    fileprivate func playSwooshSFX()
    {
        
        isSwooshSFXPlaying = !isSwooshSFXPlaying;
        
        let randomIndex = RandomInt(min: 1, max: 3);
        let soundName = "swoosh\(randomIndex).caf";
        let playSwooshSFXAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true);
        
        run(playSwooshSFXAction) { [unowned self] in
         
            self.isSwooshSFXPlaying = false;
        }
    }
}
