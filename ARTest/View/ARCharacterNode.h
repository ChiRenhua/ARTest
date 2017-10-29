//
//  ARCharacterNode.h
//  ARTest
//
//  Created by Renhuachi on 2017/10/27.
//  Copyright © 2017年 迟人华. All rights reserved.
//

#import <SceneKit/SceneKit.h>

typedef NS_ENUM(NSUInteger, ARCharacterDirection) {
    ARCharacterDirection_Forward,
    ARCharacterDirection_Back,
};

@interface ARCharacterNode : SCNNode

- (void)loadData;

- (void)doJumpAnimation;
- (void)doRunActionWithDirection:(ARCharacterDirection)direction;
- (void)stopRunAction;

@end
