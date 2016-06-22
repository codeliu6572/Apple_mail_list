//
//  ViewController.m
//  通讯录右侧字母点击效果
//
//  Created by 刘浩浩 on 16/6/21.
//  Copyright © 2016年 CodingFire. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    //非汉字和字母开头
    NSMutableArray *jingChar;
    //所有联系人名字头字母
    NSMutableArray *charSectionArray;
    //所有联系人按照头字母分组
    NSMutableArray *_dataArray;
    UITableView *_tableView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _dataArray = [[NSMutableArray alloc]init];
    charSectionArray = [[NSMutableArray alloc]init];
    jingChar = [[NSMutableArray alloc]init];

    //获取plist中的数据
    NSString *plistPath = [[NSBundle mainBundle]pathForResource:@"PeopleNumber" ofType:@"plist"];
    NSArray *plistArray = [NSArray arrayWithContentsOfFile:plistPath];
    NSMutableArray *charArray = [[NSMutableArray alloc]init];
    //获取联系人名字首字母并排序
    for (int i = 0; i < plistArray.count; i++) {
        NSString *plistIndex = plistArray[i];
        NSString *charFirst = [self firstCharactor:plistIndex];
        if ([self MatchLetter:charFirst]) {
            [charArray addObject:charFirst];
        }
        else
        {
            //将不是字母和文字开头的特殊字符打头的string加入＃分组
            [jingChar addObject:plistArray[i]];
        }
    }
    //去除重复的object
    NSSet *set = [NSSet setWithArray:charArray];
    //将NSSet转化回数组
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
    NSArray *sortSetArray = [set sortedArrayUsingDescriptors:sortDesc];
    //按A－Z排序
    NSArray *charAllArray = [sortSetArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //将联系人根据名字首字母进行分组
    /*
     *此分组方法最大的缺陷就是需要一个个比对，所以属于耗时操作，运行后并不会立马显示数据，而是需要一定时间的数据处理，如果要用的话最好在存储方法上开线程后台比对处理来存储，或者预处理，不要在进入这个界面时才处理
     */
    for (int i = 0; i < charAllArray.count; i++) {
        NSString *charStr = charAllArray[i];
        NSMutableArray *subCharArray=[[NSMutableArray alloc]init];
        for (int j=0; j < plistArray.count; j++) {
            NSString *subCharStr = [self firstCharactor:plistArray[j]];
            if ([charStr isEqualToString:subCharStr]) {
                [subCharArray addObject:plistArray[j]];
            }
        }
        [_dataArray addObject:subCharArray];
    }
    [_dataArray addObject:jingChar];
    
    charSectionArray=[NSMutableArray arrayWithArray:charAllArray];
    [charSectionArray addObject:@"#"];
    
    [self creatTableView];
    

}
#pragma mark 正则表达式
-(BOOL)MatchLetter:(NSString *)str
{
    //判断是否以字母开头
    NSString *ZIMU = @"^[A-Za-z]+$";
    NSPredicate *regextestA = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", ZIMU];
    
    if ([regextestA evaluateWithObject:str] == YES)
        return YES;
    else
        return NO;
}

-(BOOL)isChineseFirst:(NSString *)firstStr
{
    //是否以中文开头(unicode中文编码范围是0x4e00~0x9fa5)
    int utfCode = 0;
    void *buffer = &utfCode;
    NSRange range = NSMakeRange(0, 1);
    //判断是不是中文开头的,buffer->获取字符的字节数据 maxLength->buffer的最大长度 usedLength->实际写入的长度，不需要的话可以传递NULL encoding->字符编码常数，不同编码方式转换后的字节长是不一样的，这里我用了UTF16 Little-Endian，maxLength为2字节，如果使用Unicode，则需要4字节 options->编码转换的选项，有两个值，分别是NSStringEncodingConversionAllowLossy和NSStringEncodingConversionExternalRepresentation range->获取的字符串中的字符范围,这里设置的第一个字符 remainingRange->建议获取的范围，可以传递NULL
    BOOL b = [firstStr getBytes:buffer maxLength:2 usedLength:NULL encoding:NSUTF16LittleEndianStringEncoding options:NSStringEncodingConversionExternalRepresentation range:range remainingRange:NULL];
    if (b && (utfCode >= 0x4e00 && utfCode <= 0x9fa5))
        return YES;
    else
        return NO;
}
#pragma mark - creatTableView
- (void)creatTableView
{
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    [_tableView reloadData];
}
//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
- (NSString *)firstCharactor:(NSString *)aString
{
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return [pinYin substringToIndex:1];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [_dataArray[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return charSectionArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%@",charSectionArray[section]];
}
//索引
//一共有两个方法
//第一个方法用返回显示的索引是什么
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{

    return charSectionArray;
}

//第二个方法的作用当点击索引时,跳到对应分组
-(NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    //返回当前索引在tableView分组上的位置
    return index;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text=[[_dataArray objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
