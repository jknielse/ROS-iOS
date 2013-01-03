//
//  ServerCall.m
//  RobotPathDemo
//
//  Created by Jake on 13-01-02.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ServerCall.h"
#import "ServerConfig.h"
#import "ASIHTTPRequest.h"
#import "ServerCallCompliant.h"

static NSMutableDictionary *retainDict;

@implementation ServerCall

@synthesize completed;
@synthesize request;

#pragma mark -
#pragma mark ServerCall Specific Methods
#pragma mark -

+(void)initialize
{
    retainDict = [[NSMutableDictionary alloc] init];
}

-(id)init
{
    self = [super init];
    if (self) {
        attemptCounter = 0;
        completed = NO;
        uuid = [[NSProcessInfo processInfo] globallyUniqueString];
        //Makes sure that the server call will not be dealloced before it should be.
        [retainDict setValue:self forKey:uuid];
    }
    return self;
}

-(void)sendGETRequestForLocation:(NSString *)location WithRequestKeysAndValues:(NSDictionary *)dict
{
    request = [self newRequestWithURL:[self urlWithLocation:location AndKeysAndValues:dict]];
    [request setRequestMethod:@"GET"];
    [request startAsynchronous];
}

-(void)sendDELETERequestForLocation:(NSString *)location
{
    request = [self newRequestWithURL:[self urlWithLocation:location]];
    [request setRequestMethod:@"DELETE"];
    [request startAsynchronous];
}

-(void)sendPOSTRequestForLocation:(NSString *)location WithBodyData:(NSData *)data
{
    request = [self newRequestWithURL:[self urlWithLocation:location]];
    [request setRequestMethod:@"POST"];
    [request setPostBody:[NSMutableData dataWithData:data]];
    [request startAsynchronous];
}

-(void)success
{
    NSAssert(NO, @"You must override success in the subclass");
}

-(void)failure
{
    NSAssert(NO, @"You must override failure in the subclass");
}

-(NSURL *)urlWithLocation:(NSString *)location
{
    return [NSURL URLWithString:location relativeToURL:[NSURL URLWithString:SERVER_BASE_URL]];
}

-(ASIHTTPRequest *)newRequestWithURL:(NSURL *)url
{
    ASIHTTPRequest *newRequest = [ASIHTTPRequest requestWithURL:url];
    [newRequest setDelegate:self];
    [newRequest setNumberOfTimesToRetryOnTimeout:MAX_RETRIES];
    return newRequest;
}

-(NSURL *)urlWithLocation:(NSString *)location AndKeysAndValues:(NSDictionary *)dict
{
    NSString *keysAndValuesString = [[NSString alloc] init];
    BOOL firstLoop = YES;
    for (id eachKey in [dict keyEnumerator]) {
        id object = [dict objectForKey:eachKey];
        
        //Although the object may be server compliant in and of itself, if it's 
        //An NSArray, NSDictionary, NSString, or some other common base type,
        //We may be able to use it anyway.
        NSString *jsonObject = [self mapObjectToJSON:object];
        
        if (firstLoop) {
            firstLoop = NO;
            keysAndValuesString = [keysAndValuesString stringByAppendingFormat:@"%@=%@", eachKey, [self urlEncodeString:jsonObject]];
        }
        else {
            keysAndValuesString = [keysAndValuesString stringByAppendingFormat:@"&%@=%@", eachKey, [self urlEncodeString:jsonObject]];
        }
    }
    return [self urlWithLocation:[location stringByAppendingFormat:@"?%@",keysAndValuesString]];
}

-(NSString *) urlEncodeString:(NSString *)inputString
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
            NULL,
            (__bridge CFStringRef) inputString,
            NULL,
            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
            kCFStringEncodingUTF8));
}

-(NSString *)mapObjectToJSON:(id) object
{
    if ([object conformsToProtocol:@protocol(ServerCallCompliant)]) {
        return [self mapObjectToJSON:[object makeJSONCompatible]];
    }
    else if ([object isKindOfClass:[NSString class]]) {
        return object;
    }
    else {
        
        NSError *err = nil;
        
        NSData *JSONData = nil;
        @try {
            JSONData = [NSJSONSerialization 
             dataWithJSONObject:object 
             options:0 
             error:&err];
        }
        @catch (NSException *exception) {
            [CustomLog logMessage:[NSString stringWithFormat:@"Exception: %@", exception] WithLogLevel:LOG_LEVEL_ERROR];
        }
        
        NSString *returnString = [[NSString alloc] initWithData:JSONData encoding:NSStringEncodingConversionAllowLossy];
        
        if (err) {
            [CustomLog logMessage:[NSString stringWithFormat:@"JSON construction error: %@",err] WithLogLevel:LOG_LEVEL_ERROR];
        }
        
        return returnString;
    }
}

#pragma mark -
#pragma mark ASIHTTPRequestDelegate Methods
#pragma mark -

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    [CustomLog logMessage:[NSString stringWithFormat:@"Request recieved response headers: %@", responseHeaders] WithLogLevel:LOG_LEVEL_INFO];
}

- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL
{
    [CustomLog logMessage:[NSString stringWithFormat:@"Request redirecting to: %@", newURL] WithLogLevel:LOG_LEVEL_INFO];
}

- (void)requestFinished:(ASIHTTPRequest *)theRequest
{
    completed = YES;
    
    if ([theRequest responseStatusCode] >= 300) {
        [CustomLog logMessage:[NSString stringWithFormat:@"Request completed with a response code that's above 300, implying there there may have been some kind of error",nil] WithLogLevel:LOG_LEVEL_WARNING];
        [CustomLog logMessage:[NSString stringWithFormat:@"Response data as follows:%@", [theRequest responseString],nil ] WithLogLevel:LOG_LEVEL_WARNING];
        [self failure];
    }
    else {
        [self success];
    }
    
    [retainDict removeObjectForKey:uuid];
}

- (void)requestFailed:(ASIHTTPRequest *)theRequest
{
    completed = YES;
    [self failure];
    [retainDict removeObjectForKey:uuid];
}

@end
