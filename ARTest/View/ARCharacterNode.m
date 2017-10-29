//
//  ARCharacterNode.m
//  ARTest
//
//  Created by Renhuachi on 2017/10/27.
//  Copyright © 2017年 迟人华. All rights reserved.
//

#import "ARCharacterNode.h"

#define DirectionKey @"CharacterDirection"
@interface ARCharacterNode()

@property (nonatomic, strong) NSMutableDictionary *animateDic;
@property (nonatomic, assign) ARCharacterDirection characterDirection;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ARCharacterNode

- (id)init {
    if (self = [super init]) {
        SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/characters/explorer/explorer_skinned.dae"
                                   inDirectory:nil
                                       options:@{SCNSceneSourceConvertToYUpKey : @YES,
                                                 SCNSceneSourceAnimationImportPolicyKey :SCNSceneSourceAnimationImportPolicyPlayRepeatedly}];
        
        [self addChildNode:scene.rootNode];
    }
    return self;
}

- (void)loadData {
    [self setupAllAnimation];
    
    CAAnimation *idleAnimation = [_animateDic objectForKey:@"idle-1"];
    idleAnimation.repeatCount = MAXFLOAT;
    [self addAnimation:idleAnimation forKey:@"idle-1"];
}

- (void)setupAllAnimation {
    _animateDic = [NSMutableDictionary new];
    [_animateDic setObject:[self loadAnimationNamed:@"jump_start-1" fromSceneNamed:@"art.scnassets/characters/explorer/jump_start"] forKey:@"jump_start-1"];
    [_animateDic setObject:[self loadAnimationNamed:@"jump_falling-1" fromSceneNamed:@"art.scnassets/characters/explorer/jump_falling"] forKey:@"jump_falling-1"];
    [_animateDic setObject:[self loadAnimationNamed:@"jump_land-1" fromSceneNamed:@"art.scnassets/characters/explorer/jump_land"] forKey:@"jump_land-1"];
    [_animateDic setObject:[self loadAnimationNamed:@"idle-1" fromSceneNamed:@"art.scnassets/characters/explorer/idle"] forKey:@"idle-1"];
    
    [_animateDic setObject:[self loadAnimationNamed:@"run_start-1" fromSceneNamed:@"art.scnassets/characters/explorer/run_start"] forKey:@"run_start-1"];
    [_animateDic setObject:[self loadAnimationNamed:@"run_stop-1" fromSceneNamed:@"art.scnassets/characters/explorer/run_stop"] forKey:@"run_stop-1"];
    [_animateDic setObject:[self loadAnimationNamed:@"run-1" fromSceneNamed:@"art.scnassets/characters/explorer/run"] forKey:@"run-1"];
}

- (CAAnimation *)loadAnimationNamed:(NSString *)animationName fromSceneNamed:(NSString *)sceneName {
    // Load the DAE using SCNSceneSource in order to be able to retrieve the animation by its identifier
    NSURL *url = [[NSBundle mainBundle] URLForResource:sceneName withExtension:@"dae"];
    SCNSceneSource *sceneSource = [SCNSceneSource sceneSourceWithURL:url options:@{SCNSceneSourceConvertToYUpKey : @YES} ];
    
    CAAnimation *animation = [sceneSource entryWithIdentifier:animationName withClass:[CAAnimation class]];
    animation.repeatCount = 0;
    
    // Blend animations for smoother transitions
    [animation setFadeInDuration:0.15];
    [animation setFadeOutDuration:0.15];
    
    return animation;
}

- (void)doRunActionWithDirection:(ARCharacterDirection)direction {
    [self.timer invalidate];
    switch (direction) {
        case ARCharacterDirection_Forward:
            if (_characterDirection == ARCharacterDirection_Forward) {
                break;
            }
            self.characterDirection = ARCharacterDirection_Forward;
            self.rotation = SCNVector4Make(0, 1 ,0 , 0);
            break;
        case ARCharacterDirection_Back:
            if (_characterDirection == ARCharacterDirection_Back) {
                break;
            }
            self.characterDirection = ARCharacterDirection_Back;
            self.rotation = SCNVector4Make(0, 1 ,0 , M_PI);
            break;
        default:
            break;
    }
    
    CAAnimation *run = [_animateDic objectForKey:@"run-1"];
    CAAnimation *run_start = [_animateDic objectForKey:@"run_start-1"];
    
    run_start.duration = 0.33;
    run.repeatCount = MAXFLOAT;
    
    SCNAnimationEventBlock runBlock = ^(CAAnimation *animation, id animatedObject, BOOL playingBackward) {
        [self addAnimation:run forKey:@"run-1"];
    };
    
    run_start.animationEvents = @[[SCNAnimationEvent animationEventWithKeyTime:0.33f block:runBlock]];
    
    [self removeAllAnimations];
    [self addAnimation:run_start forKey:@"run_start-1"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObject:@(direction) forKey:DirectionKey];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1/30 target:self selector:@selector(characterMove:) userInfo:dic repeats:YES];
}

