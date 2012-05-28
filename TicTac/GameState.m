//
//  GameState.m
//  TicTac
//
//  Created by Michael Green on 5/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameState.h"

@implementation GameState
@synthesize playersTurn = _playersTurn;
@synthesize boardState = _boardState;

-(id) init
{
    self = [super init];
    
    if (self) {
        // Alloc and init the board state
        self.boardState = [[NSMutableArray alloc] initWithCapacity:9];
        self.playersTurn = TTxPlayerTurn;
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.boardState forKey:@"BoardState"];
    [aCoder encodeInt:self.playersTurn forKey:@"PlayersTurn"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self.boardState = [aDecoder decodeObjectForKey:@"BoardState"];
    self.playersTurn = [aDecoder decodeIntForKey:@"PlayersTurn"];
    
    return self;
}
@end
