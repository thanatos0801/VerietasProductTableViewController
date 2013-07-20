//
//  VerietasProductCell.m
//  Verietas Software
//
//  Created by Josh Pressnell on 6/8/13.
//
//

#import “VerietasProductCell.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <Parse/Parse.h>

void Swizzle(Class c, SEL orig, SEL new, SEL rename);
void Swizzle(Class c, SEL orig, SEL new, SEL rename)
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    
    class_addMethod(c, rename, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

@implementation PFPurchaseTableViewCell (Verietas)

+ (void)swizzleIt
{
    Swizzle([PFPurchaseTableViewCell class], @selector(layoutSubviews), @selector(myLayoutSubviews), @selector(oldLayoutSubviews));
    Swizzle([PFPurchaseTableViewCell class], @selector(setState:), @selector(mySetCellState:), @selector(oldSetState:));
}

- (void)myLayoutSubviews
{
    [self oldLayoutSubviews];
    self.detailTextLabel.numberOfLines = 2;
    CGRect frame = self.detailTextLabel.frame;
    frame.size.height = 30.0;
    self.detailTextLabel.frame = frame;
}

- (NSString *)getPrivateDocsDir {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Private Documents"];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Parse"];
    
    return documentsDirectory;    
}

- (void)mySetCellState:(PFPurchaseTableViewCellState)newState
{
    PFPurchaseTableViewCellState oldState = self.state;
    
    [self oldSetState:newState];
    
    if( newState == PFPurchaseTableViewCellStateDownloaded && oldState == PFPurchaseTableViewCellStateDownloading )
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            PFQuery *productQuery = [PFProduct query];
            NSArray* products = [productQuery findObjects];
            for( PFProduct* product in products )
            {
                if( [product.title isEqualToString:self.textLabel.text] )
                {
                    // This is a bit of a hack, but it’s the best we can do with the level of access provided so far.
                    NSString* downloadPath = [[[self getPrivateDocsDir]stringByAppendingPathComponent:product.productIdentifier]stringByAppendingPathComponent:product.downloadName];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ProductDownloaded" object:product userInfo:@{@"Path":downloadPath}];
                    });
                }
            }
        });
    }
}

@end
