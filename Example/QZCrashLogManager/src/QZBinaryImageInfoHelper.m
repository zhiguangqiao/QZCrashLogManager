//
//  QZBinaryImageInfoHelper
//  iOSProject
//
//  Created by QiaoZhiGuang on 15/12/25.
//  Copyright © 2015年 xingshulin. All rights reserved.
//

#import "QZBinaryImageInfoHelper.h"
#import <mach-o/dyld.h>
@implementation QZBinaryImageInfoHelper

+ (void)initialize {
    calculate();
}

static long slide = 0;
static NSString *uuid = @"";
static NSString *arch = @"";

static void calculate(void) {
    
    
    const struct mach_header *executableHeader = NULL;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        if (_dyld_get_image_header(i)->filetype == MH_EXECUTE) {
            slide = _dyld_get_image_vmaddr_slide(i);
            executableHeader = _dyld_get_image_header(i);
            break;
        }
    }
    if (!executableHeader) return;
    
    uuid = getUUIDFromeHeader(executableHeader);
    arch = getArchFromeHeader(executableHeader);
    
}
static NSString *getUUIDFromeHeader(const struct mach_header *header) {
    
    BOOL is64bit = header->magic == MH_MAGIC_64 || header->magic == MH_CIGAM_64;
    uintptr_t cursor = (uintptr_t)header + (is64bit ? sizeof(struct mach_header_64) : sizeof(struct mach_header));
    const struct segment_command *segmentCommand = NULL;
    for (uint32_t i = 0; i < header->ncmds; i++, cursor += segmentCommand->cmdsize)
    {
        segmentCommand = (struct segment_command *)cursor;
        if (segmentCommand->cmd == LC_UUID)
        {
            const struct uuid_command *uuidCommand = (const struct uuid_command *)segmentCommand;
            return [[NSUUID alloc] initWithUUIDBytes:uuidCommand->uuid].UUIDString;
        }
    }
    return @"";
}

static NSString *getArchFromeHeader(const struct mach_header *header) {
    
    NSMutableString *cpu = [NSMutableString string];
    cpu_type_t type;
    cpu_subtype_t subtype;
    
    type = header->cputype;
    subtype = header->cpusubtype;
    
    if (type == CPU_TYPE_X86)
    {
        [cpu appendString:@"X86"];
        
    } else if (type == CPU_TYPE_X86_64) {
        
        [cpu appendString:@"X86_64"];
        
    } else if (type == CPU_TYPE_ARM) {
        
        [cpu appendString:@"ARM"];
        switch(subtype)
        {
            case CPU_SUBTYPE_ARM_V7:
                [cpu appendString:@"V7"];
                break;
            default:{
                [cpu appendString:@"V7S"];
            }
        }
        
    } else if (type == CPU_TYPE_ARM64){
        
        [cpu appendString:@"ARM64"];
        
    }
    return cpu;
}

+ (NSString *) getArchString {
    return [arch copy];
}

+ (long) getBinaryLoadSlide {
    return slide;
}

+ (NSString *) getUUIDString {
    return [uuid copy];
}

@end
