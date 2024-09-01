//
//  CalleeObject.m
//  USBUtils
//
//  Created by rA9 on 1.09.2024.
//

#import <Foundation/Foundation.h>
#import "CalleeObject.h"
#import "USBUtils.h"

@implementation CalleeObject

- (void)handleUSBDeviceAdded:(NSNotification *)notification {
    NSString *deviceName = notification.userInfo[@"deviceName"];
    NSString *vendorID = notification.userInfo[@"vendorID"];
    printf("[ADDED]:   %s VID: %s\n", deviceName.UTF8String, vendorID.UTF8String);
}

- (void)handleUSBDeviceRemoved:(NSNotification *)notification {
    NSString *deviceName = notification.userInfo[@"deviceName"];
    NSString *vendorID = notification.userInfo[@"vendorID"];
    printf("[REMOVED]: %s VID: %s\n", deviceName.UTF8String, vendorID.UTF8String);
}


- (instancetype) init {
    
    self = [super init];
    if (self) {
        NSString* USBDeviceAddedNotification = @"USBDeviceAddedNotification";
        NSString* USBDeviceRemovedNotification = @"USBDeviceRemovedNotification";

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleUSBDeviceAdded:)
                                                     name:USBDeviceAddedNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleUSBDeviceRemoved:)
                                                     name:USBDeviceRemovedNotification
                                                   object:nil];

        USBUtils *utils = [[USBUtils alloc] init];
    }
    return self;
}



@end
