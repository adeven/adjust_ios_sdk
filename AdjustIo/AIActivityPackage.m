//
//  AIActivityPackage.m
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import "AIActivityPackage.h"

#pragma mark -
@implementation AIActivityPackage

- (NSString *)description {
    return [NSString stringWithFormat:@"%@%@ %@",
            self.kind, self.suffix, self.path];
}

- (NSString *)extendedString {
    NSMutableString *builder = [NSMutableString string];
    [builder appendFormat:@"Path:      %@\n", self.path];
    [builder appendFormat:@"UserAgent: %@\n", self.userAgent];
    [builder appendFormat:@"ClientSdk: %@\n", self.clientSdk];

    if (self.parameters != nil) {
        [builder appendFormat:@"Parameters:"];
        for (NSString *key in self.parameters) {
            NSString *value = [self.parameters objectForKey:key];
            [builder appendFormat:@"\n\t\t%-16s %@", [key UTF8String], value];
        }
    }

    return builder;
}

- (NSString *)successMessage {
    return [NSString stringWithFormat:@"Tracked %@%@", self.kind, self.suffix];
}

- (NSString *)failureMessage {
    return [NSString stringWithFormat:@"Failed to track %@%@", self.kind, self.suffix];
}

#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self == nil) return self;

    self.path = [decoder decodeObjectForKey:@"path"];
    self.userAgent = [decoder decodeObjectForKey:@"userAgent"];
    self.clientSdk = [decoder decodeObjectForKey:@"clientSdk"];
    self.parameters = [decoder decodeObjectForKey:@"parameters"];
    self.kind = [decoder decodeObjectForKey:@"kind"];
    self.suffix = [decoder decodeObjectForKey:@"suffix"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.path forKey:@"path"];
    [encoder encodeObject:self.userAgent forKey:@"userAgent"];
    [encoder encodeObject:self.clientSdk forKey:@"clientSdk"];
    [encoder encodeObject:self.parameters forKey:@"parameters"];
    [encoder encodeObject:self.kind forKey:@"kind"];
    [encoder encodeObject:self.suffix forKey:@"suffix"];
}

@end
