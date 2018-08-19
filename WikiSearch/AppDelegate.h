//
//  AppDelegate.h
//  WikiSearch
//
//  Created by Sandhya on 18/08/18.
//  Copyright © 2018 Sandhya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

