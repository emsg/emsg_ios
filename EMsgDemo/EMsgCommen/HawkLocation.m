//
//  HawkLocation.m
//  qiuyouquan
//
//  Created by QYQ-Hawk on 15/12/21.
//  Copyright © 2015年 QYQ-Hawk. All rights reserved.
//

#import "HawkLocation.h"

#import <CoreLocation/CoreLocation.h>

@implementation HawkLocationModel

@end

@interface HawkLocation ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *locatedLocation;

@property (nonatomic, assign) HLLocalLocationStatus status;
@property (nonatomic, strong) LocationResultBlock resultBlock;
@property (nonatomic, strong) NSError *error;

@end

@implementation HawkLocation

- (instancetype)init
{
    if (self = [super init])
    {
        [self initValues];
        [self initManager];
        _status = HLLocalLocationStatusNone;
        _needLocateCity = NO;
        [self addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"status" context:nil];
}

- (void)initManager
{
    if ([CLLocationManager locationServicesEnabled] &&
        ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized
         || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)) {
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.delegate = self;
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            _locationManager.distanceFilter = 5.0;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
            {
                if([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                    //always allow location
//                  [_locationManager requestAlwaysAuthorization];
                [_locationManager requestWhenInUseAuthorization];
                }
            }
    }
    else{
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 5.0;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            if([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                //always allow location
//                [_locationManager requestAlwaysAuthorization];
                [_locationManager requestWhenInUseAuthorization];
            }
        }

    }
}

- (void)initValues
{
    _error = nil;
    _locatedLocation = nil;
    _address = nil;
}

- (void)startLocatingWithResult:(LocationResultBlock)block
{
    [self initValues];
    self.resultBlock = block;
    if (![CLLocationManager locationServicesEnabled])
    {
        self.status = HLLocalLocationStatusDisabled;
    }
    else
    {
        self.status = HLLocalLocationStatusOngoing;
        [self.locationManager startUpdatingLocation];
    }
}

- (void)stopLocating
{
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - Output

- (void)callBackResult
{
    if (self.resultBlock)
    {
        self.resultBlock(self.status, self.error);
    }
}

- (NSString *)latitude
{
    return self.locatedLocation? [NSString stringWithFormat:@"%f", self.locatedLocation.coordinate.latitude] : nil;
}

- (NSString *)longitude
{
    return self.locatedLocation? [NSString stringWithFormat:@"%f", self.locatedLocation.coordinate.longitude] : nil;
}

#pragma mark - KVO status

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        [self callBackResult];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.locatedLocation = [locations lastObject];
    
    typeof(&*self) __weak weakSelf = self;
    [self getDetailAddressWithCompletion:^(BOOL success, HawkLocationModel *HL) {
        typeof(&*weakSelf) __weak strongSelf = weakSelf;
        
        strongSelf.address = success? HL.address : nil;
        if (!success) {
            strongSelf.status = HLLocalLocationStatusFailure;
            return;
        }
        
        if (weakSelf.needLocateCity)
        {
            strongSelf.kHL = HL;
            strongSelf.status = HLLocalLocationStatusSuccess;
        }
        else
        {
            strongSelf.status = HLLocalLocationStatusSuccess;
        }
        
    }];
    
    [self stopLocating];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    self.error = error;
    NSString *errorString;
    switch([error code]) {
        case kCLErrorDenied:
        {
            //Access denied by user
            self.status = HLLocalLocationStatusDisabled;
        }
            break;
        case kCLErrorLocationUnknown:
        {
            //Probably temporary...
            errorString = @"Location data unavailable";
            self.status = HLLocalLocationStatusFailure;
        }
            break;
        default:
        {
            errorString = @"An unknown error has occurred";
            self.status = HLLocalLocationStatusFailure;
        }
            break;
    }
    
    [self stopLocating];
}

#pragma mark - Detail Info

- (void)getDetailAddressWithCompletion:(void(^)(BOOL success, HawkLocationModel * HL))block
{
    NSParameterAssert(block);
    if (!self.geocoder)
    {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    // Locate the city
    
    [self.geocoder reverseGeocodeLocation:self.locatedLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        BOOL success = NO;
        HawkLocationModel * hl = [[HawkLocationModel alloc] init];
        if (error)
        {
            NSLog(@"Failed to get geo info, error{%@}", error);
        }
        else
        {
            CLPlacemark *mark = [placemarks firstObject];
            hl.address = mark.name;
            hl.country = mark.country;
            hl.province = mark.administrativeArea;
            hl.city = mark.locality;
            hl.area = mark.subLocality;
            success = YES;
        }
        block(success, hl);
    }];
}

@end
