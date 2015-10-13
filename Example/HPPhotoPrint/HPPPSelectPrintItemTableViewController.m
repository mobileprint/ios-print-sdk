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

#import "HPPP.h"
#import "HPPPSelectPrintItemTableViewController.h"
#import <DBChooser/DBChooser.h>
#import "HPPPPrintItemFactory.h"

@interface HPPPSelectPrintItemTableViewController ()

@property (strong, nonatomic) NSArray *sizeList;
@property (strong, nonatomic) NSArray *dpiList;
@property (strong, nonatomic) NSArray *orientationList;
@property (strong, nonatomic) NSArray *sampleImages;
@property (strong, nonatomic) NSArray *pdfList;
@property (strong, nonatomic) NSArray *aspectRatioList;
@property (assign, nonatomic) BOOL dropboxBusy;

@end

@implementation HPPPSelectPrintItemTableViewController

NSInteger const kHPPPSelectImageDropboxSection = 0;
NSInteger const kHPPPSelectImageSampleSection = 4;
NSInteger const kHPPPSelectImagePDFSection = 5;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sizeList = @[ @"4x6", @"5x7", @"Letter" ];
    self.aspectRatioList = @[ @"1.500", @"1.400", @"1.294" ];
    self.dpiList = @[ @"72dpi", @"300dpi" ];
    self.orientationList = @[ @"portrait", @"landscape" ];
    self.sampleImages = @[
                          @"The Kiss",
                          @"Bird",
                          @"3up",
                          @"4up",
                          @"Balloons",
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
    self.pdfList = @[
                     @"1 Page",
                     @"1 Page (landscape)",
                     @"2 Pages",
                     @"4 Pages",
                     @"6 Pages (landscape)",
                     @"10 Pages",
                     @"15 Pages",
                     @"44 Pages",
                     @"51 Pages",
                     @"115 Pages",
                     @"236 Pages"
                     ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sizeList.count + 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = self.dpiList.count * self.orientationList.count;
    if (kHPPPSelectImageDropboxSection == section) {
        count = 1;
    } else if (kHPPPSelectImageSampleSection == section) {
        count = self.sampleImages.count;
    } else if (kHPPPSelectImagePDFSection == section) {
        count = self.pdfList.count;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Image Cell" forIndexPath:indexPath];
    if (kHPPPSelectImageDropboxSection == indexPath.section) {
        [self prepareDropboxCell:cell];
    } else if (kHPPPSelectImagePDFSection == indexPath.section) {
        HPPPPrintItem *printItem = [HPPPPrintItemFactory printItemWithAsset:[self pdfFromIndexPath:indexPath]];
        CGSize sizeInPixels = [printItem sizeInUnits:Pixels];
        CGSize sizeInInches = [printItem sizeInUnits:Inches];
        CGFloat aspectRatio = sizeInPixels.width / sizeInPixels.height;
        if (aspectRatio < 1.0f) {
            aspectRatio = sizeInPixels.height / sizeInPixels.width;
        }
        cell.textLabel.text = [self.pdfList objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f x %.0f   (%.1f\" x %.1f\", %.3f)", sizeInPixels.width, sizeInPixels.height, sizeInInches.width, sizeInInches.height, aspectRatio];
        cell.imageView.image = [UIImage imageNamed:@"pdf.png"];
    }
    else {
        UIImage *image = [self imageFromIndexPath:indexPath];
        CGFloat aspectRatio = image.size.width / image.size.height;
        if (aspectRatio < 1.0f) {
            aspectRatio = image.size.height / image.size.width;
        }
        cell.imageView.image = image;
        if (kHPPPSelectImageSampleSection == indexPath.section) {
            cell.textLabel.text = [self.sampleImages objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f x %.0f   (%.3f)", image.size.width, image.size.height, aspectRatio];
        } else {
            NSDictionary *imageInfo = [self imageInfoFromIndexPath:indexPath];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [imageInfo objectForKey:@"size"], [imageInfo objectForKey:@"orientation"]];
            cell.detailTextLabel.text = [imageInfo objectForKey:@"dpi"];
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    if (kHPPPSelectImageDropboxSection == indexPath.section) {
        [self selectItemFromDropBox];
    } else if (kHPPPSelectImagePDFSection == indexPath.section) {
        [self didSelectPrintAsset:[self pdfFromIndexPath:indexPath]];
    }
    else {
        [self didSelectPrintAsset:[self imageFromIndexPath:indexPath]];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"DROPBOX";
    if (kHPPPSelectImageSampleSection == section) {
        title = @"ADDITIONAL IMAGES";
    } else if (kHPPPSelectImagePDFSection == section) {
        title = @"PDF";
    } else if ([self imageSection:section]) {
        NSInteger sizeIndex = section - 1;
        title = [NSString stringWithFormat:@"%@ SIZE   (%@)", [self.sizeList objectAtIndex:sizeIndex], [self.aspectRatioList objectAtIndex:sizeIndex]];
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
    if ([self imageSection:indexPath.section]) {
        NSInteger sizeIndex = indexPath.section - 1;
        size = [self.sizeList objectAtIndex:sizeIndex];
        dpi = [self.dpiList objectAtIndex:indexPath.row / self.orientationList.count];
        orientation = [self.orientationList objectAtIndex:indexPath.row % self.orientationList.count];
    }
    
    return @{ @"size":size, @"dpi":dpi, @"orientation":orientation };
}

- (NSData *)pdfFromIndexPath:(NSIndexPath *)indexPath
{
    NSString *path = [[NSBundle mainBundle] pathForResource:[self.pdfList objectAtIndex:indexPath.row] ofType:@"pdf"];
    return [NSData dataWithContentsOfFile:path];
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

- (void)didSelectPrintAsset:(id)printAsset
{
    HPPPPrintItem *printItem = [HPPPPrintItemFactory printItemWithAsset:printAsset];
    if (printItem) {
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(didSelectPrintItem:)]) {
                [self.delegate didSelectPrintItem:printItem];
            }
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Unknown Item" message:@"The item selected cannot be printed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        HPPPLogWarn(@"Invalid print asset selected:  %@", printAsset);
    }
}

- (BOOL)imageSection:(NSInteger)section
{
    return section > kHPPPSelectImageDropboxSection && section < kHPPPSelectImageSampleSection;
}

#pragma mark - Dropbox

- (void)selectItemFromDropBox
{
    self.dropboxBusy = YES;
    [[DBChooser defaultChooser] openChooserForLinkType:DBChooserLinkTypeDirect fromViewController:self completion:^(NSArray *results) {
        if (results.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                DBChooserResult *result = [results firstObject];
                NSData *data = [NSData dataWithContentsOfURL:result.link];
                self.dropboxBusy = NO;
                [self didSelectPrintAsset:data];
            });
        } else {
            self.dropboxBusy = NO;
        }
    }];
}

- (void)prepareDropboxCell:(UITableViewCell *)cell
{
    cell.imageView.image = [UIImage imageNamed:@"dropbox.png"];
    if (self.dropboxBusy) {
        cell.textLabel.text = @"Loading from Dropbox...";
        cell.detailTextLabel.text = @"Please wait while file is downloaded";
    } else {
        cell.textLabel.text = @"Select from Dropbox...";
        cell.detailTextLabel.text = @"Choose an image or PDF file";
    }
}

- (void)setDropboxBusy:(BOOL)dropboxBusy
{
    _dropboxBusy = dropboxBusy;
    self.tableView.userInteractionEnabled = !dropboxBusy;
    [self.tableView reloadData];
}

@end
