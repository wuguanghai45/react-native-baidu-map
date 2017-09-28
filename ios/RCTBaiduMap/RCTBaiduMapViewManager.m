//
//  RCTBaiduMapViewManager.m
//  RCTBaiduMap
//
//  Created by lovebing on Aug 6, 2016.
//  Copyright © 2016 lovebing.org. All rights reserved.
//

#import "RCTBaiduMapViewManager.h"


@implementation RCTBaiduMapViewManager;


RCT_EXPORT_MODULE(RCTBaiduMapView)

RCT_EXPORT_VIEW_PROPERTY(mapType, int)
RCT_EXPORT_VIEW_PROPERTY(zoom, float)
RCT_EXPORT_VIEW_PROPERTY(trafficEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(baiduHeatMapEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(marker, NSDictionary*)
RCT_EXPORT_VIEW_PROPERTY(markers, NSArray*)
RCT_EXPORT_VIEW_PROPERTY(circle, NSDictionary*)
RCT_EXPORT_VIEW_PROPERTY(trackPositions, NSDictionary*)

RCT_EXPORT_VIEW_PROPERTY(onChange, RCTBubblingEventBlock)

RCT_CUSTOM_VIEW_PROPERTY(center, CLLocationCoordinate2D, RCTBaiduMapView) {
    [view setCenterCoordinate:json ? [RCTConvert CLLocationCoordinate2D:json] : defaultView.centerCoordinate];
}


+(void)initSDK:(NSString*)key {
    BMKMapManager* _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:key  generalDelegate:nil];

    if (!ret) {
        NSLog(@"manager start failed!");
    }
}

- (UIView *)view {
  RCTBaiduMapView* rctMapView = [[RCTBaiduMapView alloc]init];
  rctMapView.delegate = self;
  return rctMapView;
}

//-(RCTBaiduMapView *)getBaiduMapView{
    //if(rctMapView == nil) {
      //rctMapView = [[RCTBaiduMapView alloc]init];
    //}
    //return rctMapView;
//}

-(void)mapview:(BMKMapView *)mapView
 onDoubleClick:(CLLocationCoordinate2D)coordinate {
    NSLog(@"onDoubleClick");
    NSDictionary* event = @{
                            @"type": @"onMapDoubleClick",
                            @"params": @{
                                    @"latitude": @(coordinate.latitude),
                                    @"longitude": @(coordinate.longitude)
                                    }
                            };
    [self sendEvent:mapView params:event];
}

-(void)mapView:(BMKMapView *)mapView
onClickedMapBlank:(CLLocationCoordinate2D)coordinate {
    NSLog(@"onClickedMapBlank");
    NSDictionary* event = @{
                            @"type": @"onMapClick",
                            @"params": @{
                                    @"latitude": @(coordinate.latitude),
                                    @"longitude": @(coordinate.longitude)
                                    }
                            };
    [self sendEvent:mapView params:event];
}

-(void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    NSDictionary* event = @{
                            @"type": @"onMapLoaded",
                            @"params": @{}
                            };
    [self sendEvent:mapView params:event];
}

-(void)mapView:(BMKMapView *)mapView
didSelectAnnotationView:(BMKAnnotationView *)view {
    NSDictionary* event = @{
                            @"type": @"onMarkerClick",
                            @"params": @{
                                    @"title": [[view annotation] title],
                                    @"position": @{
                                            @"latitude": @([[view annotation] coordinate].latitude),
                                            @"longitude": @([[view annotation] coordinate].longitude)
                                            }
                                    }
                            };
    [self sendEvent:mapView params:event];
}

- (void) mapView:(BMKMapView *)mapView
 onClickedMapPoi:(BMKMapPoi *)mapPoi {
    NSLog(@"onClickedMapPoi");
    NSDictionary* event = @{
                            @"type": @"onMapPoiClick",
                            @"params": @{
                                    @"name": mapPoi.text,
                                    @"uid": mapPoi.uid,
                                    @"latitude": @(mapPoi.pt.latitude),
                                    @"longitude": @(mapPoi.pt.longitude)
                                    }
                            };
    [self sendEvent:mapView params:event];
}

- (BMKAnnotationView *)mapView:(RCTBaiduMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    NSLog(@"viewForAnnotation %@", annotation.title);

    if(annotation.title == @"sport") {
       NSLog(@"title %@", annotation.title);

       return [mapView generateSportAnnotationView:annotation];
    }

    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        newAnnotationView.animatesDrop = YES;
        return newAnnotationView;
    }
    return nil;
}

- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay {
    NSLog(@"viewForOverlay");
    if ([overlay isKindOfClass:[BMKCircle class]])
    {
        BMKCircleView* circleView = [[BMKCircleView alloc] initWithOverlay:overlay];
        circleView.fillColor = [[UIColor alloc] initWithRed:216/255.0 green:173/255.0 blue:173/255.0 alpha:0.3];
        circleView.strokeColor = [[UIColor alloc] initWithRed:216/255.0 green:173/255.0 blue:173/255.0 alpha:0.5];
        circleView.lineWidth = 1.0;

      return circleView;
    }

    if ([overlay isKindOfClass:[BMKPolyline class]])
    {
        NSLog(@"polygonView");

        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.strokeColor = [[UIColor alloc] initWithRed:0.0 green:0.5 blue:0.0 alpha:0.6];
        polylineView.lineWidth = 1.5;
        return polylineView;
    }

  return nil;
}

- (void)mapView:(RCTBaiduMapView *)mapView didAddAnnotationViews:(NSArray *)views {
   [mapView runArrowMove];
}


-(void)mapStatusDidChanged: (BMKMapView *)mapView	 {
    NSLog(@"mapStatusDidChanged");
    CLLocationCoordinate2D targetGeoPt = [mapView getMapStatus].targetGeoPt;
    NSDictionary* event = @{
                            @"type": @"onMapStatusChange",
                            @"params": @{
                                    @"target": @{
                                            @"latitude": @(targetGeoPt.latitude),
                                            @"longitude": @(targetGeoPt.longitude)
                                            },
                                    @"zoom": @"",
                                    @"overlook": @""
                                    }
                            };
    [self sendEvent:mapView params:event];
}

-(void)sendEvent:(RCTBaiduMapView *) mapView params:(NSDictionary *) params {
    if (!mapView.onChange) {
        return;
    }
    mapView.onChange(params);
}


@end
