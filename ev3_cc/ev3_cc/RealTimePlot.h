//
//  RealTimePlot.h
//  CorePlotGallery
//

#import "PlotItem.h"
#import "EV3ValueRange.h"

@interface RealTimePlot : PlotItem<CPTPlotDataSource>
{
    @private
    NSMutableArray *plotData;
    NSUInteger currentIndex;
    NSTimer *dataTimer;
}

@property (strong, nonatomic) NSNumber * currentValue;
@property (assign, nonatomic) EV3ValueRange valueRange;

- (void)newData:(NSTimer *)theTimer;

@end
