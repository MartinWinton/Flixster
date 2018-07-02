//
//  Movie.m
//  Flixster
//
//  Created by Martin Winton on 7/2/18.
//  Copyright © 2018 Martin Winton. All rights reserved.
//

#import "Movie.h"

@implementation Movie

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    self.title = dictionary[@"title"];
    
    self.overview = dictionary[@"overview"];
    
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    
    NSString *posterURLString = dictionary[@"poster_path"];
    
    
    NSString *finalString = [baseURLString stringByAppendingString:posterURLString];
    
    self.posterUrl = [NSURL URLWithString:finalString];
    
    
    /*
    
    NSURLRequest *request = [NSURLRequest requestWithURL:posterURL];
    
    __weak Movie *weakSelf = self;
    
    [self.movieImage setImageWithURLRequest:request placeholderImage:nil
                                    success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
                                        
                                        // imageResponse will be nil if the image is cached
                                        if (imageResponse) {
                                            NSLog(@"Image was NOT cached, fade in image");
                                            weakSelf.movieImage.alpha = 0.0;
                                            weakSelf.movieImage.image = image;
                                            
                                            //Animate UIImageView back to alpha 1 over 0.3sec
                                            [UIView animateWithDuration:0.3 animations:^{
                                                weakSelf.movieImage.alpha = 1.0;
                                            }];
                                        }
                                        else {
                                            NSLog(@"Image was cached so just update the image");
                                            weakSelf.movieImage.image = image;
                                        }
                                    }
                                    failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
                                        // do something for the failure condition
                                    }];
    
    
    */

    return self;
}

+ (NSMutableArray *)moviesWithDictionaries:(NSMutableArray *)dictionaries {
    
    NSMutableArray *movies = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dictionary in dictionaries) {
        Movie *movie = [[Movie alloc] initWithDictionary:dictionary];
        
        [movies addObject:movie];
    }
    
    return movies;

    
}

@end
