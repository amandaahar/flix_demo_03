//
//  MoviesViewController.m
//  flix_demo_03
//
//  Created by amandahar on 6/26/19.
//  Copyright © 2019 amandahar. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"

// the AFNetworking library adds a few helper function to the UIImage view

#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

// <UITableViewDataSource, UITableViewDelegate> says that this class implements
// data source and delegate meaning this class is a data source now
// this means that MoviesViewController will implement the methods associated
// with DataSource and Delegate; it seems like a data source is kind of like a interface in Java.
@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

// property of type NSArray called movies; getters and setters are automatocally
// created with the property declaration as well as an encapsulated version of *movies
// strong means to increment the reference count of movies so it does't go away

@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set data source and delegate equal to this view controller
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self fetchMovies];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    // this calls the fetchMovies fn on self when refresh control is triggers which corresponds to UIControlEventValueChanged
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    
    
}

- (void)fetchMovies {
    //network call
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    // ^ is the start of the block. The code within the block is what's called when the network call is finished
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSLog(@"%@", dataDictionary);
            
            // self. is similar to saying this. in java
            self.movies = dataDictionary[@"results"];
            for (NSDictionary *movie in self.movies) {
                // NSLog(@"%@", movie[@"title"]);
            }
            
            // this calls data source methods again since it takes awhile for the movies to
            // load from the database
            [self.tableView reloadData];
            
            // TODO: Get the array of movies
            // TODO: Store the movies in a property to use elsewhere
            // TODO: Reload your table view data
        }
        [self.refreshControl endRefreshing];
    }];
    [task resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // java: UITableViewCell cell = UITableViewCell();
    // alloc means create me an instance of the specified type
    // init = manually calling initializer
    // UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    //rather than assigning cell to [[UITableViewCell alloc] init] we will assign it to the table view cell (cell template) we made in the main story board
    // its called dequeReusable so as you scroll off it will store the cell in some reusable memory
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    
    NSDictionary *movie = self.movies[indexPath.row];
    // sets text that appears on each cell
    // cell.textLabel.text = movie[@"title"];
    
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    
    // NSURL is basically a string except it checks to see if a URL is valid or not
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:posterURL];
    return cell;
}


#pragma mark - Navigation


// In a storyboard-based application, you will often want to do a little preparation before navigation
// this method is basically asking if you want the next view controller to know a property about the current view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    // gets index for movie you clicked on?
    NSDictionary *movie = self.movies[indexPath.row];
    
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie;
    
    // NSLog(@"Tapping on a movie");
}
 


@end
