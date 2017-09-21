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

//#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
//#import <BaiduMapAPI_Map/BMKPinAnnotationView.h>
//#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
//#import <BaiduMapAPI_Map/BMKMapView.h>
//#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
//#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
//#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>//引入云检索功能所有的头文件
//#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
//#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件
//#import <BaiduMapAPI_Radar/BMKRadarComponent.h>//引入周边雷达功能所有的头文件

#import <UIKit/UIKit.h>

@interface RCTBaiduMapView : BMKMapView <BMKMapViewDelegate>

@property (nonatomic, copy) RCTBubblingEventBlock onChange;

-(void)setZoom:(float)zoom;
-(void)setCenterLatLng:(NSDictionary *)LatLngObj;
-(void)setMarker:(NSDictionary *)Options;
-(void)setCircle:(NSDictionary *)Options;

@end

#endif
