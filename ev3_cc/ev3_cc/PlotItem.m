//
//  PlotItem.m
//  CorePlotGallery
//
//  Created by Jeff Buck on 9/4/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotItem.h"
#import <tgmath.h>

// For IKImageBrowser
#import <Quartz/Quartz.h>

NSString *const kDemoPlots      = @"Demos";
NSString *const kPieCharts      = @"Pie Charts";
NSString *const kLinePlots      = @"Line Plots";
NSString *const kBarPlots       = @"Bar Plots";
NSString *const kFinancialPlots = @"Financial Plots";

@implementation PlotItem

-(id)init
{
    if ( (self = [super init]) ) {
        _defaultLayerHostingView = nil;
        _graphs                  = [[NSMutableArray alloc] init];
        _section                 = nil;
        _title                   = nil;
    }

    return self;
}

-(void)addGraph:(CPTGraph *)graph toHostingView:(CPTGraphHostingView *)layerHostingView
{
    [self.graphs addObject:graph];

    if ( layerHostingView ) {
        layerHostingView.hostedGraph = graph;
    }
}

-(void)addGraph:(CPTGraph *)graph
{
    [self addGraph:graph toHostingView:nil];
}

-(void)killGraph
{
    [[CPTAnimation sharedInstance] removeAllAnimationOperations];

    // Remove the CPTLayerHostingView
    if ( self.defaultLayerHostingView ) {
        [self.defaultLayerHostingView removeFromSuperview];

        self.defaultLayerHostingView.hostedGraph = nil;
        self.defaultLayerHostingView = nil;
    }

    self.cachedImage = nil;

    [self.graphs removeAllObjects];
}

-(void)dealloc
{
    [self killGraph];
}

// override to generate data for the plot if needed
-(void)generateData
{
}

-(NSComparisonResult)titleCompare:(PlotItem *)other
{
    NSComparisonResult comparisonResult = [self.section caseInsensitiveCompare:other.section];

    if ( comparisonResult == NSOrderedSame ) {
        comparisonResult = [self.title caseInsensitiveCompare:other.title];
    }

    return comparisonResult;
}

-(void)setTitleDefaultsForGraph:(CPTGraph *)graph withBounds:(CGRect)bounds
{
    graph.title = self.title;
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color                = [CPTColor grayColor];
    textStyle.fontName             = @"Helvetica-Bold";
    textStyle.fontSize             = round( bounds.size.height / CPTFloat(20.0) );
    graph.titleTextStyle           = textStyle;
    graph.titleDisplacement        = CPTPointMake( 0.0, textStyle.fontSize * CPTFloat(1.5) );
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
}

-(void)setPaddingDefaultsForGraph:(CPTGraph *)graph withBounds:(CGRect)bounds
{
    CGFloat boundsPadding = round( bounds.size.width / CPTFloat(20.0) ); // Ensure that padding falls on an integral pixel

    graph.paddingLeft = boundsPadding;

    if ( graph.titleDisplacement.y > 0.0 ) {
        graph.paddingTop = graph.titleTextStyle.fontSize * 2.0;
    }
    else {
        graph.paddingTop = boundsPadding;
    }

    graph.paddingRight  = boundsPadding;
    graph.paddingBottom = boundsPadding;
}

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE

-(UIImage *)image
{
    if ( cachedImage == nil ) {
        CGRect imageFrame = CGRectMake(0, 0, 400, 300);
        UIView *imageView = [[UIView alloc] initWithFrame:imageFrame];
        [imageView setOpaque:YES];
        [imageView setUserInteractionEnabled:NO];

        [self renderInView:imageView withTheme:nil animated:NO];

        CGSize boundsSize = imageView.bounds.size;

        if ( UIGraphicsBeginImageContextWithOptions ) {
            UIGraphicsBeginImageContextWithOptions(boundsSize, YES, 0.0);
        }
        else {
            UIGraphicsBeginImageContext(boundsSize);
        }

        CGContextRef context = UIGraphicsGetCurrentContext();

        CGContextSetAllowsAntialiasing(context, true);

        for ( UIView *subView in imageView.subviews ) {
            if ( [subView isKindOfClass:[CPTGraphHostingView class]] ) {
                CPTGraphHostingView *hostingView = (CPTGraphHostingView *)subView;
                CGRect frame                     = hostingView.frame;

                CGContextSaveGState(context);

                CGContextTranslateCTM(context, frame.origin.x, frame.origin.y + frame.size.height);
                CGContextScaleCTM(context, 1.0, -1.0);
                [hostingView.hostedGraph layoutAndRenderInContext:context];

                CGContextRestoreGState(context);
            }
        }

        CGContextSetAllowsAntialiasing(context, false);

        cachedImage = UIGraphicsGetImageFromCurrentImageContext();
        [cachedImage retain];
        UIGraphicsEndImageContext();

        [imageView release];
    }

    return cachedImage;
}

