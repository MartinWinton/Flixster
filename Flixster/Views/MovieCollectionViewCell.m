//
//  MovieCollectionViewCell.m
//  Flixster
//
//  Created by Martin Winton on 6/28/18.
//  Copyright © 2018 Martin Winton. All rights reserved.
//

#import "MovieCollectionViewCell.h"

@implementation MovieCollectionViewCell

- (void)makeDark{
    [UIView animateWithDuration:.5f animations:^{
        self.gridImage.alpha = .5;
    }];

}

- (void)reset{
    
    [UIView animateWithDuration:0.5f animations:^{
        self.gridImage.alpha = 1;
    }];

}


@end

