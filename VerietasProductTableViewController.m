//
//  VerietasProductTableViewController.m
//  Verietas Software
//
//  Created by Josh Pressnell on 6/5/13.
//
//

#import “VerietasProductTableViewController.h"
#import <Parse/Parse.h>
#import “VerietasProductCell.h"

@interface VerietasProductTableViewController ()

@end

@implementation VerietasProductTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [PFPurchaseTableViewCell swizzleIt];
    });
    
    // Do any additional setup after loading the view.
    self.navigationItem.title = @“Verietas Sound Packs";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(doRefresh)];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ProductDownloaded" object:nil queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      PFProduct* product = note.object;
                                                      NSString* path = [note.userInfo valueForKey:@"Path"];
                                                      
                                                      NSLog(@"Detected product(%@) was downloaded to %@.",product.productIdentifier,path);

                                                      // Do something with it here.
                                                  }];
}

- (void)doRefresh
{
    [PFPurchase restore];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
