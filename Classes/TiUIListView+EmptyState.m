//
//  TiUIListView+EmpyState.m
//  titanium-empty-state
//
//  Created by Hans Knöchel on 01.04.18.
//

#import "TiUIAttributedStringProxy.h"
#import "TiUIListView+EmptyState.h"
#import "TiUIViewProxy.h"

@implementation TiUIListViewProxy (EmptyStateProxy)

- (void)setPlaceholder:(id)arguments
{
  ENSURE_TYPE(arguments, NSDictionary);

  UITableView *tableView = [(TiUIListView *)[self view] tableView];

  if (tableView.emptyDataSetSource == nil && tableView.emptyDataSetDelegate == nil) {
    tableView.emptyDataSetSource = (TiUIListView *)self.view;
    tableView.emptyDataSetDelegate = (TiUIListView *)self.view;
  }

  [self replaceValue:arguments forKey:@"placeholder" notification:NO];
}

- (void)reloadPlaceholder:(id)unused
{
  UITableView *tableView = [(TiUIListView *)[self view] tableView];

  [tableView reloadData];
}

@end

@implementation TiUIListView (EmptyState)

#pragma mark DZNEmptyDataSetSource, DZNEmptyDataSetDelegate

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
  NSString *image = [self placeholderPropertyForAttribute:@"image" withType:[NSString class]];

  if (image == nil) {
    return nil;
  }

  return [TiUtils image:image proxy:self.proxy];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
  TiUIAttributedStringProxy *title = [self placeholderPropertyForAttribute:@"title" withType:[TiUIAttributedStringProxy class]];

  if (title == nil) {
    return nil;
  }

  return title.attributedString;
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
  TiUIAttributedStringProxy *description = [self placeholderPropertyForAttribute:@"description" withType:[TiUIAttributedStringProxy class]];

  if (description == nil) {
    return nil;
  }

  return description.attributedString;
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
{
  TiUIAttributedStringProxy *buttonTitle = [self placeholderPropertyForAttribute:@"buttonTitle" withType:[TiUIAttributedStringProxy class]];

  if (buttonTitle == nil) {
    return nil;
  }

  return buttonTitle.attributedString;
}

- (UIImage *)buttonImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
{
  NSString *buttonImage = [self placeholderPropertyForAttribute:@"buttonImage" withType:[NSString class]];

  if (buttonImage == nil) {
    return nil;
  }

  return [TiUtils image:buttonImage proxy:self.proxy];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
  NSString *backgroundColor = [self placeholderPropertyForAttribute:@"backgroundColor" withType:[NSString class]];

  if (backgroundColor == nil) {
    return nil;
  }

  return [TiUtils colorValue:backgroundColor].color;
}

- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
  TiUIViewProxy *customView = [self placeholderPropertyForAttribute:@"customView" withType:[TiUIViewProxy class]];

  if (customView == nil) {
    return nil;
  }

  return customView.view;
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
  NSNumber *visible = [self placeholderPropertyForAttribute:@"visible" withType:[NSNumber class]];

  return visible.boolValue;
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView
{
  return [[self proxy] _hasListeners:@"placeholderclick"];
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
  NSNumber *scrollEnabled = [self placeholderPropertyForAttribute:@"scrollEnabled" withType:[NSNumber class]];

  return scrollEnabled.boolValue;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view
{
  [[self proxy] fireEvent:@"placeholderclick" withObject:@{ @"clicksource" : @"view" }];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button
{
  [[self proxy] fireEvent:@"placeholderclick" withObject:@{ @"clicksource" : @"button" }];
}

#pragma mark Utilities

- (id)placeholderPropertyForAttribute:(id)attribute withType:(Class)type
{
  NSDictionary *placeholder = [[self proxy] valueForKey:@"placeholder"];

  if (placeholder == nil) {
    return nil;
  }

  id property = placeholder[attribute];

  if (property == nil) {
    return nil;
  }

  if (![property isKindOfClass:type]) {
    [self throwException:@"Invalid placeholder property type"
               subreason:[NSString stringWithFormat:@"Expected %@, got %@", NSStringFromClass(type), NSStringFromClass([property class])]
                location:CODELOCATION];
  }

  return placeholder[attribute];
}

@end