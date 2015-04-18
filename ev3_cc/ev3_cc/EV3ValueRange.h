//
//  ValueRange.h
//  ev3_cc
//
//  Created by Bartlomiej Hyzy on 18/04/2015.
//  Copyright (c) 2015 bhyzy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct _EV3ValueRange {
    double minValue;
    double maxValue;
} EV3ValueRange;

NS_INLINE EV3ValueRange EV3MakeValueRange(double minValue, double maxValue) {
    EV3ValueRange r;
    r.minValue = minValue;
    r.maxValue = maxValue;
    return r;
}