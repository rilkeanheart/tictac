//
//  ViewController.h
//  TicTac
//
//  Created by Michael Green on 5/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "GameState.h"

typedef enum {
    TTGameNotOver = 0,      // The Game is NOT over
    TTGameOverXWins = 1,    // The X player won
    TTGameOverOWins = 2,    // The Y player won
    TTGameOverTie = 3,      // The game is a tie
} TTGameOverStatus;

typedef enum {
    TTMyShapeUndetermined = 0,
    TTMyShapeX = 1,
    TTMyShapeO = 2
} TTMyShape;

@interface ViewController : UIViewController<GKPeerPickerControllerDelegate>
// (non-IBOutle) Member Variables
@property (strong, nonatomic) UIImage* xImage;
@property (strong, nonatomic) UIImage* oImage;
@property (strong, nonatomic) GameState* theGameState;
@property (nonatomic) TTMyShape myShape; // Which player am I
@property (strong, nonatomic) NSString* myUUID; // Store my UUID
// GameKit Variables
@property (strong, nonatomic) GKSession* theSession;
@property (strong, nonatomic) NSString* myPeerID;

// IBOutlets
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *spaceButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerLabel;

// IBActions
- (IBAction)spaceButtonTapped:(id)sender;

// Method Declarations
- (void) initGame;
- (void) updateBoard;
- (void) updateGameStatus;
- (TTGameOverStatus) checkGameOver;
- (BOOL) didPlayerWin: (NSString*) player;
- (void) endGameWithResult: (TTGameOverStatus) result;
- (NSString*) getUUIDString;
@end
