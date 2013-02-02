//
// @author Jonny Brannum <jonny.brannum@gmail.com> 
//         1/21/12
//

#import "GameLayer.h"


@interface GameLayer ()


@end

@implementation GameLayer
{
    BOOL isMove;
}

@synthesize mazeGenerator = _mazeGenerator;
@synthesize playerEntity = _playerEntity;
@synthesize desireEntity=_desireEntity;
@synthesize currentStart = _currentStart;
@synthesize currentEnd = _currentEnd;
@synthesize batchNode = _batchNode;
@synthesize guiLayer=_guiLayer;


- (id)init
{
    self = [super init];
    isMove=NO;
    
    self.isTouchEnabled = YES;
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"walls.plist"];
    self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"walls.png"];
    [self addChild:_batchNode];
    self.mazeGenerator = [[[MazeGenerator alloc] initWithBatchNode:_batchNode] autorelease];
    [self regenerateMaze];
    return self;
}

- (void)regenerateMaze
{
    [self removeAllChildrenWithCleanup:YES];
    [_batchNode removeAllChildrenWithCleanup:YES];
    [self addChild:_batchNode];
    _currentStart = nil;
    _currentEnd = nil;
    _playerEntity = nil;
    _desireEntity=nil;
    [self setPosition:ccp(0, 0)];
    [_mazeGenerator createUsingDepthFirstSearch];
    [self loadGeneratedMaze];
}
- (void)showMazeAnswer
{
    [_playerEntity beginMovement];
    //开始查找
    [_mazeGenerator searchUsingDepthFirstSearch:_currentStart.position endingAt:_currentEnd.position movingEntity:_playerEntity];
    _mazeGenerator.playerEntity=_playerEntity;
}


- (void)loadGeneratedMaze
{
    // determine our maze center
    CGPoint mazeCenter = ccp((_mazeGenerator.size.width)/2, (_mazeGenerator.size.height)/2);
    // find our center cell
    self.playerEntity = [Entity spriteWithFile:@"entity.png"];
    //set player position
    CGPoint rbMaze = ccp((_mazeGenerator.size.width), 0);
    MazeCell* rbCell= [_mazeGenerator cellForPosition:rbMaze];
    [_playerEntity setPosition:rbCell.position];
    [self addChild:_playerEntity];
    
    self.desireEntity = [Entity spriteWithFile:@"entity.png"];
    //set player position
    CGPoint ltMaze = ccp(0,(_mazeGenerator.size.height));
    MazeCell* ltCell= [_mazeGenerator cellForPosition:ltMaze];
    [_desireEntity setPosition:ltCell.position];
    [self addChild:_desireEntity];
    
    
    
    // determine the window center
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGPoint winCenter = ccp(winSize.width/2, winSize.height/2);
    // determine the difference between the two
    CGPoint diff = ccpSub(winCenter, mazeCenter);
    // add the difference to our current position to center the maze
    [self setPosition:ccpAdd(position_, ccp(diff.x, diff.y/2))];
    
    
    //创建&放置start点
    if (_currentStart == nil) {
        _currentStart = [Entity spriteWithFile:@"entity.png"];
        [_currentStart setColor:ccRED];
        [self addChild:_currentStart];
    }
    [_currentStart setPosition:_playerEntity.position];
    
    //创建&放置end点
    if (_currentEnd == nil) {
        _currentEnd = [Entity spriteWithFile:@"entity.png"];
        [_currentEnd setColor:ccGREEN];
        [self addChild:_currentEnd];
    }
    [_currentEnd setPosition:_desireEntity.position];
    
}
#if 1
- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{

    isMove=NO;
}

- (void)ccTouchesMoved:(NSSet*)touches withEvent:(UIEvent *)event
{
    if ([SysConfig mazeSize]>=oLarge) {
        isMove=YES;
        
        // we also handle touches for map movement
        // simply move the layer around by the diff of this move and the last
        UITouch *touch = [touches anyObject];
        // get our GL location
        CGPoint location = [[CCDirector sharedDirector]
                            convertToGL:[touch locationInView:touch.view]
                            ];
        CGPoint previousLocation = [[CCDirector sharedDirector]
                                    convertToGL:[touch previousLocationInView:touch.view]
                                    ];
        // create the difference
        CGPoint diff = ccp(location.x - previousLocation.x, location.y - previousLocation.y);
        // add the diff to the current position
        [self setPosition:ccp(position_.x + diff.x, position_.y + diff.y)];

    }
    
  }

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!isMove) {
        UITouch *touch = [touches anyObject];
        CGPoint location = [[CCDirector sharedDirector]
                            convertToGL:[touch locationInView:touch.view]
                            ];
        //这里点击有些偏移，因此需要手动修改
        int diffx=15;int diffy=18;
//        CGPoint endPosition = ccpAdd( ccpSub(location, self.position),ccp(15, 18));
        CGPoint endPosition = ccpSub(location, self.position);
        NSLog(@"ccTouchesEnded---endPosition x:%f,y:%f",endPosition.x,endPosition.y);
        if (endPosition.x>-diffx
            && endPosition.y>-diffy
            && endPosition.x<_mazeGenerator.size.width+diffx
            && endPosition.y<_mazeGenerator.size.height+diffy) {
            if ([_mazeGenerator isDesirePosition:endPosition desirePosition:_currentEnd.position]) {
                NSLog(@"GameLayer--great!!! you win!!!!!");
                [_guiLayer showOperationLayer:YES type:tLayerWin];
            }else{
                if ([_mazeGenerator showShotPath:_playerEntity.position endingAt:endPosition ]) {
                    [_mazeGenerator showShotPath:_currentStart.position endingAt:endPosition movingEntity:_playerEntity];
                }
            }
        } else {
            NSLog(@"touch is out of the maze..");
        }
    }
   
}
#endif
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_mazeGenerator release];
    [super dealloc];
}
@end