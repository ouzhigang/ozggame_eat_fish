#import "OzgCCUtility.h"

@implementation OzgCCUtility

+ (CCAnimate*) createAnimate:(NSString*)plist
{
    NSMutableArray *spriteFrames = [NSMutableArray array];
    NSDictionary *root = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], plist]];
    
    NSInteger loops = [(NSString*)[root objectForKey:@"loop"] integerValue];
    float delay = [(NSString*)[root objectForKey:@"delay"] floatValue];
    NSArray *frames = (NSArray*)[root objectForKey:@"frames"];
    NSDictionary *rectDict = (NSDictionary*)[root objectForKey:@"rect"];
    
    CGFloat rectX = [(NSString*)[rectDict objectForKey:@"x"] floatValue];
    CGFloat rectY = [(NSString*)[rectDict objectForKey:@"y"] floatValue];
    CGFloat rectWidth = [(NSString*)[rectDict objectForKey:@"width"] floatValue];
    CGFloat rectHeight = [(NSString*)[rectDict objectForKey:@"height"] floatValue];
    CGRect rect = CGRectMake(rectX, rectY, rectWidth, rectHeight);

    for (NSObject *item in frames)
    {
        NSString *itemStr = (NSString*)item;
        
        CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:itemStr];
        CCSpriteFrame *spriteFrame = [CCSpriteFrame frameWithTexture:texture rect:rect];
        [spriteFrames addObject:spriteFrame];
        
    }
    
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:spriteFrames delay:delay];
    [animation setLoops:loops];
    
    CCAnimate *animate = [CCAnimate actionWithAnimation:animation];
    return animate;
}

+ (void)clearAnimate:(NSString*)plist
{
    NSDictionary *root = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], plist]];
    NSArray *frames = (NSArray*)[root objectForKey:@"frames"];
    for (NSObject *item in frames)
    {
        NSString *itemStr = (NSString*)item;
        [[CCTextureCache sharedTextureCache] removeTextureForKey:itemStr];
    }
    
}

+ (NSString*)getImagePath:(NSString*)path
{
    if([OzgOCUtility isRunAtIphone5])
    {
        NSString *ext = [path pathExtension];
        return [NSString stringWithFormat:@"%@.%@", [[path stringByDeletingPathExtension] stringByAppendingString:@"-ip5"], ext];
    }
    else
        return path;
}

+ (BOOL)randomRate:(CGFloat)rate
{
    if(CCRANDOM_0_1() <= rate)
        return YES;
    
    return NO;
}

+ (CGFloat)randomRange:(CGFloat)minValue withMaxValue:(CGFloat)maxValue
{
    CGFloat val = maxValue - minValue;
    val = minValue + (val * CCRANDOM_0_1());
    return val;
}

@end
