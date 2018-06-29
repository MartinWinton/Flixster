//
//  GridViewController.m
//  Flixster
//
//  Created by Martin Winton on 6/28/18.
//  Copyright © 2018 Martin Winton. All rights reserved.
//
#import "DetailViewController.h"
#import "GridViewController.h"
#import "MovieCollectionViewCell.h"
#import "UIImageView+AFNetWorking.h"
#import "SVProgressHUD.h"

@interface GridViewController () <UICollectionViewDataSource, UICollectionViewDelegate,UISearchBarDelegate>
@property (nonatomic,strong) NSArray *movies;
@property (strong, nonatomic) NSArray *filteredMovies;


@property (weak, nonatomic) IBOutlet UICollectionView *movieGridView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


@end

@implementation GridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.movieGridView.dataSource = self;
    self.movieGridView.delegate = self;
    self.searchBar.delegate = self;

    // Do any additional setup after loading the view.
    
    [SVProgressHUD showWithStatus:@"Loading Classics..."];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getMovies];
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    });
    
    UICollectionViewFlowLayout *layout =  (UICollectionViewFlowLayout*) self.movieGridView.collectionViewLayout;
    
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    
    CGFloat postersPerLine = 2;
    
    CGFloat itemWidth = (self.movieGridView.frame.size.width- layout.minimumInteritemSpacing * (postersPerLine-1))/postersPerLine;
    
    CGFloat itemHeight = itemWidth * 1.6;
    
    
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    
    [ self.refreshControl addTarget:self action:@selector(getMovies) forControlEvents:UIControlEventValueChanged];
    
    [self.movieGridView insertSubview:self.refreshControl atIndex:0];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getMovies {
    
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/2000/recommendations?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
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
                                                                     
                                                                     [SVProgressHUD showWithStatus:@"Retrying..."];
                                                                     UIColor *borderColor =  [UIColor redColor];
                                                                     [SVProgressHUD setForegroundColor:borderColor ];
                                                                     
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
            
            

            
            [self.movieGridView reloadData];


            
            
            [SVProgressHUD dismiss];
            
            
            
            
        }
        [self.refreshControl endRefreshing];

        
    }];
    [task resume];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    
    MovieCollectionViewCell *tappedCell = sender;
    


    
    
    NSIndexPath *indexPath = [self.movieGridView indexPathForCell:tappedCell];
    
    NSDictionary *movie = self.filteredMovies[indexPath.row];
    DetailViewController *detailsViewController =  [segue destinationViewController];
    
    detailsViewController.movie = movie;
    
 
    
}



- (UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    MovieCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"gridcell" forIndexPath:indexPath];
    

    
    NSDictionary *movie = self.filteredMovies[indexPath.item];

    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    
    NSString *posterURLString = movie[@"poster_path"];
    
    
    NSString *finalString = [baseURLString stringByAppendingString:posterURLString];
    
    NSURL *posterURL = [NSURL URLWithString:finalString];
    __weak MovieCollectionViewCell *weakSelf = cell;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:posterURL];

    
    
    [cell.gridImage setImageWithURLRequest:request placeholderImage:nil
                                   success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
                                       
                                       // imageResponse will be nil if the image is cached
                                       if (imageResponse) {
                                           NSLog(@"Image was NOT cached, fade in image");
                                           weakSelf.gridImage.alpha = 0.0;
                                           weakSelf.gridImage.image = image;
                                           
                                           //Animate UIImageView back to alpha 1 over 0.3sec
                                           [UIView animateWithDuration:0.5 animations:^{
                                               weakSelf.gridImage.alpha = 1.0;
                                           }];
                                       }
                                       else {
                                           NSLog(@"Image was cached so just update the image");
                                           weakSelf.gridImage.image = image;
                                       }
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
                                       // do something for the failure condition
                                   }];
    
    
    
    
    return cell;
    

    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MovieCollectionViewCell *cell = (MovieCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell makeDark];
    [cell reset];


}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.filteredMovies.count;

}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor whiteColor]];
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    
    self.filteredMovies = self.movies;
    [self.movieGridView reloadData];
    
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
    
    [self.movieGridView reloadData];
    
}



@end
