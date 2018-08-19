//
//  ViewController.m
//  WikiSearch
//
//  Created by Sandhya on 18/08/18.
//  Copyright © 2018 Sandhya. All rights reserved.
//

#import "ViewController.h"
#import "HTTPRequest.h"
#import "WebViewViewController.h"

@interface ViewController ()<HttpDelegte,UITableViewDelegate,UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating,UIPopoverPresentationControllerDelegate>
{
    NSArray * arrResults ;
    NSIndexPath * selectedIndex;
    BOOL isSelectedIndex;
}

@property (strong, nonatomic)  UITableViewCell *searchCell;
@property (weak, nonatomic) IBOutlet UITableView *tbleSearchResult;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnstrntImageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnstrntImageHeight;
@property (strong, nonatomic)  UISearchBar *searchBar;
@property (nonatomic, strong) UISearchController *searchController;
@end

@implementation ViewController
-(void)responseData:(id )responseData withReqType:(NSString *)type
{
    NSString * pageNo = [[[arrResults objectAtIndex:selectedIndex.row] objectForKey:@"pageid"] stringValue];
    id reponse = [[responseData objectForKey:@"query"] objectForKey:@"pages"];
    
    if(![reponse isKindOfClass:[NSArray class]])
    {
        if(![[[[responseData objectForKey:@"query"] objectForKey:@"pages"] allKeys] containsObject:pageNo])
        {
            arrResults = [[responseData objectForKey:@"query"] objectForKey:@"pages"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tbleSearchResult reloadData];
            });        }
        else
        {
            NSString * url = [[[[responseData objectForKey:@"query"] objectForKey:@"pages"] objectForKey:pageNo] objectForKey:@"fullurl"];
            [self loadDetailView:url];
        }
    }
    else
    {
        arrResults = [[responseData objectForKey:@"query"] objectForKey:@"pages"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tbleSearchResult reloadData];
        });
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _searchBar.layer.borderWidth = 0;
    _searchBar.layer.shadowOpacity = 0;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [_searchController.searchBar setBackgroundColor:[UIColor whiteColor]];
    if (!_searchController.searchBar.superview) {
        self.tbleSearchResult.tableHeaderView = self.searchController.searchBar;
    }
    //if (!self.searchController.active && self.searchController.searchBar.text.length == 0) {
      //  self.tbleSearchResult.contentOffset = CGPointMake(50, CGRectGetHeight(self.searchController.searchBar.frame));
    //}
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.searchController.isActive) {
        self.searchController.active = NO;
    }
}

-(void)loadDetailView :(NSString * )url
{
    WebViewViewController *contentVC = [[WebViewViewController alloc] init];
    contentVC.URL = url;
    UITableViewCell* cell = [_tbleSearchResult cellForRowAtIndexPath:selectedIndex];
    
    contentVC.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popPC = contentVC.popoverPresentationController;
    contentVC.preferredContentSize = CGSizeMake( 400,400);
    CGRect frame = self.view.frame;
    contentVC.popoverPresentationController.sourceRect = CGRectMake(frame.size.width - 100, cell.frame.origin.y + 40, 0,0 );
    contentVC.popoverPresentationController.sourceView = self.view;
    popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popPC.backgroundColor = [UIColor whiteColor];
    popPC.delegate = self;

    if(_searchController.active)
    {
        [_searchController dismissViewControllerAnimated:YES completion:^{
            [self presentViewController:contentVC animated:YES completion:nil];
        }];
        
    }
    else
    {
        [self presentViewController:contentVC animated:YES completion:nil];
        
    }

}

#pragma mark - Tableview DataSource methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrResults count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _searchCell  = [tableView dequeueReusableCellWithIdentifier:@"ResultCell"];
    
    if (_searchCell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SearchResultCell" owner:self options:nil];
        _searchCell = [nib objectAtIndex:0];
    }
    
    NSDictionary * dictData;
    
    dictData = [arrResults objectAtIndex:indexPath.row];
    
    
    UIImageView * image = [_searchCell viewWithTag:1];
    UILabel * lblTitle = [_searchCell viewWithTag:2];
    UILabel * lblDesc = [_searchCell viewWithTag:3];
    
    [image setBackgroundColor:[UIColor clearColor]];
    lblTitle.text = [dictData objectForKey:@"title"];
    lblDesc.text = [[[dictData objectForKey:@"terms"] objectForKey:@"description"] objectAtIndex:0];

    if([[dictData allKeys] containsObject:@"thumbnail"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _cnstrntImageWidth.constant = [[[dictData objectForKey:@"thumbnail"] objectForKey:@"width"] doubleValue];
            _cnstrntImageHeight.constant = [[[dictData objectForKey:@"thumbnail"] objectForKey:@"height"] doubleValue];
        });
        
        
       dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       ^{
                           NSString * imgURL = [[dictData objectForKey:@"thumbnail"] objectForKey:@"source"];
                           NSURL *imageURL = [NSURL URLWithString:imgURL];
                           NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                           
                           dispatch_sync(dispatch_get_main_queue(), ^{
                               UIImage * imageToSet = [UIImage imageWithData:imageData];
                               image.image = imageToSet;
                               
                           });
                       }
                       );
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _cnstrntImageWidth.constant = 0;
        });
    }
    
    return _searchCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}

#pragma mark - Tableview Delegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = indexPath;
    isSelectedIndex = YES;
    NSString * urlString = [NSString stringWithFormat:@"https://en.wikipedia.org/w/api.php?action=query&prop=info&pageids=%@&inprop=url&format=json",[[arrResults objectAtIndex:indexPath.row] objectForKey:@"pageid"]];
    
    HTTPRequest *request =[[HTTPRequest alloc] init];
    [request initRequestWithRequestData:urlString withEntityType:@"Detail"];
    request.delegate = self;
 
}

#pragma mark - UIPopoverPresentationController Delegate
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection
{
    return UIModalPresentationNone;
}
#pragma mark - Searchbar Methods

- (UISearchController *)searchController {
    if (!_searchController) {
        _searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
        _searchController.searchResultsUpdater = self;
        _searchController.dimsBackgroundDuringPresentation = NO;
        _searchController.searchBar.delegate = self;
        _searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        [_searchController.searchBar sizeToFit];
    }
    return _searchController;
}
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {

    if(_searchController.isActive && searchController.searchBar.text.length > 0 && ![searchController.searchBar.text isEqualToString:@" "])
    {
        NSString * urlString = [NSString stringWithFormat:@"https://en.wikipedia.org/w/api.php?action=query&formatversion=2&generator=prefixsearch&gpslimit=10&prop=pageimages%%7Cpageterms&piprop=thumbnail&pithumbsize=50&pilimit=%@&redirects=&wbptterms=description&format=json&gpssearch=%@",@"10",searchController.searchBar.text];

        HTTPRequest *request =[[HTTPRequest alloc] init];
        [request initRequestWithRequestData:urlString withEntityType:@"Search"];
        request.delegate = self;
    }
    else if(searchController.searchBar.text.length == 0 )
    {
        arrResults = nil;
        [_tbleSearchResult reloadData];
    }


}
@end
