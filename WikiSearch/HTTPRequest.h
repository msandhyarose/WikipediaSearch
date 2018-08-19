//
//  HTTPRequest.h
//  WikiSearch
//
//  Created by Sandhya on 18/08/18.
//  Copyright © 2017 Sandhya. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HttpDelegte <NSObject>

-(void)responseData:(id )responseData withReqType:(NSString *)type;

@end

@interface HTTPRequest : NSObject
@property (strong,nonatomic) id <HttpDelegte> delegate;

-(void)initRequestWithRequestData:(NSString *)urlString withEntityType:(NSString *)entityType;
@end
