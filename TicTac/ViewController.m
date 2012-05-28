//
//  ViewController.m
//  TicTac
//
//  Created by Michael Green on 5/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize xImage = _xImage;
@synthesize oImage = _oImage;
@synthesize theGameState = _theGameState;
@synthesize myShape = _myShape;
@synthesize myUUID = _myUUID;
@synthesize theSession = _theSession;
@synthesize myPeerID = _myPeerID;

@synthesize spaceButton;
@synthesize statusLabel;
@synthesize playerLabel = _playerLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Load the images
    self.xImage = [UIImage imageNamed:@"x.png"];
    self.oImage = [UIImage imageNamed:@"o.png"];
    
    // Create the game state
    self.theGameState = [[GameState alloc] init];
    
    // Initialize my shape to undetermined
    self.myShape = TTMyShapeUndetermined;
    
    // Generate my UUID
    self.myUUID = [self getUUIDString];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Show the peer picker
    GKPeerPickerController* picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    [picker show];
    
    // Initialize the game
    [self initGame];
}

- (void)viewDidUnload
{
    [self setStatusLabel:nil];
    [self setSpaceButton:nil];
    [self setPlayerLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)spaceButtonTapped:(id)sender {
    NSLog(@"Player tapped:  %i", [sender tag]);
    int spaceIndex = [sender tag];
    
    // If the space is blank and if it is my turn go, if not, ignore
    if ([[self.theGameState.boardState objectAtIndex:spaceIndex] isEqualToString:@" "] &&
          self.myShape == self.theGameState.playersTurn) {
        // Update game state
        if (self.theGameState.playersTurn == TTxPlayerTurn) {
            [self.theGameState.boardState replaceObjectAtIndex:spaceIndex withObject:@"x"];
            
            // It is now o's turn
            self.theGameState.playersTurn = TToPlayerTurn;
        } else {
            [self.theGameState.boardState replaceObjectAtIndex:spaceIndex withObject:@"o"];
            
            // It is now x's turn
            self.theGameState.playersTurn = TTxPlayerTurn;
        }
        
        // Update the board
        [self updateBoard];
        
        // Update the game status
        [self updateGameStatus];
        
        // Send the new game state out to peers
        NSData* theData = [NSKeyedArchiver archivedDataWithRootObject:self.theGameState];
        NSError* error;
        [self.theSession sendDataToAllPeers:theData withDataMode:GKSendDataReliable error:&error];
    }
}

- (void) initGame 
{
    // Initialize the game
    // Set player's turn to the x player because X always goes first
    self.theGameState.playersTurn=TTxPlayerTurn;
    
    // Set the status label
    self.statusLabel.text = @"X to move";
    
    // Clear the board state
    [self.theGameState.boardState removeAllObjects];
    for (int i = 0; i <= 8; i++) {
        // Insert a space to indicate a blank in the grid
        [self.theGameState.boardState insertObject:@" " atIndex:i];
    }
    
    [self updateBoard];
}

- (void) updateBoard
{
    // Given the state, update the board
    for (int i=0; i<=8; i++) {
        if ([[self.theGameState.boardState objectAtIndex:i] isEqualToString:@"x"]) {
            [[self.spaceButton objectAtIndex:i] setImage:self.xImage forState:UIControlStateNormal];
        } else if ([[self.theGameState.boardState objectAtIndex:i] isEqualToString:@"o"]) {
            [[self.spaceButton objectAtIndex:i] setImage:self.oImage forState:UIControlStateNormal];
        } else {
            [[self.spaceButton objectAtIndex:i] setImage:nil forState:UIControlStateNormal];
        }
    }
}

- (BOOL) didPlayerWin:(NSString *)player
{
    BOOL didPlayerWin = NO;
    // This method determines if the given player has won the game
    
    if (([[self.theGameState.boardState objectAtIndex:0] isEqualToString:player] &&
         [[self.theGameState.boardState objectAtIndex:1] isEqualToString:player] &&
         [[self.theGameState.boardState objectAtIndex:2] isEqualToString:player]) ||
        ([[self.theGameState.boardState objectAtIndex:3] isEqualToString:player] &&
         [[self.theGameState.boardState objectAtIndex:4] isEqualToString:player] &&
         [[self.theGameState.boardState objectAtIndex:5] isEqualToString:player]) ||
        ([[self.theGameState.boardState objectAtIndex:6] isEqualToString:player] &&
         [[self.theGameState.boardState objectAtIndex:7] isEqualToString:player] &&
         [[self.theGameState.boardState objectAtIndex:8] isEqualToString:player]) ||
        
        ([[self.theGameState.boardState objectAtIndex:0] isEqualToString:player] &&
         [[self.theGameState.boardState objectAtIndex:3] isEqualToString:player] &&
         [[self.theGameState.boardState objectAtIndex:6] isEqualToString:player]) ||
        ([[self.theGameState.boardState objectAtIndex:1] isEqualToString:player] &&
         [[self.theGameState.boardState objectAtIndex:4] isEqualToString:player] &&
         [[self.theGameState.boardState objectAtIndex:7] isEqualToString:player]) ||
        ([[self.theGameState.boardState objectAtIndex:2] isEqualToString:player] &&
         [[self.theGameState.boardState objectAtIndex:5] isEqualToString:player] &&
         [[self.theGameState.boardState objectAtIndex:8] isEqualToString:player]) ||
        
        ([[self.theGameState.boardState objectAtIndex:0] isEqualToString:player] &&
         [[self.theGameState.boardState objectAtIndex:4] isEqualToString:player] &&
         [[self.theGameState.boardState objectAtIndex:8] isEqualToString:player]) ||
        ([[self.theGameState.boardState objectAtIndex:2] isEqualToString:player] &&
         [[self.theGameState.boardState objectAtIndex:4] isEqualToString:player] &&
         [[self.theGameState.boardState objectAtIndex:6] isEqualToString:player])) {
            didPlayerWin = YES;
    }
    
    return didPlayerWin;
}

- (TTGameOverStatus) checkGameOver
{
    // This method checks to see if the game is over.  Default is a tie unless proven otherwise
    TTGameOverStatus gameOverStatus = TTGameOverTie;
    
    if ([self didPlayerWin:@"x"]) {  // Did x win?
        gameOverStatus = TTGameOverXWins;
    } else if ([self didPlayerWin:@"o"]) {
        gameOverStatus = TTGameOverOWins; // Did o win?
    } else {
        // No winner.  Check to see if there are open spaces left on the board
        // because if there are not any open spaces, the game is a tie.
        for (int i=0; i<=8; i++) {
            if ([[self.theGameState.boardState objectAtIndex:i] isEqualToString:@" "]) {
                gameOverStatus = TTGameNotOver;
                break;
            }
        }
    }
    
    return gameOverStatus;
}

- (void) updateGameStatus
{
    // Check for win or tie
    TTGameOverStatus gameOverStatus = [self checkGameOver];
    
    switch (gameOverStatus) {
        case TTGameNotOver:
            // The game is not over
            // Next player's turn
            if (self.theGameState.playersTurn == TTxPlayerTurn) {
                // Set the status label
                self.statusLabel.text = @"X to move";
            } else {
                // Set the status label
                self.statusLabel.text = @"O to move";
            }
            break;
        case TTGameOverOWins:
        case TTGameOverXWins:
        case TTGameOverTie:
            // Game is over
            [self endGameWithResult:gameOverStatus];
        default:
            break;
    }
}
- (void) endGameWithResult: (TTGameOverStatus) result
{
    NSString* gameOverMessage;
    
    switch (result) {
        case TTGameOverXWins:
            gameOverMessage = [NSString stringWithString:@"X wins"];
            break;
        case TTGameOverOWins:
            gameOverMessage = [NSString stringWithString:@"O wins"];
            break;
        case TTGameOverTie:
            gameOverMessage = [NSString stringWithString:@"The game is a tie"];
            break;
        default:
            break;
    }
    
    // Show an alert with the results
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over" 
                                                    message:gameOverMessage
                                                   delegate:self 
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView  clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Reset the game
    [self initGame];
}

- (NSString*) getUUIDString
{
    NSString * result;
    CFUUIDRef uuid;
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    uuidStr = CFUUIDCreateString(NULL, uuid);
    result = [NSString stringWithFormat:@"%@", uuidStr];
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

- (void) peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    // Tells the delegate that the controller connected a peer to the session.
    // Once a peer is connected to the session, your application should take
    // ownership of the session, dismiss the peer picker, and then use the 
    // session to communicate with the other peer.
    
    // Store off the session
    self.theSession = session;
    
    // Stre the Peer ID
    self.myPeerID = peerID;
    
    // Set the receive data handler
    [session setDataReceiveHandler:self withContext:nil];
    
    // Dismiss the picker
    [picker dismiss];
    
    // Session is connected so negotiate shapes
    //  Send out UUID
    NSData* theData = [NSKeyedArchiver archivedDataWithRootObject:self.myUUID];
    NSError* error;
    
    [self.theSession sendDataToAllPeers:theData withDataMode:GKSendDataReliable error:&error];
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context
{
    // The receive data handler
    NSLog(@"Received data");
    
    // If myShape == TTMyShapeUndetermined we should get shape negotiation data
    if (self.myShape == TTMyShapeUndetermined) {
        NSString* peerUUID = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if ([self.myUUID compare:peerUUID] == NSOrderedAscending) {
            self.myShape = TTMyShapeX;
            self.playerLabel.text  = @"You are player X";
        } else {
            self.myShape = TTMyShapeO;
            self.playerLabel.text = @"You are player O";
        }
    } else {
        // Update the board state with the received data
        self.theGameState = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        // Received datga so update the board and the game status
        [self updateBoard];
        [self updateGameStatus];
    }
}
@end
