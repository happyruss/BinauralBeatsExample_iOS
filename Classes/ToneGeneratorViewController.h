//
//  Binaural
//
//  Created by Russell Dobda 2015.
//  Copyright 2015 Russell Dobda. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AudioUnit/AudioUnit.h>

@interface ToneGeneratorViewController : UIViewController
{
	UILabel *carrierLabel;
    UILabel *binauralLabel;

    UIButton *carrierButton;
    UIButton *binauralButton;
    
    UILabel *leftFrequencyLabel;
    UILabel *rightFrequencyLabel;
    
    UIButton *playButton;
    
    AudioComponentInstance toneUnit;

    //float carrierFreq, binauralFreq;
    
    
@public
	float leftFrequency;
    float rightFrequency;
    float amplitude;

    float sampleRate;
	float rightTheta;
    float leftTheta;
}

@property (nonatomic, retain) IBOutlet UISlider *amplitudeSlider;

@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *carrierButton;
@property (nonatomic, retain) IBOutlet UIButton *binauralButton;

@property (nonatomic, retain) IBOutlet UILabel *carrierLabel;
@property (nonatomic, retain) IBOutlet UILabel *binauralLabel;
@property (nonatomic, retain) IBOutlet UILabel *leftFrequencyLabel;
@property (nonatomic, retain) IBOutlet UILabel *rightFrequencyLabel;

@property (nonatomic) float carrierFrequency;
@property (nonatomic) float binauralFrequency;

- (IBAction)amplitudeSliderChanged:(UISlider *)amplitudeSlider;
- (IBAction)togglePlay:(UIButton *)selectedButton;
- (IBAction)linkToWeb:(UIButton *)selectedButton;
- (IBAction)toggleCarrier:(UIButton *)selectedButton;
- (IBAction)toggleBinaural:(UIButton *)selectedButton;
- (IBAction)toggleSegue:(UIButton *)selectedButton;

- (void)stop;

@end

