//
// Hewlett-Packard Company
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import "HPPPSelectImageTableViewController.h"

@interface HPPPSelectImageTableViewController ()

@property (strong, nonatomic) NSArray *sizeList;
@property (strong, nonatomic) NSArray *dpiList;
@property (strong, nonatomic) NSArray *orientationList;
@property (strong, nonatomic) NSArray *sampleImages;

@end

@implementation HPPPSelectImageTableViewController

NSInteger const kHPPPSelectImageSampleSection = 3;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sizeList = @[ @"4x6", @"5x7", @"Letter" ];
    self.dpiList = @[ @"72dpi", @"300dpi" ];
    self.orientationList = @[ @"portrait", @"landscape" ];
    self.sampleImages = @[
                          @"Baloons",
                          @"Cat",
                          @"Dog",
                          @"Earth",
                          @"Flowers",
                          @"Focus on Quality",
                          @"Galaxy",
                          @"Garden Path",
                          @"Quality Seal",
                          @"Soccer Ball"
                          ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sizeList.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = self.dpiList.count * self.orientationList.count;
    if (kHPPPSelectImageSampleSection == section) {
        count = self.sampleImages.count;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Image Cell" forIndexPath:indexPath];
    UIImage *image = [self imageFromIndexPath:indexPath];
    cell.imageView.image = image;
    if (kHPPPSelectImageSampleSection == indexPath.section) {
        cell.textLabel.text = [self.sampleImages objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f x %.0f", image.size.width, image.size.height];
    } else {
        NSDictionary *imageInfo = [self imageInfoFromIndexPath:indexPath];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [imageInfo objectForKey:@"size"], [imageInfo objectForKey:@"orientation"]];
        cell.detailTextLabel.text = [imageInfo objectForKey:@"dpi"];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(didSelectImage:)]) {
            [self.delegate didSelectImage:[self imageFromIndexPath:indexPath]];
        }
    }];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"ADDITIONAL SAMPLES";
    if (kHPPPSelectImageSampleSection != section) {
        title = [NSString stringWithFormat:@"%@ SIZE", [self.sizeList objectAtIndex:section]];
    }
    return title;
}

#pragma mark - Button actions

- (IBAction)cancelButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helpers

- (NSDictionary *)imageInfoFromIndexPath:(NSIndexPath *)indexPath
{
    NSString *size = @"???";
    NSString *dpi = @"???";
    NSString *orientation = @"???";
    if (kHPPPSelectImageSampleSection != indexPath.section) {
        size = [self.sizeList objectAtIndex:indexPath.section];
        dpi = [self.dpiList objectAtIndex:indexPath.row / self.orientationList.count];
        orientation = [self.orientationList objectAtIndex:indexPath.row % self.orientationList.count];
    }
    
    return @{ @"size":size, @"dpi":dpi, @"orientation":orientation };
}

- (UIImage *)imageFromIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *imageInfo = [self imageInfoFromIndexPath:indexPath];
    NSString *filename;
    if (kHPPPSelectImageSampleSection == indexPath.section) {
        filename = [NSString stringWithFormat:@"%@.jpg", [self.sampleImages objectAtIndex:indexPath.row]];
    } else {
        filename = [NSString stringWithFormat:@"%@.%@.%@.jpg", [imageInfo objectForKey:@"size"], [imageInfo objectForKey:@"dpi"], [imageInfo objectForKey:@"orientation"]];
    }
    return [UIImage imageNamed:filename];
}

@end
