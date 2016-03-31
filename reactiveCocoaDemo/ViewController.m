//
//  ViewController.m
//  reactiveCocoaDemo
//
//  Created by 艾泽鑫 on 16/3/31.
//  Copyright © 2016年 艾泽鑫. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveCocoa.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *pasWord;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
/** 姓名是否有效 */
@property (assign,nonatomic,getter=isUsernameValid)BOOL usernameValid;
/** 密码是否有效 */
@property (assign,nonatomic,getter=isPasswordValid)BOOL passwordValid;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    [[self.submitBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)]
    subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
}
//- (RACSignal *)signInSignal {
//    return [RACSignal createSignal:^RACDisposable *(id subscriber){
//        [self.signInService
//         signInWithUsername:self.usernameTextField.text
//         password:self.passwordTextField.text
//         complete:^(BOOL success){
//             [subscriber sendNext:@(success)];
//             [subscriber sendCompleted];
//         }];
//        return nil;
//    }];
//}

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

@end
