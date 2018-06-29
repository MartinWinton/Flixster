//
//  MoviesViewController.m
//  Flixster
//
//  Created by Martin Winton on 6/27/18.
//  Copyright © 2018 Martin Winton. All rights reserved.
//
#import "DetailViewController.h"
#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetWorking.h"
#import "SVProgressHUD.h"


@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic,strong) NSArray *movies;
@property (strong, nonatomic) NSArray *filteredMovies;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIColor *gold;


@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
    
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;

    
    [SVProgressHUD showWithStatus:@"Loading Movies..."];
   // UIColor *borderColor =  [UIColor blueColor];
    self.gold = [UIColor colorWithRed:255.0f/255.0f
                    green:215.0f/255.0f
                     blue:0.0f/255.0f
                    alpha:1.0f];
    [SVProgressHUD setForegroundColor:self.gold ];
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getMovies];
   
    });
    
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    
    [ self.refreshControl addTarget:self action:@selector(getMovies) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    
 
}




- (void) getMovies {
    
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            
            [SVProgressHUD dismiss];

            NSLog(@"%@", [error localizedDescription]);
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error Loading Movies"
                                                                           message:@"Check your internet connection and try again!"
                                                                    preferredStyle:(UIAlertControllerStyleAlert)];
            
            // create a cancel action
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Try Again"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                     
                                                                     [SVProgressHUD setForegroundColor:self.gold ];
                                                                     [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
                                                                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                         [self getMovies];
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
            
            self.movies = dataDictionary[@"results"];
            self.filteredMovies = self.movies;
            
            if(self.searchBar.text.length > 0){
                
                NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
                    
                    NSString *title = evaluatedObject[@"title"];
                    NSString *description = evaluatedObject[@"overview"];
                    
                    
                    
                    NSString *lowerTitle = [title lowercaseString];
                    NSString *lowerDescription = [description lowercaseString];
                    
                    
                    
                    
                    
                    return [lowerTitle containsString:[self.searchBar.text lowercaseString]] ||   [lowerDescription containsString:[self.searchBar.text lowercaseString]];
                    
                    
                }];
                self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
                
                NSLog(@"%@", self.filteredMovies);
                
                
            }
            
            [self.tableView reloadData];
            
            [SVProgressHUD dismiss];

            
            
           
        }
        
        [self.refreshControl endRefreshing];
    }];
    [task resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filteredMovies.count;
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor whiteColor]];
    self.searchBar.showsCancelButton = YES;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    UIView *backgroundView = [[UIView alloc] init];
    UIColor *dark = [UIColor colorWithRed:60.0f/255.0f
                                green:60.0f/255.0f
                                 blue:60.0f/255.0f
                                alpha:1.0f];
    backgroundView.backgroundColor = dark;
    cell.selectedBackgroundView = backgroundView;

    

    
    NSDictionary *movie = self.filteredMovies[indexPath.row];

    
    cell.titleLabel.text = movie[@"title"];
    cell.descriptionLabel.text = movie[@"overview"];
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    
    NSString *posterURLString = movie[@"poster_path"];
    
    
    NSString *finalString = [baseURLString stringByAppendingString:posterURLString];
    
    NSURL *posterURL = [NSURL URLWithString:finalString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:posterURL];
    
    __weak MovieCell *weakSelf = cell;
    
    [cell.movieImage setImageWithURLRequest:request placeholderImage:nil
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
    

    
  
   
    
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    
    NSDictionary *movie = self.filteredMovies[indexPath.row];
    DetailViewController *detailsViewController =  [segue destinationViewController];
    
    detailsViewController.movie = movie;
    
    
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    
    self.filteredMovies = self.movies;
    [self.tableView reloadData];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length != 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            
            NSString *title = evaluatedObject[@"title"];
            NSString *description = evaluatedObject[@"overview"];
            
            
                
            NSString *lowerTitle = [title lowercaseString];
            NSString *lowerDescription = [description lowercaseString];

                
            


            return [lowerTitle containsString:[searchText lowercaseString]] ||   [lowerDescription containsString:[searchText lowercaseString]];
            
            
        }];
        self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
        
        NSLog(@"%@", self.filteredMovies);
        
    }
    else {
        self.filteredMovies = self.movies;
    }
    
    [self.tableView reloadData];
    
}



@end
