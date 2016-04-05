//
//  ViewController.m
//  reactiveCocoaDemo
//
//  Created by 艾泽鑫 on 16/3/31.
//  Copyright © 2016年 艾泽鑫. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveCocoa.h"
#import "RWDummySignInService.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *pasWord;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
/** 提示label*/
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
/** 姓名是否有效 */
@property (assign,nonatomic,getter=isUsernameValid)BOOL usernameValid;
/** 密码是否有效 */
@property (assign,nonatomic,getter=isPasswordValid)BOOL passwordValid;
@property (strong, nonatomic) RWDummySignInService *signInService;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.signInService = [[RWDummySignInService alloc]init];
    __block typeof(self) weakSelf = self;
    
    RACSignal *validUsernameSignal = [self.nameText.rac_textSignal map:^id(id value) {
        NSString *text = value;
        return @([self isValidUsername:text]);
    }];
    RACSignal *validPasswordSignal = [self.pasWord.rac_textSignal map:^id(id value) {
        NSString *text = value;
        return @([self isValidPassword:text]);
    }];
    RAC(self.pasWord,backgroundColor) = [validPasswordSignal map:^id(NSNumber *passwordValid) {
        return [passwordValid boolValue] ?[UIColor clearColor]:[UIColor yellowColor];
    }];
    RAC(self.nameText,backgroundColor) = [validUsernameSignal map:^id(NSNumber *passwordValid) {
        return [passwordValid boolValue] ?[UIColor clearColor]:[UIColor yellowColor];
    }];
    RACSignal *signUpActiveSignal = [RACSignal combineLatest:@[validUsernameSignal,validPasswordSignal] reduce:^id{
        return @(self.isUsernameValid && self.isPasswordValid);
    }];
    [signUpActiveSignal subscribeNext:^(NSNumber *signupActive) {
        self.submitBtn.enabled = [signupActive boolValue];
    }];
    
    [[[[self.submitBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)]
      doNext:^(id x) {
          self.submitBtn.enabled = NO;
          self.tipsLabel.hidden = YES;
      } ]
     flattenMap:^id(id value) {
         return [self signInSignal];
     }]
    subscribeNext:^(NSNumber *signedIn) {
        NSLog(@"Sign in result: %@", signedIn);
        weakSelf.submitBtn.enabled = YES;
        BOOL success = [signedIn boolValue];
        weakSelf.tipsLabel.hidden = success;
        if (success) {
            NSLog(@"成功跳转");
        }
    }];
    
    /*// 1.遍历数组
    NSDictionary *dict = @{@"name":@"xmg",@"age":@18};
    
    // 这里其实是三步
    // 第一步: 把数组转换成集合RACSequence numbers.rac_sequence
    // 第二步: 把集合RACSequence转换RACSignal信号类,numbers.rac_sequence.signal
    // 第三步: 订阅信号，激活信号，会自动把集合中的所有值，遍历出来。
    [dict.rac_sequence.signal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];*/
}

-(BOOL )isValidUsername:(NSString*)text{
    self.usernameValid = text.length > 3;
    return _usernameValid;
}
-(BOOL)isValidPassword:(NSString *)text{
    self.passwordValid = text.length > 3;
    return _passwordValid;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 *  创建信号
 *
 *  @return <#return value description#>
 */
- (RACSignal *)signInSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber){
        [self.signInService
         signInWithUsername:self.nameText.text
         password:self.pasWord.text
         complete:^(BOOL success){
             [subscriber sendNext:@(success)];
             [subscriber sendCompleted];
         }];
        return nil;
    }];
}

@end
