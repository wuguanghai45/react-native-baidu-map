//
//  RCTBaiduMap.h
//  RCTBaiduMap
//
//  Created by lovebing on 4/17/2016.
//  Copyright © 2016 lovebing.org. All rights reserved.
//

#ifndef RCTBaiduMapView_h
#define RCTBaiduMapView_h


#import <React/RCTViewManager.h>
#import <React/RCTConvert+CoreLocation.h>

#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Map/BMKPinAnnotationView.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <BaiduMapAPI_Map/BMKCircle.h>
#import <BaiduMapAPI_Map/BMKCircleView.h>
#import <BaiduMapAPI_Map/BMKPolyline.h>
#import <BaiduMapAPI_Map/BMKPolylineView.h>


#import <UIKit/UIKit.h>


@interface RCTBaiduMapView : BMKMapView <BMKMapViewDelegate>

@property (nonatomic, copy) RCTBubblingEventBlock onChange;
//@property (nonatomic, strong) SportAnnotationView* sportAnnotation;

-(void)runArrowMove;
-(void)setZoom:(float)zoom;
-(void)setCenterLatLng:(NSDictionary *)LatLngObj;
-(void)setMarker:(NSDictionary *)Options;
-(void)setCircle:(NSDictionary *)Options;
-(void)setTrackPositions:(NSDictionary *)Options;
-(BMKAnnotationView *)generateSportAnnotationView:(id<BMKAnnotation>)annotation;

@end

#endif