#else // OSX

-(NSImage *)image
{
    if ( self.cachedImage == nil ) {
        CGRect imageFrame = CGRectMake(0, 0, 400, 300);

        NSView *imageView = [[NSView alloc] initWithFrame:NSRectFromCGRect(imageFrame)];
        [imageView setWantsLayer:YES];

        [self renderInView:imageView withTheme:nil animated:NO];

        CGSize boundsSize = imageFrame.size;

        NSBitmapImageRep *layerImage = [[NSBitmapImageRep alloc]
                                        initWithBitmapDataPlanes:NULL
                                                      pixelsWide:boundsSize.width
                                                      pixelsHigh:boundsSize.height
                                                   bitsPerSample:8
                                                 samplesPerPixel:4
                                                        hasAlpha:YES
                                                        isPlanar:NO
                                                  colorSpaceName:NSCalibratedRGBColorSpace
                                                     bytesPerRow:(NSInteger)boundsSize.width * 4
                                                    bitsPerPixel:32];

        NSGraphicsContext *bitmapContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:layerImage];
        CGContextRef context             = (CGContextRef)[bitmapContext graphicsPort];

        CGContextClearRect( context, CGRectMake(0.0, 0.0, boundsSize.width, boundsSize.height) );
        CGContextSetAllowsAntialiasing(context, true);
        CGContextSetShouldSmoothFonts(context, false);
        [imageView.layer renderInContext:context];
        CGContextFlush(context);

        self.cachedImage = [[NSImage alloc] initWithSize:NSSizeFromCGSize(boundsSize)];
        [self.cachedImage addRepresentation:layerImage];
    }

    return self.cachedImage;
}
#endif

-(void)applyTheme:(CPTTheme *)theme toGraph:(CPTGraph *)graph withDefault:(CPTTheme *)defaultTheme
{
    if ( theme == nil ) {
        [graph applyTheme:defaultTheme];
    }
    else if ( ![theme isKindOfClass:[NSNull class]] ) {
        [graph applyTheme:theme];
    }
}

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
-(void)setFrameSize:(NSSize)size
{
}
#endif

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
-(void)renderInView:(UIView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
#else
-(void)renderInView:(NSView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
#endif
{
    [self killGraph];

    self.defaultLayerHostingView = [(CPTGraphHostingView *)[CPTGraphHostingView alloc] initWithFrame : hostingView.bounds];

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    defaultLayerHostingView.collapsesLayers = NO;
    [defaultLayerHostingView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
#else
    [self.defaultLayerHostingView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
#endif
    [self.defaultLayerHostingView setAutoresizesSubviews:YES];

    [hostingView addSubview:self.defaultLayerHostingView];
    [self generateData];
    [self renderInLayer:self.defaultLayerHostingView withTheme:theme animated:animated];
}

-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
    NSLog(@"PlotItem:renderInLayer: Override me");
}

-(void)reloadData
{
    for ( CPTGraph *g in self.graphs ) {
        [g reloadData];
    }
}

#pragma mark -
#pragma mark IKImageBrowserItem methods

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else

-(NSString *)imageUID
{
    return self.title;
}

-(NSString *)imageRepresentationType
{
    return IKImageBrowserNSImageRepresentationType;
}

-(id)imageRepresentation
{
    return [self image];
}

-(NSString *)imageTitle
{
    return self.title;
}

/*
 * - (NSString*)imageSubtitle
 * {
 *  return graph.title;
 * }
 */
#endif

@end