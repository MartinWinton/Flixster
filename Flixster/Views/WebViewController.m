//
//  WebViewController.m
//  Flixster
//
//  Created by Martin Winton on 6/28/18.
//  Copyright © 2018 Martin Winton. All rights reserved.
//

#import "WebViewController.h"
#import "SVProgressHUD.h"
#import "DetailViewController.h"

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) NSString  *movieID;




@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNumber *number = self.movie[@"id"];
    self.movieID = [number stringValue];
    
    
    
    [SVProgressHUD showWithStatus:@"Loading Trailer..."];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getVideo];
        
    });


    
}



- (void) getVideo {
    
    
    NSString *beforeVideo = @"https://api.themoviedb.org/3/movie/";
    
    NSString *afterVideo = @"/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US";
    
    NSString *withID = [beforeVideo stringByAppendingString:self.movieID];
    
    NSString *finalMovieString  = [withID stringByAppendingString:afterVideo];
    
    NSURL *videoURL = [NSURL URLWithString:finalMovieString];
    
    

    
    

    NSURLRequest *request = [NSURLRequest requestWithURL:videoURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            
            
            NSLog(@"%@", [error localizedDescription]);
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error Loading Trailer"
                                                                           message:@"Check your internet connection and try again!"
                                                                    preferredStyle:(UIAlertControllerStyleAlert)];
            
            // create a cancel action
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Try Again"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                              
                                                                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                         [self getVideo];
                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                             
                                                                         });
                                                                     });
                                                                     
                                                                     
                                                                     
                                                                     
                                                                 }];
            // add the cancel action to the alertController
            [alert addAction:cancelAction];
            
            
            [self presentViewController:alert animated:YES completion:^{
                // optional code for what happens after the alert controller has finished presenting
            }];
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSLog(@"%@", dataDictionary);
            
            NSArray *results = dataDictionary[@"results"];
            
            if([results count] < 1){
                
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Trailers for this Movie"
                                                                               message:@"Return Home?"
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
                
                // create a cancel action
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Home"
                                                                       style:UIAlertActionStyleCancel
                                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                                         
                                                                         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                          
                                                                     

                                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                                 
                                                                                 [self performSegueWithIdentifier:@"back" sender:self];

                                                                            
                                                                                 
                                                                                 
                                                                                 [SVProgressHUD dismiss];
                                                                                 
                                                                                 
                                                                              
                                                                                 
                                                                             });
                                                                         });
                                                                         
                                                                         
                                                                         
                                                                         
                                                                     }];
                // add the cancel action to the alertController
                [alert addAction:cancelAction];
                
                
                [self presentViewController:alert animated:YES completion:^{
                    // optional code for what happens after the alert controller has finished presenting
                }];
                
                
                
                
            }
            
            else{
            
            NSDictionary *result = results[0];
            
            
            NSString *key = result[@"key"];
            
            
            
            NSString *beforeKey = @"https://www.youtube.com/watch?v=";
            

            

            
            
            NSString *withKey = [beforeKey stringByAppendingString:key];
            
            
            
            
            
            NSURL *youtube = [NSURL URLWithString:withKey];
            
            NSURLRequest *request = [NSURLRequest requestWithURL:youtube
                                                     cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                 timeoutInterval:10.0];
            // Load Request into WebView.
            [self.webView loadRequest:request];
            
                
            }
            
            [SVProgressHUD dismiss];



       
            
            
        }
        
    }];
    [task resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
