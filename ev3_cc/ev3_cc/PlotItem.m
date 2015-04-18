//
//  PlotItem.m
//  CorePlotGallery
//
//  Created by Jeff Buck on 9/4/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotItem.h"
#import <tgmath.h>

@implementation PlotItem

-(id)init
{
    if ( (self = [super init]) ) {
        _defaultLayerHostingView = nil;
        _graphs                  = [[NSMutableArray alloc] init];
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

-(void)applyTheme:(CPTTheme *)theme toGraph:(CPTGraph *)graph withDefault:(CPTTheme *)defaultTheme
{
    if ( theme == nil ) {
        [graph applyTheme:defaultTheme];
    }
    else if ( ![theme isKindOfClass:[NSNull class]] ) {
        [graph applyTheme:theme];
    }
}

-(void)setFrameSize:(NSSize)size
{
}

-(void)renderInView:(NSView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
    [self killGraph];

    self.defaultLayerHostingView = [(CPTGraphHostingView *)[CPTGraphHostingView alloc] initWithFrame : hostingView.bounds];

    [self.defaultLayerHostingView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
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

@end
