//
//  DetailViewController.m
//  Flixster
//
//  Created by Martin Winton on 6/27/18.
//  Copyright © 2018 Martin Winton. All rights reserved.
//

#import "DetailViewController.h"
#import "UIIMageView+AFNetworking.h"
#import "WebViewController.h"


@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UIImageView *backdropImage;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *synopsisLabel;

@end

@implementation DetailViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak DetailViewController *weakSelf = self;

    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    
    NSString *posterURLString = self.movie[@"poster_path"];
    
    
    
    NSString *finalString = [baseURLString stringByAppendingString:posterURLString];
    
    NSURL *posterURL = [NSURL URLWithString:finalString];
    
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:posterURL];

    
    
    [self.posterView setImageWithURLRequest:request placeholderImage:nil
                                       success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
                                           
                                           // imageResponse will be nil if the image is cached
                                           if (imageResponse) {
                                               NSLog(@"Image was NOT cached, fade in image");
                                               weakSelf.posterView.alpha = 0.0;
                                               weakSelf.posterView.image = image;
                                               
                                               //Animate UIImageView back to alpha 1 over 0.3sec
                                               [UIView animateWithDuration:0.3 animations:^{
                                                   weakSelf.posterView.alpha = 1.0;
                                               }];
                                           }
                                           else {
                                               NSLog(@"Image was cached so just update the image");
                                               weakSelf.posterView.image = image;
                                           }
                                       }
                                       failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
                                           // do something for the failure condition
                                       }];
    

  

    
    
    
    
    
    NSString *smallBackdropString = @"https://image.tmdb.org/t/p/w45";
    NSString *largeBackdropString = @"https://image.tmdb.org/t/p/original";


    NSString *backdropURLString = self.movie[@"backdrop_path"];
    
    
    NSString *largeBackDropFinal = [largeBackdropString stringByAppendingString:backdropURLString];
    
    NSURL *largeBackdropURL = [NSURL URLWithString:largeBackDropFinal];
    
    NSURLRequest *largeBackdropRequest = [NSURLRequest requestWithURL:largeBackdropURL];
    
    NSString *smallBackDropFinal = [smallBackdropString stringByAppendingString:backdropURLString];
    
    NSURL *smallBackdropURL = [NSURL URLWithString:smallBackDropFinal];
    
    NSURLRequest *smallBackdropRequest = [NSURLRequest requestWithURL:smallBackdropURL];
    
    UIImage * myImage = [UIImage imageNamed: @"error.png"];
    self.backdropImage.image = myImage;
    
    
    
    
    [self.backdropImage setImageWithURLRequest:smallBackdropRequest
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
                                       
                                       // smallImageResponse will be nil if the smallImage is already available
                                       // in cache (might want to do something smarter in that case).
                                       weakSelf.backdropImage.alpha = 0.0;
                                       weakSelf.backdropImage.image = smallImage;
                                       
                                       [UIView animateWithDuration:0.3
                                                        animations:^{
                                                            
                                                            weakSelf.backdropImage.alpha = 1.0;
                                                            
                                                        } completion:^(BOOL finished) {
                                                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                                                            // per ImageView. This code must be in the completion block.
                                                            [weakSelf.backdropImage setImageWithURLRequest:largeBackdropRequest
                                                                                      placeholderImage:smallImage
                                                                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
                                                                                                   weakSelf.backdropImage.image = largeImage;
                                                                                               }
                                                                                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                                   // do something for the failure condition of the large image request
                                                                                                   // possibly setting the ImageView's image to a default image
                                                                                               }];
                                                        }];
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       // do something for the failure condition
                                       // possibly try to get the large image
                                       
                             
                                   }];

    
    self.titleLabel.text = self.movie[@"title"];
    self.synopsisLabel.text = self.movie[@"overview"];
    
    [self.titleLabel sizeToFit];

    
    
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    WebViewController *webViewController =  [segue destinationViewController];
    webViewController.movie = self.movie;
}


@end
