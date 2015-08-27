//
//  ViewController.m
//  BeaconSample
//
//  Created by LoopSessions on 2015/08/26.
//  Copyright (c) 2015年 LoopSessions. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
	CLLocationManager *_locationManager;
	CLBeaconRegion *_region;
	NSMutableArray *_arBeacons;
	
	UITableView *_tableView;
	BOOL _isStart;
}
@end

@implementation ViewController

- (id)init
{
    self = [super init];
    if (self) {
		_arBeacons = [[NSMutableArray alloc] init];
		_isStart = NO;
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor lightGrayColor];
	
	NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:kUUIDString_ESTIMOTE];
	_region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
	
	_locationManager = [[CLLocationManager alloc] init];
	_locationManager.delegate = self;
	// !!!: iOS8
	if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
		[_locationManager requestAlwaysAuthorization];
	}
	
	
	CGFloat fWidth = [[UIScreen mainScreen] bounds].size.width;
	CGFloat fHeight = [[UIScreen mainScreen] bounds].size.height;
	CGFloat fStatusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
	CGFloat fNavigationbarHeight = self.navigationController.navigationBar.frame.size.height;
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, fWidth, fHeight - fStatusBarHeight - fNavigationbarHeight) style:UITableViewStylePlain];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	_tableView.backgroundColor = [UIColor clearColor];
	_tableView.backgroundView = nil;
	[self.view addSubview:_tableView];
	
	UIBarButtonItem *buttonControl = [[UIBarButtonItem alloc]
								   initWithTitle:@"Start"
								   style:UIBarButtonItemStylePlain
								   target:self
								   action:@selector(buttonControlAct:)];
	self.navigationItem.rightBarButtonItem = buttonControl;
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
	[_tableView release];
	[_arBeacons release];
	_locationManager.delegate = nil;
	[_locationManager release];
	[_region release];
	[super dealloc];
}

////////////////////////////////////////////////////////////////
#pragma mark -

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

////////////////////////////////////////////////////////////////
#pragma mark -

// !!!: iOS8
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	if (status == kCLAuthorizationStatusNotDetermined) {
	} else if(status == kCLAuthorizationStatusAuthorizedAlways) {
	} else if(status == kCLAuthorizationStatusAuthorizedWhenInUse) {
	}
	NSLog(@"didChangeAuthorizationStatus %d", status);
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
	[_arBeacons removeAllObjects];
	[_arBeacons addObjectsFromArray:beacons];
	
	[_tableView reloadData];
}

////////////////////////////////////////////////////////////////
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [BEACON_MAJOR count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 80.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	
	if ([_arBeacons count] > indexPath.row) {
		CLBeacon *beacon = _arBeacons[indexPath.row];
		NSString *prox;
		switch (beacon.proximity) {
			case CLProximityImmediate:
				prox = @"Immediate（近接）";
				break;
			case CLProximityNear:
				prox = @"Near（1m以内）";
				break;
			case CLProximityFar:
				prox = @"Far（1m以上）";
				break;
			case CLProximityUnknown:
			default:
				prox = @"Unknown（不明）";
				break;
		}
		
		cell.textLabel.numberOfLines = 1;
		cell.textLabel.text = [beacon.proximityUUID UUIDString];
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		
		cell.detailTextLabel.numberOfLines = 0;
		cell.detailTextLabel.text = [NSString stringWithFormat:@"Major:%@, Minor:%@, Prox:%@ \nAcc 推定誤差:%.2fm  RSSI 受信信号強度:%ld", beacon.major, beacon.minor, prox, beacon.accuracy, (long)beacon.rssi];
		
		// color
		cell.textLabel.textColor = [UIColor grayColor];
		cell.detailTextLabel.textColor = [UIColor grayColor];
		for (int i = 0; i < [BEACON_MAJOR count]; i++) {
			if ([beacon.major isEqualToNumber:BEACON_MAJOR[i]] && [beacon.minor isEqualToNumber:BEACON_MINOR[i]]) {
				cell.textLabel.textColor = [UIColor blackColor];
				cell.detailTextLabel.textColor = [UIColor blackColor];
				break;
			}
		}
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

////////////////////////////////////////////////////////////////
#pragma mark -

- (void)buttonControlAct:(UIBarButtonItem *)sender
{
	if (_isStart) {
		[_locationManager stopRangingBeaconsInRegion:_region];
		[self.navigationItem.rightBarButtonItem setTitle:@"Start"];
	} else {
		[_locationManager startRangingBeaconsInRegion:_region];
		[self.navigationItem.rightBarButtonItem setTitle:@"Stop"];
	}
	_isStart ^= 0x01;
}

@end
