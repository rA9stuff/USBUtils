//
//  main.m
//  USBUtils
//
//  Created by rA9 on 1.09.2024.
//

#import <Foundation/Foundation.h>
#import "CalleeObject.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        printf("==================\n\nIOKit USB Interface tester\nrA9stuff 2024\n\n==================\n\n");
        printf("Listening for USB activity now...\n");
        CalleeObject *callee = [[CalleeObject alloc] init];
    }
    return 0;
}
