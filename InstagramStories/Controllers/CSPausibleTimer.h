//
//  CSPausibleTimer.h
//  uFilmer
//
//  Created by Chris Shaheen on 3/28/13.
//  Copyright (c) 2013 Codeslaw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSPausibleTimer : NSObject

//Timer Info
@property (nonatomic) NSTimeInterval timeInterval;
@property (nonatomic, weak) id target;
@property (nonatomic) SEL selector;
@property (nonatomic) id userInfo;
@property (nonatomic) BOOL repeats;

@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) BOOL isPaused;

+(CSPausibleTimer *)timerWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)repeats;

-(void)pause;
-(void)start;

@end
