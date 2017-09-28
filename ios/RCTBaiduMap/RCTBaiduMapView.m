//
//  RCTBaiduMap.m
//  RCTBaiduMap
//
//  Created by lovebing on 4/17/2016.
//  Copyright © 2016 lovebing.org. All rights reserved.
//

#import "RCTBaiduMapView.h"



@interface BMKSportNode : NSObject

//经纬度
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
//方向（角度）
@property (nonatomic, assign) CGFloat angle;
//距离
@property (nonatomic, assign) CGFloat distance;
//速度
@property (nonatomic, assign) CGFloat speed;

@end

@implementation BMKSportNode

@synthesize coordinate = _coordinate;
@synthesize angle = _angle;
@synthesize distance = _distance;
@synthesize speed = _speed;

@end

// 自定义BMKAnnotationView，用于显示运动者
@interface SportAnnotationView : BMKAnnotationView

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation SportAnnotationView

@synthesize imageView = _imageView;

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        NSLog(@"initWithAnnotation %@", annotation.title);
        [self setBounds:CGRectMake(0.f, 0.f, 22.f, 22.f)];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 22.f, 22.f)];
        _imageView.image = [UIImage imageNamed:@"sportarrow.png"];
        [self addSubview:_imageView];
    }
    return self;
}

@end


@implementation RCTBaiduMapView {
    BMKMapView* _mapView;
    BMKCircle* circle;
    BMKPointAnnotation* _annotation;
    NSMutableArray* _annotations;

    //轨迹相关
    NSMutableArray *sportNodes;//轨迹点
    BMKPolyline *pathPloygon;
    NSInteger sportNodeNum;//轨迹点数
    NSInteger currentIndex;//当前结点
    BOOL isAnimate;
    BMKPointAnnotation *sportAnnotation;
    SportAnnotationView *sportAnnotationView;
}

-(void)setZoom:(float)zoom {
    self.zoomLevel = zoom;
}

-(void)setCircle:(NSDictionary *)option {
  NSLog(@"setCircle");
  if(circle !=nil) {
    [self removeOverlay:circle];
  }

  if(option != nil) {
    double lat = [RCTConvert double:option[@"latitude"]];
    double lng = [RCTConvert double:option[@"longitude"]];
    int radius = [RCTConvert int:option[@"radius"]];
    CLLocationCoordinate2D coor;
    coor.latitude = lat;
    coor.longitude = lng;
    circle = [BMKCircle circleWithCenterCoordinate:coor radius:radius];
    [self addOverlay:circle];
  }
}


//设置轨迹回放
-(void)setTrackPositions:(NSDictionary *)option {
  NSLog(@"setTrackPositions");
    NSArray *positions = [RCTConvert NSArray:option[@"tracks"]];
  if(positions != nil) {
    [self initSportNodes:positions];
    [self start];
  }
}

-(void)setCenterLatLng:(NSDictionary *)LatLngObj {
    double lat = [RCTConvert double:LatLngObj[@"lat"]];
    double lng = [RCTConvert double:LatLngObj[@"lng"]];
    CLLocationCoordinate2D point = CLLocationCoordinate2DMake(lat, lng);
    self.centerCoordinate = point;
}

-(void)setMarker:(NSDictionary *)option {
    NSLog(@"setMarker");
    if(option != nil) {
        if(_annotation == nil) {
            _annotation = [[BMKPointAnnotation alloc]init];
            [self addMarker:_annotation option:option];
        }
        else {
            [self updateMarker:_annotation option:option];
        }
    }
}

-(void)setMarkers:(NSArray *)markers {
    int markersCount = [markers count];
    if(_annotations == nil) {
        _annotations = [[NSMutableArray alloc] init];
    }
    if(markers != nil) {
        for (int i = 0; i < markersCount; i++)  {
            NSDictionary *option = [markers objectAtIndex:i];

            BMKPointAnnotation *annotation = nil;
            if(i < [_annotations count]) {
                annotation = [_annotations objectAtIndex:i];
            }
            if(annotation == nil) {
                annotation = [[BMKPointAnnotation alloc]init];
                [self addMarker:annotation option:option];
                [_annotations addObject:annotation];
            }
            else {
                [self updateMarker:annotation option:option];
            }
        }
        
        int _annotationsCount = [_annotations count];
        
        NSString *smarkersCount = [NSString stringWithFormat:@"%d", markersCount];
        NSString *sannotationsCount = [NSString stringWithFormat:@"%d", _annotationsCount];
        
        if(markersCount < _annotationsCount) {
            int start = _annotationsCount - 1;
            for(int i = start; i >= markersCount; i--) {
                BMKPointAnnotation *annotation = [_annotations objectAtIndex:i];
                [self removeAnnotation:annotation];
                [_annotations removeObject:annotation];
            }
        }
        
        
    }
}

-(CLLocationCoordinate2D)getCoorFromMarkerOption:(NSDictionary *)option {
    double lat = [RCTConvert double:option[@"latitude"]];
    double lng = [RCTConvert double:option[@"longitude"]];
 
    CLLocationCoordinate2D coor;
    coor.latitude = lat;
    coor.longitude = lng;
    return coor;
}

