//
//  GameOverScene.swift
//  FruitNinjaGame
//
//  Created by Steve Kerney on 9/1/17.
//  Copyright © 2017 Steve Kerney. All rights reserved.
//

import SpriteKit
import AVFoundation
import AVKit

class GameOverScene: SKScene
{
    var restartLabel: SKLabelNode!;
    var gameOverSFX: AVAudioPlayer!;
    
    override func didMove(to view: SKView)
    {
        initScene();
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let vTouch = touches.first else { return; }
        let touchLocation = vTouch.location(in: self);
        
        let objects = nodes(at: touchLocation);
        
        if objects.contains(restartLabel)
        {
            if let scene = SKScene(fileNamed: "GameScene")
            {
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene);
            }
        }
    }
    
    func initScene()
    {
        createBG();
        playGameOverSFX();
        createRestartButton();
    }
    
    fileprivate func createBG()
    {
        guard let vViewFrame = view?.frame else { return; }
        
        let background = SKSpriteNode(imageNamed: "gameOverBG");
        background.position = CGPoint(x: vViewFrame.width / 2, y: vViewFrame.height / 2)
        background.blendMode = .replace;
        background.zPosition = -1;
        addChild(background);
    }
    
    fileprivate func playGameOverSFX()
    {
        let path = Bundle.main.path(forResource: "gameover.caf", ofType: nil)!;
        let url = URL(fileURLWithPath: path);
        let sound = try! AVAudioPlayer(contentsOf: url);
        gameOverSFX = sound;
        sound.play();
    }
    
    fileprivate func createRestartButton()
    {
        restartLabel = SKLabelNode(fontNamed: "Chalkduster");
        restartLabel.text = "Restart Game";
        restartLabel.horizontalAlignmentMode = .center;
        restartLabel.fontSize = 48;
        restartLabel.position = CGPoint(x: ((self.view?.frame.width)! / 2), y: ((self.view?.frame.height)! / 5));
        addChild(restartLabel);
    }
}
