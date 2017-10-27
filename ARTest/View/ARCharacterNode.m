//
//  ARCharacterNode.m
//  ARTest
//
//  Created by Renhuachi on 2017/10/27.
//  Copyright © 2017年 迟人华. All rights reserved.
//

#import "ARCharacterNode.h"

@implementation ARCharacterNode

- (id)init {
    if (self = [super init]) {
        SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/characters/explorer/explorer_skinned.dae"
                                   inDirectory:nil
                                       options:@{SCNSceneSourceConvertToYUpKey : @YES,
                                                 SCNSceneSourceAnimationImportPolicyKey :SCNSceneSourceAnimationImportPolicyPlayRepeatedly}];
        
        self = (ARCharacterNode *)scene.rootNode;
        
        [self setupAnimation];
    }
    return self;
}

- (void)setupAnimation {
    
}

@end
