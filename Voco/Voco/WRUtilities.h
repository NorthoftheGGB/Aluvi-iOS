//
//  Copyright (c) 2013 David Whiteman Enterprises LLC. All rights reserved.
//  Permission is hereby granted to Phaze 4 Media and AMCI Global to deal in the Software with rights to use, copy, modify, merge, and publish solely for distribution on Kia Ride and Drive Tour.  
//  Distribution outside of the above mentioned entities is strictly prohibited without written consent by an authorized agent of David Whiteman Enterprises LLC
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//



#import <Foundation/Foundation.h>

@interface WRUtilities : NSObject

+ (id)getViewFromNib: (NSString *) nibName class: (id) class;
+ (void) criticalError: (NSError *) error;
+ (void) criticalErrorWithString: (NSString *) error;
+ (void) subcriticaError: (NSError *) error;
+ (void) subcriticalErrorWithString: (NSString *) error;
+ (void) warningWithString: (NSString *) error;
+ (void) successMessage: (NSString *) message;
+ (void) stateErrorWithString: (NSString*) message;
+ (void) showNetworkUnavailableMessage;

@end