-(void)addMarker:(BMKPointAnnotation *)annotation option:(NSDictionary *)option {
    [self updateMarker:annotation option:option];
    [self addAnnotation:annotation];
}

-(void)updateMarker:(BMKPointAnnotation *)annotation option:(NSDictionary *)option {
    CLLocationCoordinate2D coor = [self getCoorFromMarkerOption:option];
    NSString *title = [RCTConvert NSString:option[@"title"]];
    if(title.length == 0) {
        title = nil;
    }
    annotation.coordinate = coor;
    annotation.title = title;
}

-(BMKSportNode *)getSportNode:(NSDictionary *)startPosition endPosition:(NSDictionary *)endPosition {



  BMKSportNode *sportNode = [[BMKSportNode alloc] init];
  double angle;

  double fromLat = [RCTConvert double:startPosition[@"latitude"]];
  double fromLng = [RCTConvert double:startPosition[@"longitude"]];

  double toLat = [RCTConvert double:endPosition[@"latitude"]];
  double toLng = [RCTConvert double:endPosition[@"longitude"]];

  double slope = ((fromLat - toLat) / (toLng - fromLng));

  if(toLng == fromLng) {
    if(toLat > fromLat) {
      angle = 0;
    } else {
      angle = 180;
    }
  } else {
    double deltAngle = 0;
    if ((toLat - fromLat) * slope < 0) {
      deltAngle = 180;
    }
    double radio = atan(slope);
    angle = 180 * (radio / M_PI) + deltAngle - 90;
  }
  

  sportNode.angle = M_PI/180 * (angle - 90);
  sportNode.distance = 40;
  sportNode.speed = 10;

  return sportNode;
}

-(void)initSportNodes:(NSArray *)positions {
  sportNodes = [[NSMutableArray alloc] init];
  NSInteger positionsCount = [positions count];
  for (int i = 0; i < positionsCount; i++)  {
    NSDictionary *startOption = [positions objectAtIndex:i];
    
    double lat = [RCTConvert double:startOption[@"latitude"]];
    double lng = [RCTConvert double:startOption[@"longitude"]];
    CLLocationCoordinate2D coor;
    coor.latitude = lat;
    coor.longitude = lng;

    if(i != positionsCount - 1) {
      NSDictionary *endOption = [positions objectAtIndex:(i + 1)];

      BMKSportNode *sportNode = [self getSportNode:startOption endPosition:endOption];
      sportNode.coordinate = coor;

      [sportNodes addObject:sportNode];
    } else {

      BMKSportNode *sportNode = [[BMKSportNode alloc] init];
      sportNode.coordinate = coor;
      sportNode.angle = 60;
      sportNode.distance = 40;
      sportNode.speed = 10;
      [sportNodes addObject:sportNode];
    }
  }

  sportNodeNum = positionsCount;
}


- (void)start {
    CLLocationCoordinate2D paths[sportNodeNum];
    for (NSInteger i = 0; i < sportNodeNum; i++) {
        BMKSportNode *node = sportNodes[i];
        paths[i] = node.coordinate;
    }

    pathPloygon = [BMKPolyline polylineWithCoordinates:paths count:sportNodeNum];
    [self addOverlay:pathPloygon];

    sportAnnotation = [[BMKPointAnnotation alloc]init];

    sportAnnotation.coordinate = paths[0];
    sportAnnotation.title = @"sport";
    self.centerCoordinate = paths[0];
    currentIndex = 0;
    isAnimate = YES;
    [self addAnnotation:sportAnnotation];
}

//runing
- (void)runArrowMove {
    if(isAnimate) {
      BMKSportNode *node = [sportNodes objectAtIndex:currentIndex % sportNodeNum];
      sportAnnotationView.imageView.transform = CGAffineTransformMakeRotation(node.angle);
      [UIView animateWithDuration:node.distance/node.speed animations:^{
          currentIndex++;
          BMKSportNode *node = [sportNodes objectAtIndex:currentIndex % sportNodeNum];

          sportAnnotation.coordinate = node.coordinate;
          if(currentIndex + 1 == sportNodeNum) {
              isAnimate = NO;
          }
      } completion:^(BOOL finished) {
          if (isAnimate) {
            [self runArrowMove];
            NSInteger prefixIndex = currentIndex - 1;
            BMKSportNode *centerNode = [sportNodes objectAtIndex:prefixIndex];
            self.centerCoordinate = centerNode.coordinate;
          }else {
            BMKSportNode *centerNode = [sportNodes objectAtIndex:(sportNodeNum - 1)];
            self.centerCoordinate = centerNode.coordinate;
          }

      }];
    }
}

-(BMKAnnotationView *)generateSportAnnotationView: (id<BMKAnnotation>)annotation {
    if (sportAnnotationView == nil) {
      sportAnnotationView = [[SportAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"sportsAnnotation"];
      sportAnnotationView.draggable = NO;
      BMKSportNode *node = [sportNodes firstObject];
      sportAnnotationView.imageView.transform = CGAffineTransformMakeRotation(node.angle);
    }
    return sportAnnotationView;
}

-(void)willRemoveSubview:(UIView *)subview{
    isAnimate = NO;
    NSLog(@"willRemoveSubview");
}

- (void)dealloc {
  isAnimate = NO;
}

@end

