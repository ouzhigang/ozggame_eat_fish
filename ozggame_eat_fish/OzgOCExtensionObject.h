/*
 内置类方法扩展
 最后修改日期: 2012-12-19
 最后修改人: ozg
 
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//NS

@interface NSString(ExtensionNSString)

- (NSUInteger) getReallyLength; //获取真实长度（中文为两个字节）

- (NSString*)toURLEncoding; //URL编码

- (NSString*)stringByAppendingFileSuffix:(NSString*)suffix; //添加文件名后缀（除去文件扩展名）

@end

@interface NSArray(ExtensionNSArray)

- (NSArray*)randSort; //随机排序

@end

//UIKit

@interface UIImage(ExtensionUIImage)

- (UIImage *)imageRotatedByRadians:(CGFloat)radians; //图片旋转 参数为弧度
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees; //图片旋转 参数为角度
- (UIImage*)imageWithUIView:(UIView*) view; //将UIView转成UIImage

@end

@interface UIColor(ExtensionUIColor)

+ (UIColor*) colorFromHexRGB:(NSString*) inColorString; //用十六进制的方式获取UIColor对象（参数的前面不用加#号）

@end
