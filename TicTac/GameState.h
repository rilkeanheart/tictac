//
//  GameState.h
//  TicTac
//
//  Created by Michael Green on 5/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TTxPlayerTurn = 1,
    TToPlayerTurn = 2
} TTPlayerTurn;

@interface GameState : NSObject<NSCoding>

@property (nonatomic) TTPlayerTurn playersTurn;
@property (strong, nonatomic) NSMutableArray* boardState;

@end
