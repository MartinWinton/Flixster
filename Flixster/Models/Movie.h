//
//  Movie.h
//  Flixster
//
//  Created by Martin Winton on 7/2/18.
//  Copyright © 2018 Martin Winton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Movie : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *overview;

@property (nonatomic, strong) NSURL *posterUrl;

- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (NSMutableArray *)moviesWithDictionaries: (NSMutableArray *) dictionaries;



@end
