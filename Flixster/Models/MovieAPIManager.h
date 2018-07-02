//
//  MovieAPIManager.h
//  Flixster
//
//  Created by Martin Winton on 7/2/18.
//  Copyright © 2018 Martin Winton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovieAPIManager : NSObject

- (void)fetchNowPlaying:(void(^)(NSArray *movies, NSError *error))completion;

@end
