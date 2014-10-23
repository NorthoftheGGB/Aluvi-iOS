//
//  VCCodes.m
//  Voco
//
//  Created by Matthew Shultz on 10/13/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCCodes.h"

@implementation VCCodes

+ (BOOL) checkCode: (NSString *) code {
    
    NSArray * codes = @[
                        @"quails",
                        @"glassdoormv",
                        @"fzzvvbvt",
                        @"gqqfjuks",
                        @"ywtkudon",
                        @"zvarrfzd",
                        @"ulhhxoiw",
                        @"jqppylrn",
                        @"wbayhytj",
                        @"wzbbojfo",
                        @"cjgzzflx",
                        @"rcncqgec",
                        @"xzdpasno",
                        @"nzjnowja",
                        @"ttdfouyg",
                        @"qaycilms",
                        @"mnkafnbs",
                        @"bwamvgwe",
                        @"tonevabq",
                        @"wqnshgkl",
                        @"wspldiht",
                        @"tryawnba",
                        @"linhsict",
                        @"ubuuxioo",
                        @"exqvihgn",
                        @"oxfeslsj",
                        @"wefnpefi",
                        @"mafyvbzf",
                        @"tuvsloxd",
                        @"izsrlerg",
                        @"cqoqdoan",
                        @"ldtuppkf",
                        @"ygzroklk",
                        @"bmfmhggh",
                        @"lekuohms",
                        @"jlufesau",
                        @"uekbyfnz",
                        @"repjtxzl",
                        @"dlwfcrmf",
                        @"xftwourt",
                        @"pwspiazt",
                        @"dlonehih",
                        @"puykwwgg",
                        @"farfmgok",
                        @"smhohygn",
                        @"ubfczxlq",
                        @"khusbnln",
                        @"hvuqzyda",
                        @"xeawkror",
                        @"trniicvr",
                        @"jvasydgb",
                        @"xlqkfbtr",
                        @"mdadggzk",
                        @"sububgwl",
                        @"pdfyseyu",
                        @"rgsaingg",
                        @"zdxmeffn",
                        @"avipgtag",
                        @"kpyihgat",
                        @"swdurjup",
                        @"fhiodybq",
                        @"jbututbh",
                        @"larennpv",
                        @"wlesyyhk",
                        @"zldcfbwy",
                        @"okrosiqc",
                        @"npkknbvm",
                        @"ejbqchdd",
                        @"hutlygoc",
                        @"aoztqvgg",
                        @"rtwpnwod",
                        @"iiaczxfi",
                        @"inkwwttm",
                        @"oqgwukcn",
                        @"pygfnowv",
                        @"aqlnyspl",
                        @"lnvkttdh",
                        @"aodhgrbr",
                        @"gmemrfdd",
                        @"cgejqdab",
                        @"mxqmbrql",
                        @"xpnrmzev",
                        @"lvdjdrqe",
                        @"wmiulxdv",
                        @"aoqqzzac",
                        @"xfyejvwv",
                        @"bxxebttb",
                        @"ttaxpcey",
                        @"uapmoilg",
                        @"gdyqeagi",
                        @"embttaol",
                        @"axcysflt",
                        @"kpedilkt",
                        @"mvwgyhds",
                        @"vyhwidid",
                        @"xzwyzhyp",
                        @"lvwtqigl",
                        @"eqvmipvi",
                        @"ccmhstbc",
                        @"gazsdjld",
                        @"kepnurhl",
                        @"rqyqcrvr"
                        ];
    
    if( [codes containsObject:code]) {
        return YES;
    } else {
        return NO;
    }
}

@end