- (void)characterMove:(NSTimer *)timerInfo {
    ARCharacterDirection direction = [[[timerInfo userInfo] objectForKey:DirectionKey] integerValue];
    
    float moveDistance;
    
    switch (direction) {
        case ARCharacterDirection_Forward:
            moveDistance = 0.0002;
            break;
        case ARCharacterDirection_Back:
            moveDistance = -0.0002;
            break;
        default:
            break;
    }
    
    self.position = SCNVector3Make(self.position.x, self.position.y, self.position.z + moveDistance);
}

- (void)stopRunAction {
    [self.timer invalidate];
    CAAnimation *idleAnimation = [_animateDic objectForKey:@"idle-1"];
    idleAnimation.repeatCount = MAXFLOAT;
    [self addAnimation:idleAnimation forKey:@"idleAnimation-1"];
}

#pragma mark - action
- (void)doJumpAnimation {
    CAAnimation *jumpAnimation = [_animateDic objectForKey:@"jump_start-1"];
    CAAnimation *fallAnimation = [_animateDic objectForKey:@"jump_falling-1"];
    CAAnimation *landAanimation = [_animateDic objectForKey:@"jump_land-1"];
    CAAnimation *idleAnimation = [_animateDic objectForKey:@"idle-1"];
    idleAnimation.repeatCount = MAXFLOAT;
    jumpAnimation.duration = 2;
    
    SCNAnimationEventBlock leaveGroundBlock = ^(CAAnimation *animation, id animatedObject, BOOL playingBackward) {
//        self.position = SCNVector3Make(self.position.x, self.position.y + 1, self.position.z);
    };
    SCNAnimationEventBlock pause = ^(CAAnimation *animation, id animatedObject, BOOL playingBackward) {
        [self pauseAnimationForKey:@"jump_falling-1"];
    };
    
    SCNAnimationEventBlock down = ^(CAAnimation *animation, id animatedObject, BOOL playingBackward) {
//        self.position = SCNVector3Make(self.position.x, self.position.y - 1, self.position.z);
    };
    
    jumpAnimation.animationEvents = @[[SCNAnimationEvent animationEventWithKeyTime:0.3f block:leaveGroundBlock]];
    fallAnimation.animationEvents = @[[SCNAnimationEvent animationEventWithKeyTime:0.6f block:pause]];
    landAanimation.animationEvents = @[[SCNAnimationEvent animationEventWithKeyTime:0.9f block:down]];
    
    [self chainAnimation:@"jump_start-1" toAnimation:@"jump_falling-1"];
    [self chainAnimation:@"jump_start-1" toAnimation:@"jump_land-1"];
    [self chainAnimation:@"jump_start-1" toAnimation:@"idle-1"];
    
    
    [self removeAllAnimations];
    [self addAnimation:jumpAnimation forKey:@"jump_start-1"];
    
    
    [self runAction:[SCNAction moveTo:SCNVector3Make(self.position.x, self.position.y + 1, self.position.z) duration:1] forKey:@"" completionHandler:^{
        [self runAction:[SCNAction moveTo:SCNVector3Make(self.position.x, self.position.y - 1, self.position.z) duration:1]];
    }];
}

#pragma mark - helper Methods
- (void)chainAnimation:(NSString *)firstKey toAnimation:(NSString *)secondKey
{
    CAAnimation *firstAnim = [_animateDic objectForKey:firstKey];
    CAAnimation *secondAnim = [_animateDic objectForKey:secondKey];
    if (firstAnim == nil || secondAnim == nil)
        return;
    
    SCNAnimationEventBlock chainEventBlock = ^(CAAnimation *animation, id animatedObject, BOOL playingBackward) {
        [self addAnimation:secondAnim forKey:secondKey];
    };
    
    if (firstAnim.animationEvents == nil || firstAnim.animationEvents.count == 0) {
        firstAnim.animationEvents = @[[SCNAnimationEvent animationEventWithKeyTime:0.85f block:chainEventBlock]];
    } else {
        NSMutableArray *pastEvents = [NSMutableArray arrayWithArray:firstAnim.animationEvents];
        [pastEvents addObject:[SCNAnimationEvent animationEventWithKeyTime:0.85f block:chainEventBlock]];
        firstAnim.animationEvents = pastEvents;
    }
}

@end
