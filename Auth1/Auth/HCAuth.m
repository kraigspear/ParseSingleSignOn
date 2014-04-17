//
// Created by Kraig Spear on 12/28/13.
// Copyright (c) 2013 ___FULLUSERNAME___. All rights reserved.
//

#import "HCAuth.h"

#import "Parse.h"


@implementation HCAuth
{
@private
}


NSString *const HCAuthDomain = @"HarperAuthorization";

static NSString *const AppId = @"";
static NSString *const RestKey = @"";

#pragma mark Sign Up


- (void)signUpWithUserName:(NSString *)userName andPassword:(NSString *)password
                   success:(HCAuthSuccessBlock)success
                   failure:(HCAuthErrorBlock)failure
{

    NSData *jsonData= [self getUserNamePasswordAsJSONDataFromUserName:userName password:password];

    NSURLRequest *request = [self createRequestForPostAt:@"https://api.parse.com/1/users" jsonData:jsonData];

    NSURLSession *session = [NSURLSession sharedSession];

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                failure(error);
            });

            return;
        }

        NSError *jsonError = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
        if (jsonError)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                failure(jsonError);
            });

            return;
        }

        NSString *errorStr = responseDict[ErrorKey];

        int responseCode = [responseDict[@"code"] intValue];

        NSLog(@"ResposeCode = %d Error = %@", responseCode, responseDict[ErrorKey]);

        if (errorStr)
        {
            NSDictionary *errorDict = @{NSLocalizedDescriptionKey : responseDict[ErrorKey]};
            NSError *responseError = [NSError errorWithDomain:HCAuthDomain code:responseCode userInfo:errorDict];

            dispatch_async(dispatch_get_main_queue(), ^
            {
                failure(responseError);
            });
        }
        else
        {
            NSString *objectId = responseDict[@"objectId"];
            NSAssert(objectId != nil, @"objectId should be there if response == success");
            HCUser *user = [[HCUser alloc] initWithName:userName userId:objectId];

            [self logOnToAppFor:user success:^(BOOL loggedOnAppSuccess)
            {
                if(loggedOnAppSuccess)
                {
                    dispatch_async(dispatch_get_main_queue(), ^
                    {
                        success(user);
                    });
                }
            }
            failure:^(NSError *loggedOnAppError)
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    failure(loggedOnAppError);
                });
            }];
        }

    }];

    [dataTask resume];

}

- (NSURLRequest*) createRequestForPostAt:(NSString*) urlStr jsonData:(NSData*) jsonData
{
    NSURL *url = [NSURL URLWithString:urlStr];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];

    request.HTTPBody = jsonData;
    request.HTTPMethod = @"POST";

    [request addValue:AppId forHTTPHeaderField:@"X-Parse-Application-Id"];
    [request addValue:RestKey forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    return request;

}

- (NSData *)getUserNamePasswordAsJSONDataFromUserName:(NSString *)userName password:(NSString *)password
{
    NSDictionary *dict = @{@"username" : userName, @"password" : password};

    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&jsonError];
    return jsonData;
}

#pragma mark Log On

- (void)logOnWithUserName:(NSString *)userName andPassword:(NSString *)password success:(HCAuthSuccessBlock)success
                  failure:(HCAuthErrorBlock)failure
{


    NSString *urlStr = [NSString stringWithFormat:@"https://api.parse.com/1/login?username=%@&password=%@", userName, password];

    NSURL *url = [NSURL URLWithString:urlStr];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];

    [request addValue:@"Km2CWZqsF47O6uvDxe2y3zBgRZkFMIY158CTAHet" forHTTPHeaderField:@"X-Parse-Application-Id"];
    [request addValue:@"WXLDJNpp12oVwHOFaNcGz538x8TwIPeB7bpUiHBz" forHTTPHeaderField:@"X-Parse-REST-API-Key"];

    request.HTTPMethod = @"GET";

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                failure(error);
            });
            return;
        }

        NSError *jsonError;
        NSDictionary *userDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];

        if (jsonError != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                failure(jsonError);
            });
            return;
        }

        NSString *userNameFromParse = userDict[@"username"];
        NSString *objectId = userDict[@"objectId"];
        NSString *errorDesc = userDict[ErrorKey];

        if (errorDesc)
        {
            NSDictionary *errorDict = @{NSLocalizedDescriptionKey : errorDesc};

            int errorCode = [userDict[@"code"] intValue];

            NSError *responseError = [NSError errorWithDomain:HCAuthDomain code:errorCode userInfo:errorDict];

            dispatch_async(dispatch_get_main_queue(), ^
            {
                failure(responseError);
            });

            return;
        }

        //Auth logon a success, try the client App
        HCUser *user = [[HCUser alloc] initWithName:userNameFromParse userId:objectId];

        [self logOnToAppFor:user
                    success:^(BOOL logOnSuccess)
                    {
                        if (logOnSuccess)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^
                            {
                                success(user);
                            });
                        }
                        else
                        {
                            dispatch_async(dispatch_get_main_queue(), ^
                            {
                                success(nil);
                            });
                        }
                    }
                    failure:^(NSError *logInError)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^
                        {
                            failure(logInError);
                        });
                    }];
    }];

    [dataTask resume];


}

//Here we log into the actual App (not the Auth account)
- (void)logOnToAppFor:(HCUser *)hcUser success:(HCBoolBlock)success failure:(HCAuthErrorBlock)failure
{
    //We use the userId from the Auth server as our password.
    [PFUser logInWithUsernameInBackground:hcUser.userName password:hcUser.userId
                                    block:^(PFUser *parseUser, NSError *error)
                                    {
                                        //User doesn't exist in client account, try and add.
                                        if (!parseUser || error)
                                        {
                                            PFUser *newUser = [PFUser user];
                                            newUser.username = hcUser.userName;
                                            newUser.password = hcUser.userId;
                                            [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *signUpError)
                                            {
                                                if (signUpError)
                                                {
                                                    failure(signUpError);
                                                }
                                                else
                                                {
                                                    if (succeeded)
                                                    {
                                                        success(YES);
                                                    }
                                                    else
                                                    {
                                                        success(NO);
                                                    }
                                                }
                                            }];
                                        }
                                        else
                                        {
                                            //User does exist.
                                            success(YES);
                                        }
                                    }];
}

@end