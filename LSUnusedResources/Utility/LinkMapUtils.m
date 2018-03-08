//
//  LInkMapUtils.m
//  LSUnusedResources
//
//  Created by Wenzhou on 08/03/2018.
//  Copyright © 2018 lessfun.com. All rights reserved.
//

#import "LinkMapUtils.h"
#include <stdlib.h>

@interface SymbolModel : NSObject

@property (nonatomic, copy) NSString *file;
@property (nonatomic, assign) NSUInteger size;

@end
@implementation SymbolModel

@end

@interface LinkMapUtils()
+ (NSString*) formatSize: (NSUInteger) size;
+ (NSArray<SymbolModel *> *) mergeLibs: (NSArray<SymbolModel *>*) oldLibs;
@end

@implementation LinkMapUtils

+ (NSString*) startAnalysis: (NSString*) path {
    
    NSString *srcPath = path;
    
    NSMutableDictionary <NSString *,SymbolModel *> *sizeMap = [NSMutableDictionary new] ;
    
    NSString *content = [NSString stringWithContentsOfFile:srcPath encoding:NSASCIIStringEncoding error:nil];
    
    if(!content)
        return nil;
    
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    
    BOOL reachFiles = NO;
    BOOL reachSymbols = NO;
    BOOL reachSections = NO;
    
    for(NSString *line in lines)
    {
        if([line hasPrefix:@"#"])   //注释行
        {
            if([line hasPrefix:@"# Object files:"])
                reachFiles = YES;
            else if ([line hasPrefix:@"# Sections:"])
                reachSections = YES;
            else if ([line hasPrefix:@"# Symbols:"])
                reachSymbols = YES;
        }
        else
        {
            if(reachFiles == YES && reachSections == NO && reachSymbols == NO)
            {
                NSRange range = [line rangeOfString:@"]"];
                if(range.location != NSNotFound)
                {
                    NSString* file = [[[line substringFromIndex:range.location + 1] componentsSeparatedByString: @"/"].lastObject stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    SymbolModel *symbol = [SymbolModel new];
                    symbol.file = file;
                    NSString *key = [[line substringWithRange: NSMakeRange(1, range.location)] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    sizeMap[key] = symbol;
                }
            }
            else if (reachFiles == YES &&reachSections == YES && reachSymbols == NO)
            {
            }
            else if (reachFiles == YES && reachSections == YES && reachSymbols == YES)
            {
                NSArray <NSString *>*symbolsArray = [line componentsSeparatedByString:@"\t"];
                if(symbolsArray.count == 3)
                {
                    //Address Size File Name
                    NSString *fileKeyAndName = symbolsArray[2];
                    NSUInteger size = strtoul([symbolsArray[1] UTF8String], nil, 16);
                    
                    NSRange range = [fileKeyAndName rangeOfString:@"]"];
                    if(range.location != NSNotFound)
                    {
                        NSString* key = [[fileKeyAndName substringWithRange: NSMakeRange(1, range.location)] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        SymbolModel *symbol = sizeMap[key];
                        if(symbol)
                        {
                            symbol.size += size;
                        }
                    }
                }
            }
        }
        
    }
    
    NSArray <SymbolModel *> *symbols = [sizeMap allValues];
    NSArray<SymbolModel*>* mergedSymbols = [self mergeLibs: symbols];
    NSArray *sorted = [mergedSymbols sortedArrayUsingComparator:^NSComparisonResult(SymbolModel *  _Nonnull obj1, SymbolModel *  _Nonnull obj2) {
        if(obj1.size > obj2.size)
            return NSOrderedAscending;
        else if (obj1.size < obj2.size)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
    
    NSMutableString *finalResult = [NSMutableString stringWithFormat: @""];
    
    NSMutableString *result = [@"各模块体积大小\n" mutableCopy];
    NSUInteger totalSize = 0;
    
    for(SymbolModel *symbol in sorted)
    {
        [result appendFormat:@"%@\t %@\n", symbol.file, [self formatSize: symbol.size]];
        totalSize += symbol.size;
    }
    
    [finalResult appendFormat:@"总体积: %@\n", [self formatSize: totalSize]];
    [finalResult appendString: result];
    
    return finalResult;
}

+ (NSString*) formatSize: (NSUInteger) size {
    if (size > 1024 * 1024) {
        return [NSString stringWithFormat:@"%.2fMB", size/(1024.0 * 1024)];
    } else if (size > 1024) {
        return [NSString stringWithFormat:@"%.2fKB", size/(1024.0)];
    }
    return [NSString stringWithFormat:@"%luB", (unsigned long)size];
}

+ (NSArray<SymbolModel *> *) mergeLibs: (NSArray<SymbolModel *>*) oldLibs {
    NSMutableDictionary<NSString*, SymbolModel *> *resultDic = [NSMutableDictionary new];
    for(SymbolModel* symbol in oldLibs){
        NSString* file = symbol.file;
        NSString* libName = @"";
        NSRange range = [file rangeOfString: @".o"];
        if (range.location != NSNotFound) {
            libName = [file componentsSeparatedByString: @"("].firstObject;
        } else {
            libName = file;
        }
        if (!resultDic[libName]) {
            SymbolModel* model = [SymbolModel new];
            model.file = libName;
            model.size = symbol.size;
            resultDic[libName] = model;
        } else {
            SymbolModel* model = resultDic[libName];
            model.size += symbol.size;
        }
    }
    return [resultDic allValues];
}

@end
