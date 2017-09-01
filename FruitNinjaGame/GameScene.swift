//
//  GameScene.swift
//  FruitNinjaGame
//
//  Created by Steve Kerney on 8/28/17.
//  Copyright © 2017 Steve Kerney. All rights reserved.
//

import SpriteKit
import AVFoundation
import AVKit

enum SequenceType: Int
{
    case oneNoBomb
    case one
    case twoWithOneBomb
    case two
    case three
    case four
    case chain
    case fastChain
}

enum ForceBomb
{
    case never
    case always
    case random
}

class GameScene: SKScene
{
    //Game
    var bombSFX: AVAudioPlayer!;
    
    //Enemy Spawning
    var spawnTime = 0.9
    var sequence: [SequenceType]!;
    var sequenceIndex = 0;
    var chainDelay = 3.0;
    var nextSequencedQueued = true;
    
    
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
    
    //Enemies
    var activeEnemies = [SKSpriteNode]();
    
    
    //Consts
    let ENEMY_VELOCITY_SCALAR = 40;
    
    //MARK: Game Init
    override func didMove(to view: SKView)
    {
        initScene();
        
        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain];
        
        for _ in 0...1000
        {
            let nextSequence = SequenceType(rawValue: RandomInt(min: 2, max: 7))!;
            sequence.append(nextSequence);
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
            self.tossEnemies();
        }
    }
    
    //MARK: Game Update
    override func update(_ currentTime: TimeInterval)
    {
        if activeEnemies.count > 0
        {
            for enemy in activeEnemies
            {
                if enemy.position.y < -140
                {
                    enemy.removeFromParent();
                    
                    if let index = activeEnemies.index(of: enemy)
                    {
                        activeEnemies.remove(at: index);
                    }
                }
            }
        }
        else
        {
            if !nextSequencedQueued
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + spawnTime, execute: { [unowned self] in
                    
                    self.tossEnemies();
                })
                nextSequencedQueued = true;
            }
        }
        
        var bombCount = 0;
        for node in activeEnemies
        {
            if node.name == "bombContainer"
            {
                bombCount += 1;
                break;
            }
        }
        
        if bombCount == 0
        {
            guard bombSFX != nil else { return; }
            bombSFX.stop();
            bombSFX = nil;
        }
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

//MARK: Enemy Functions
extension GameScene
{
    func createEnemy(_ forceBomb: ForceBomb = .random)
    {
        var enemyType = RandomInt(min: 0, max: 6);
        
        switch forceBomb
        {
        case .always:
            enemyType = 0;
        case .never:
            enemyType = 1;
        case .random:
            break;
        }
        
        enemyType == 0 ? createBomb() : createWatermelon()
        
    }
    
    func createBomb()
    {
        //Bomb Empty Collision Node
        let enemy = SKSpriteNode();
        enemy.zPosition = 1;
        enemy.name = "bombContainer";
        
        
        //Bomb Image Child
        let bombImage = SKSpriteNode(imageNamed: "sliceBomb");
        bombImage.name = "bomb";
        enemy.addChild(bombImage);
        
        if bombSFX != nil
        {
            bombSFX.stop();
            bombSFX = nil;
        }
        
        //Bomb Fuse SFX
        let path = Bundle.main.path(forResource: "sliceBombFuse.caf", ofType: nil)!;
        let url = URL(fileURLWithPath: path);
        let sound = try! AVAudioPlayer(contentsOf: url);
        bombSFX = sound;
        sound.play();
        
        //Bomb Emitter Child
        let emitter = SKEmitterNode(fileNamed: "sliceFuse.sks")!;
        emitter.position = CGPoint(x: 76, y: 64);
        enemy.addChild(emitter);
        
        setEnemyOrientation(enemy: enemy);
        
        activeEnemies.append(enemy);
        addChild(enemy);
    }
    
    func createWatermelon()
    {
        let enemy = SKSpriteNode(imageNamed: "watermelon");
        enemy.name = "watermelon";
        run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false));
        
        setEnemyOrientation(enemy: enemy);
        
        activeEnemies.append(enemy);
        addChild(enemy);
    }
    
    func setEnemyOrientation(enemy: SKSpriteNode)
    {
        //Position
        let randomPosition = CGPoint(x: RandomInt(min: 64, max: 960), y: -128);
        enemy.position = randomPosition;
        
        //Angular Velocity
        let randomAngularVelocity = CGFloat(RandomInt(min: -6, max: 6)) / 2.0
        
        //Linear Velocity
        var randomXVelocity = 0;
        if randomPosition.x < 256
        {
            randomXVelocity = RandomInt(min: 8, max: 15);
        }
        else if randomPosition.x < 512
        {
            randomXVelocity = RandomInt(min: 3, max: 5);
        }
        else if randomPosition.x < 756
        {
            randomXVelocity = -RandomInt(min: 3, max: 5);
        }
        else
        {
            randomXVelocity = -RandomInt(min: 8, max: 15);
        }
        let randomYVelocity = RandomInt(min: 24, max: 32)
        
        //Physics
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64);
        enemy.physicsBody!.velocity = CGVector(dx: randomXVelocity * ENEMY_VELOCITY_SCALAR, dy: randomYVelocity * ENEMY_VELOCITY_SCALAR);
        enemy.physicsBody!.angularVelocity = randomAngularVelocity;
        enemy.physicsBody!.collisionBitMask = 0;
    }
}

//MARK: Gameplay Functions
extension GameScene
{
    func tossEnemies()
    {
        spawnTime *= 0.991;
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02;
        
        let sequenceType = sequence[sequenceIndex];
        
        switch sequenceType
        {
        case .oneNoBomb:
            createEnemy(.never);
        case .one:
            createEnemy();
        case .twoWithOneBomb:
            createEnemy(.never);
            createEnemy(.always);
        case .two:
            createEnemy();
            createEnemy();
        case .three:
            createEnemy();
            createEnemy();
            createEnemy();
        case .four:
            createEnemy();
            createEnemy();
            createEnemy();
            createEnemy();
        case .chain:
            createEnemy();
            
            for index in 1...4
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * Double(index)), execute: { [unowned self] in
                    self.createEnemy();
                })
            }
        case .fastChain:
            createEnemy();
            
            for index in 1...4
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * Double(index)), execute: { [unowned self] in
                    self.createEnemy();
                })
            }
        }
        
        sequenceIndex += 1;
        nextSequencedQueued = false;
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
