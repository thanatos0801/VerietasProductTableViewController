//
//  VerietasProductCell.h
//  Verietas Software
//
//  Created by Josh Pressnell on 6/8/13.
//
//

#import <UIKit/UIKit.h>
#import <Parse/PFPurchaseTableViewCell.h>

@interface PFPurchaseTableViewCell (Verietas)

+ (void)swizzleIt;

- (void)oldLayoutSubviews;
- (void)oldSetState:(PFPurchaseTableViewCellState)state;

@end
