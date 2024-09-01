//
//  USBUtils.m
//  USBUtils
//
//  Created by rA9 on 1.09.2024.
//

#import <Foundation/Foundation.h>
#include <IOKit/usb/IOUSBLib.h>
#import "USBUtils.h"

@implementation USBUtils

io_iterator_t detectionIterator, removalIterator;
NSString* USBDeviceAddedNotification = @"USBDeviceAddedNotification";
NSString* USBDeviceRemovedNotification = @"USBDeviceRemovedNotification";

- (NSString*) getManufacturerIDOfUSBDevice: (io_object_t) usbDevice {
    kern_return_t kernResult;
    CFMutableDictionaryRef properties = NULL;
    
    // Retrieve the device properties
    kernResult = IORegistryEntryCreateCFProperties(usbDevice, &properties, kCFAllocatorDefault, kNilOptions);
    if (kernResult != KERN_SUCCESS) {
        NSLog(@"Unable to access USB device properties");
        return @"err";
    }
    
    // Get the vendor ID (manufacturer ID)
    CFNumberRef vendorIDRef = CFDictionaryGetValue(properties, CFSTR(kUSBVendorID));
    if (!vendorIDRef) {
        NSLog(@"Vendor ID not found");
        CFRelease(properties);
        return @"err";
    }
    
    int vendorID;
    if (!CFNumberGetValue(vendorIDRef, kCFNumberIntType, &vendorID)) {
        NSLog(@"Unable to get vendor ID");
        CFRelease(properties);
        return @"err";
    }
    
    CFRelease(properties);
    
    // Return the vendor ID as a string
    return [NSString stringWithFormat:@"%04x", vendorID];
}


- (NSString*) getNameOfUSBDevice: (io_object_t) usbDevice {
    kern_return_t kernResult;
    CFMutableDictionaryRef properties = NULL;
    kernResult = IORegistryEntryCreateCFProperties(usbDevice, &properties, kCFAllocatorDefault, kNilOptions);
    if (kernResult != KERN_SUCCESS) {
        NSLog(@"Unable to access USB device properties");
        return @"err";
    }
    CFTypeRef nameRef = CFDictionaryGetValue(properties, CFSTR(kUSBProductString));
    if (!nameRef) {
        NSLog(@"Name not found");
        return @"err";
    }
    CFStringRef nameStrRef = (CFStringRef)nameRef;
    char nameCStr[1024];
    if (!CFStringGetCString(nameStrRef, nameCStr, 1024, kCFStringEncodingUTF8)) {
        NSLog(@"Unable to get C string representation of name");
        return @"err";
    }

    NSString *name = [NSString stringWithCString:nameCStr encoding:NSUTF8StringEncoding];
    CFRelease(properties);
    return name;
}

- (void) USBDeviceDetectedCallback:(void *)refcon iterator: (io_iterator_t) iterator {
    io_object_t usbDevice;
    while ((usbDevice = IOIteratorNext(iterator))) {
        NSString* name = [self getNameOfUSBDevice:usbDevice];
        NSString* vid = [self getManufacturerIDOfUSBDevice:usbDevice];
        // Post notification
        NSDictionary *userInfo = @{@"deviceName": name, @"vendorID": vid};
        [[NSNotificationCenter defaultCenter] postNotificationName:USBDeviceAddedNotification
                                                            object:self
                                                          userInfo:userInfo];
        IOObjectRelease(usbDevice);
    }
}

- (void) USBDeviceRemovedCallback:(void *)refcon iterator: (io_iterator_t) iterator {
    
    io_object_t usbDevice;
    while ((usbDevice = IOIteratorNext(iterator))) {
        
        NSString* name = [self getNameOfUSBDevice:usbDevice];
        NSString* vid = [self getManufacturerIDOfUSBDevice:usbDevice];
        NSDictionary *userInfo = @{@"deviceName": name, @"vendorID": vid};
        [[NSNotificationCenter defaultCenter] postNotificationName:USBDeviceRemovedNotification
                                                            object:self
                                                          userInfo:userInfo];
        IOObjectRelease(usbDevice);
    }
}

static void DeviceAdded(void *refCon, io_iterator_t iterator) {
    USBUtils *obj = (__bridge USBUtils *)refCon;
    [obj USBDeviceDetectedCallback:NULL iterator:iterator];
}

static void DeviceRemoved(void *refCon, io_iterator_t iterator) {
    USBUtils *obj = (__bridge USBUtils *)refCon;
    [obj USBDeviceRemovedCallback:NULL iterator:iterator];
}

- (void) registerForUSBDeviceNotifications {
    CFMutableDictionaryRef matchingDict = IOServiceMatching(kIOUSBDeviceClassName);
    if (!matchingDict) {
        NSLog(@"Unable to create matching dictionary for USB device detection");
        return;
    }
    
    IONotificationPortRef notificationPort = IONotificationPortCreate(kIOMasterPortDefault);
    CFRunLoopSourceRef runLoopSource = IONotificationPortGetRunLoopSource(notificationPort);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopDefaultMode);
    kern_return_t kernResult = IOServiceAddMatchingNotification(notificationPort, kIOPublishNotification, matchingDict, DeviceAdded, (__bridge void*)self, &detectionIterator);

    if (kernResult != kIOReturnSuccess) {
        NSLog(@"Unable to register for USB device detection notifications");
        return;
    }
    [self USBDeviceDetectedCallback:NULL iterator: detectionIterator];
    
    CFMutableDictionaryRef removalMatchingDict = IOServiceMatching(kIOUSBDeviceClassName);
    if (!removalMatchingDict) {
        NSLog(@"Unable to create matching dictionary for USB device detection");
        return;
    }
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopDefaultMode);
    kernResult = IOServiceAddMatchingNotification(notificationPort, kIOTerminatedNotification, removalMatchingDict, DeviceRemoved, (__bridge void*)self, &removalIterator);

    if (kernResult != kIOReturnSuccess) {
        NSLog(@"Unable to register for USB device detection notifications");
        return;
    }
    [self USBDeviceRemovedCallback:NULL iterator:removalIterator];
}

- (instancetype) init {
    self = [super init];
    
    if (self) {
        [self registerForUSBDeviceNotifications];
        CFRunLoopRun();
    }
    
    return self;
}

@end
