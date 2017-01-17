//
//  VoiceConverter.h
//  Jeans
//
//  Created by Jeans Huang on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoiceConverter : NSObject

+ (int)ConvertAmrToWav:(NSString*)_amrPath wavSavePath:(NSString*)_savePath;

+ (int)ConvertWavToAmr:(NSString*)_wavPath amrSavePath:(NSString*)_savePath;

@end
