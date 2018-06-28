//
//  MovieCollectionViewCell.h
//  Flixster
//
//  Created by Martin Winton on 6/28/18.
//  Copyright © 2018 Martin Winton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieCollectionViewCell : UICollectionViewCell

- (void)makeDark;
- (void)reset;





@property (weak, nonatomic) IBOutlet UIImageView *gridImage;

@end
