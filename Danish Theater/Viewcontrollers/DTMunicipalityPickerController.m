//
//  DTMunicipalityPickerController.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/2/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTMunicipalityPickerController.h"

@import Firebase;

@interface DTMunicipalityPickerController ()

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSIndexPath *usersLocalMunicipalityIndexPath; // not yet in use.

@end

@implementation DTMunicipalityPickerController
@synthesize delegate;

#pragma mark - Initializers
- (instancetype)initWithMunicipalities:(NSArray <NSString *> *)municipalities {
    self = [super init];
    if (self) {
        _municipalities = [NSArray arrayWithArray:municipalities];
    }
    
    return self;
}

/*
- (instancetype)init {
    self = [super init];
    if (self) {
        if (_municipalities.count == 0) {
            [DanishTheater loadMunicipalitiesWithCompletion:^(NSError * _Nonnull error, NSArray<NSString *> * _Nonnull municipalities) {
                _municipalities = [municipalities copy];
                
            }];
        }
    }
    
    return self;
}
*/

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _navigationBar = [[UINavigationBar alloc] initForAutoLayout];
    _navigationBar.translucent = YES;
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"MUNICIPALITIES_NAVBAR_TITLE", nil)];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CANCEL_ITEM_TITLE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    [navItem setLeftBarButtonItem:cancelItem];
    
    [_navigationBar setItems:@[navItem]];
    
    [self.view addSubview:_navigationBar];
    
    [_navigationBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [_navigationBar autoSetDimension:ALDimensionHeight toSize:44 + [UIApplication sharedApplication].statusBarFrame.size.height];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view insertSubview:_tableView belowSubview:_navigationBar];
    [_tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [_tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_navigationBar];
    
    _selectedIndexPath = [NSIndexPath indexPathForRow:[_municipalities indexOfObject:_selectedMunicipality] inSection:0];
    _usersLocalMunicipalityIndexPath = nil;
    if (_usersLocalMunicipaltiy) {
        _usersLocalMunicipalityIndexPath = [NSIndexPath indexPathForRow:[_municipalities indexOfObject:_usersLocalMunicipaltiy] inSection:0];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_tableView scrollToRowAtIndexPath:_selectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

#pragma mark - UITableViewCellDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _municipalities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    NSString *municipality = [_municipalities objectAtIndex:indexPath.row];
    
    if (indexPath == _selectedIndexPath) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (_usersLocalMunicipalityIndexPath == indexPath) {
        cell.detailTextLabel.text = NSLocalizedString(@"CURRENT_LOCATION_DETAIL_TEXT", nil); // subtitle
        // cell.textLabel.attributedText = [self attributedTextWithMunicipality:municipality];
    }
    
    cell.textLabel.text = municipality;
    
    return cell;
    
}

#pragma mark - UITableViewCellDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSIndexPath *prevSelectedIndexPath = _selectedIndexPath;
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (_selectedIndexPath != indexPath) {
        _selectedIndexPath = indexPath;
        
        [_tableView reloadRowsAtIndexPaths:@[prevSelectedIndexPath, _selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    NSString *selectedMunicipality = selectedCell.textLabel.text;
    
    if ([delegate respondsToSelector:@selector(municipalityPickerController:didFinishPickingWithMuncipality:)]) {
        [delegate municipalityPickerController:self didFinishPickingWithMuncipality:selectedMunicipality];
    }
    
    _completion(NO, selectedMunicipality);
    
    [self dismissViewControllerAnimated:YES completion:nil]; // set a delay here and how?
}


#pragma mark - Actions
- (IBAction)cancel:(id)sender {
    if ([delegate respondsToSelector:@selector(municipalityPickerControllerDidCancel:)]) {
        [delegate municipalityPickerControllerDidCancel:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        _completion(YES, nil);
    }];
}

#pragma mark - Helpers
- (NSAttributedString *)attributedTextWithMunicipality:(NSString *)municipality {
    
    /* Icon before text
     NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
     
     NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
     attachment.image = [[UIImage imageNamed:@"ic_near_me_18pt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
     attachment.bounds = CGRectMake(0, -3, attachment.image.size.width, attachment.image.size.height);
     [attrStr appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
     
     [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, 1)];
     
     [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", municipality]]];
     
     return attrStr;
     */
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", municipality]];
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [[UIImage imageNamed:@"ic_near_me_18pt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    attachment.bounds = CGRectMake(0, -3, attachment.image.size.width, attachment.image.size.height);
    [attrStr appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange([attrStr string].length - 2, 2)];
    
    return attrStr;
}

#pragma mark - Convenience Methods
+ (void)getNearestMunicipalityWithLocation:(CLLocation *)location withSuccess:(void (^)(NSString *municipality))success failure:(void (^)(NSError *error))failure {
    
    NSString *geop = [NSString stringWithFormat:@"%f,%f", location.coordinate.longitude, location.coordinate.latitude];
    
    Geokeys *geokeys = [[Geokeys alloc] initWithLogin:@"DanielRanLehmann" password:@"Daniel11"];
    [geokeys GET:GKMunicipality parameters:@{@"geop" : geop, @"georef": NSStringFromEPSG(EPSGMake(4326))} completionHandler:^(NSError *error, id response) {
        
        if (!error) {
            success(response[@"features"][0][@"properties"][@"navn"]);
            return;
        }
        
        else {
            failure(error);
            return;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
