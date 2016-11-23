//
//  ViewController.m
//  TwoDimensionCode
//
//  Created by xp on 2016/11/23.
//  Copyright © 2016年 com.yunwangnet. All rights reserved.
//

#import "ViewController.h"
#import "GetAndAddContacts.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,CNContactPickerDelegate,ABPeoplePickerNavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)getAllContactsBtnAction:(UIButton *)sender;
- (IBAction)useSystemBtnAction:(UIButton *)sender;
- (IBAction)addAContactBtnAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *systemInfoLabel;


@property (nonatomic,strong) NSMutableArray *allConsArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableView.delegate = self;
    self.tableView.dataSource  = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 按钮响应函数
- (IBAction)getAllContactsBtnAction:(UIButton *)sender {
    self.allConsArr = [[GetAndAddContacts sharedContacts] getAllContacts].mutableCopy;
    [self.tableView reloadData];
}

- (IBAction)useSystemBtnAction:(UIButton *)sender {
    
    if ((NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_x_Max)) {
        CNContactPickerViewController *contactVc = [[CNContactPickerViewController alloc] init];
        contactVc.delegate = self;
        [self presentViewController:contactVc animated:YES completion:nil];
    }else{
        ABPeoplePickerNavigationController *nav = [[ABPeoplePickerNavigationController alloc] init];
        nav.peoplePickerDelegate = self;
//        if(IOS8_OR_LATER){
//            nav.predicateForSelectionOfPerson = [NSPredicate predicateWithValue:false];
//        }
        [self presentViewController:nav animated:YES completion:nil];
    }
    
    
    
}

- (IBAction)addAContactBtnAction:(UIButton *)sender {
}
#pragma mark - 网络请求

#pragma mark - 协议函数
#pragma mark - UITableViewDataSource,UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allConsArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CustomCell";
    
    UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSDictionary *conDic = self.allConsArr[indexPath.row];
    cell.textLabel.text = conDic[kName];
    cell.detailTextLabel.text = conDic[kPhoneNum];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 取消Cell的选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - CNContactPickerDelegate
// 1.点击取消按钮调用的方法
- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker
{
    NSLog(@"取消选择联系人");
    self.systemInfoLabel.text = @"取消了选择联系人";
}
// 2.当选中某一个联系人时会执行该方法
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact
{
    // 1.获取联系人的姓名
    NSString *lastname = contact.familyName;
    NSString *firstname = contact.givenName;
    NSLog(@"%@ %@", lastname, firstname);
    
    // 2.获取联系人的电话号码(此处获取的是该联系人的第一个号码,也可以遍历所有的号码)
    NSArray *phoneNums = contact.phoneNumbers;
    CNLabeledValue *labeledValue = phoneNums[0];
    CNPhoneNumber *phoneNumer = labeledValue.value;
    NSString *phoneNumber = phoneNumer.stringValue;
    NSLog(@"%@", phoneNumber);
    
    self.systemInfoLabel.text = [NSString stringWithFormat:@"姓名:%@%@ 电话:%@",lastname, firstname,phoneNumber];
}

//取消选择
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
    long index = ABMultiValueGetIndexForIdentifier(phone,identifier);
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSString *phoneNO = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phone, index);
    
    if ([phoneNO hasPrefix:@"+"]) {
        phoneNO = [phoneNO substringFromIndex:3];
    }
    
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSLog(@"%@", phoneNO);
    self.systemInfoLabel.text = [NSString stringWithFormat:@"姓名:%@%@ 电话:%@",lastName, firstName,phoneNO];
//    if (phone && [ZXValidateHelper checkTel:phoneNO]) {
//        phoneNum = phoneNO;
//        [self.tableView reloadData];
//        [peoplePicker dismissViewControllerAnimated:YES completion:nil];
//        return;
//    }
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person
{
    ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
    personViewController.displayedPerson = person;
    [peoplePicker pushViewController:personViewController animated:YES];
}

#pragma mark - 组装数据、创建视图、自定义方法



@end
