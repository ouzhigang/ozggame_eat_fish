#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "OzgOCUtility.h"

@interface OzgCCUtility : NSObject

+ (NSString*)getImagePath:(NSString*)path;
+ (BOOL)randomRate:(CGFloat)rate; //0到1的随机抽中率，参数0.5则为50%的机率会返回YES 
+ (CGFloat)randomRange:(CGFloat)minValue withMaxValue:(CGFloat)maxValue; //范围随机值

@end
