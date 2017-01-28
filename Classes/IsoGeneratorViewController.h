//
//  Binaural
//
//  Created by Russell Dobda 2015.
//  Copyright 2015 Russell Dobda. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AudioUnit/AudioUnit.h>

@interface IsoGeneratorViewController : UIViewController
{
	UILabel *carrierLabel;
    UILabel *binauralLabel;

    UIButton *carrierButton;
    UIButton *binauralButton;
    
    UIButton *playButton;
    
    AudioComponentInstance toneUnit;

    NSTimer *isoTimer;
    
    //float carrierFreq, binauralFreq;

    
@public
	float monoFrequency;
    int frame;
    bool isOn;
    
    int sampleRate;
	float monoTheta;
    int multiplier;
    float amplitude;
    //int sampleDifferenceCompensation;
}

@property (nonatomic) float carrierFrequency;
@property (nonatomic) float binauralFrequency;


@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *carrierButton;
@property (nonatomic, retain) IBOutlet UIButton *binauralButton;

@property (nonatomic, retain) IBOutlet UILabel *carrierLabel;
@property (nonatomic, retain) IBOutlet UILabel *binauralLabel;

- (IBAction)togglePlay:(UIButton *)selectedButton;
- (IBAction)linkToWeb:(UIButton *)selectedButton;
- (IBAction)toggleCarrier:(UIButton *)selectedButton;
- (IBAction)toggleBinaural:(UIButton *)selectedButton;
- (IBAction)toggleSegue:(UIButton *)selectedButton;

- (void)stop;

@end

