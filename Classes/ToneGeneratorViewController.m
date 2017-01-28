//
//  Binaural
//
//  Created by Russell Dobda 2015.
//  Copyright 2015 Russell Dobda. All rights reserved.
//


#import "IsoGeneratorViewController.h"
#import "ToneGeneratorViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "math.h"

OSStatus RenderTone(
	void *inRefCon, 
	AudioUnitRenderActionFlags 	*ioActionFlags, 
	const AudioTimeStamp 		*inTimeStamp, 
	UInt32 						inBusNumber, 
	UInt32 						inNumberFrames, 
	AudioBufferList 			*ioData)

{

	// Get the tone parameters out of the view controller
	ToneGeneratorViewController *viewController =
		(ToneGeneratorViewController *)inRefCon;
	//double leftTheta = viewController->leftTheta;
    //double rightTheta = viewController->rightTheta;

    float left_theta_increment = 2.0f * M_PI * viewController->leftFrequency / viewController->sampleRate;
    float right_theta_increment = 2.0f * M_PI * viewController->rightFrequency / viewController->sampleRate;
    float amplitude = 0.25f * viewController->amplitude;

    
	const int leftChannel = 0;
    const int rightChannel = 1;

    Float32 *leftBuffer = (Float32 *)ioData->mBuffers[leftChannel].mData;
	
	// Generate the samples
	for (UInt32 frame = 0; frame < inNumberFrames; frame++) 
	{
		leftBuffer[frame] = sin(viewController->leftTheta) * amplitude;
		
		viewController->leftTheta += left_theta_increment;
		if (viewController->leftTheta > 2.0 * M_PI)
		{
			viewController->leftTheta -= 2.0 * M_PI;
		}
	}

    Float32 *rightBuffer = (Float32 *)ioData->mBuffers[rightChannel].mData;
    
    // Generate the samples
    for (UInt32 frame = 0; frame < inNumberFrames; frame++)
    {
        rightBuffer[frame] = sin(viewController->rightTheta) * amplitude;
        
        viewController->rightTheta += right_theta_increment;
        if (viewController->rightTheta > 2.0 * M_PI)
        {
            viewController->rightTheta -= 2.0 * M_PI;
        }
    }
    
	return noErr;
}


@implementation ToneGeneratorViewController

@synthesize amplitudeSlider;
@synthesize playButton;
@synthesize carrierLabel;
@synthesize binauralLabel;
@synthesize carrierButton;
@synthesize binauralButton;
@synthesize rightFrequencyLabel;
@synthesize leftFrequencyLabel;
@synthesize carrierFrequency;
@synthesize binauralFrequency;



-(void) ChangeFrequencies
{
    //round carrier slider to only use two decimal places
    self.carrierFrequency = roundf(self.carrierFrequency * 100) / 100;
    
    //round binaural to only use two decimal places
    self.binauralFrequency = roundf(self.binauralFrequency * 100) / 100;
    
    //check for out of range and adjust accordingly
    if (self.carrierFrequency - (self.binauralFrequency / 2) < .1)
    {
        self.carrierFrequency = (self.binauralFrequency / 2) + .1;
        self.carrierLabel.text = [NSString stringWithFormat:@"%4.2f Hz", self.carrierFrequency];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm"
                                                        message:@"Carrier was increased to accomodate Binaural Beat Frequency"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    leftFrequency = self.carrierFrequency - (self.binauralFrequency / 2);
    rightFrequency = self.carrierFrequency + (self.binauralFrequency / 2);
    amplitude = self.amplitudeSlider.value * .25;
    
    self.leftFrequencyLabel.text = [NSString stringWithFormat:@"%4.1f Hz", leftFrequency];
    self.rightFrequencyLabel.text = [NSString stringWithFormat:@"%4.1f Hz", rightFrequency];
    self.carrierLabel.text = [NSString stringWithFormat:@"%4.2f Hz", self.carrierFrequency];
    self.binauralLabel.text = [NSString stringWithFormat:@"%4.2f Hz", self.binauralFrequency];
    
}

- (IBAction)amplitudeSliderChanged:(UISlider *)slider
{
    [self ChangeFrequencies];
}


- (IBAction)carrierSliderChanged:(UISlider *)slider
{
    [self ChangeFrequencies];
}

- (IBAction)binauralSliderChanged:(UISlider *)slider
{
    [self ChangeFrequencies];
}

- (void)createToneUnit
{
	// Configure the search parameters to find the default playback output unit
	// (called the kAudioUnitSubType_RemoteIO on iOS but
	// kAudioUnitSubType_DefaultOutput on Mac OS X)
	AudioComponentDescription defaultOutputDescription;
	defaultOutputDescription.componentType = kAudioUnitType_Output;
	defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	defaultOutputDescription.componentFlags = 0;
	defaultOutputDescription.componentFlagsMask = 0;
	
	// Get the default playback output unit
	AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
	NSAssert(defaultOutput, @"Can't find default output");
	
	// Create a new unit based on this that we'll use for output
	OSErr err = AudioComponentInstanceNew(defaultOutput, &toneUnit);
	NSAssert1(toneUnit, @"Error creating unit: %ld", (long)err);
	
	// Set our tone rendering function on the unit
	AURenderCallbackStruct input;
	input.inputProc = RenderTone;
	input.inputProcRefCon = self;
	err = AudioUnitSetProperty(toneUnit, 
		kAudioUnitProperty_SetRenderCallback, 
		kAudioUnitScope_Input,
		0, 
		&input, 
		sizeof(input));
	NSAssert1(err == noErr, @"Error setting callback: %ld", (long)err);
	
	// Set the format to 32 bit, single channel, floating point, linear PCM
	const int four_bytes_per_float = 4;
	const int eight_bits_per_byte = 8;
	AudioStreamBasicDescription streamFormat;
	streamFormat.mSampleRate = sampleRate;
	streamFormat.mFormatID = kAudioFormatLinearPCM;
	streamFormat.mFormatFlags =
		kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	streamFormat.mBytesPerPacket = four_bytes_per_float;
	streamFormat.mFramesPerPacket = 1;	
	streamFormat.mBytesPerFrame = four_bytes_per_float;		
	streamFormat.mChannelsPerFrame = 2;
	streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
	err = AudioUnitSetProperty (toneUnit,
		kAudioUnitProperty_StreamFormat,
		kAudioUnitScope_Input,
		0,
		&streamFormat,
		sizeof(AudioStreamBasicDescription));
	NSAssert1(err == noErr, @"Error setting stream format: %ld", (long)err);
}

- (IBAction)linkToWeb:(UIButton *)selectedButton
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.guidedmeditationtreks.com/binaural"]];
}

- (IBAction)toggleCarrier:(UIButton *)selectedButton
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Set Carrier Frequency" message:@"Enter Carrier Frequency" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *myTextField = [alert textFieldAtIndex:0];
    myTextField.keyboardType=UIKeyboardTypeDecimalPad;
    alert.tag = 0;
    [alert show];
    [alert release];
}

- (IBAction)toggleSegue:(UIButton *)selectedButton
{
    [self doSegue];
}

-(void) doSegue
{
    [self stop];
    IsoGeneratorViewController *vc= [[IsoGeneratorViewController alloc] initWithNibName:@"IsoGeneratorViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (IBAction)toggleBinaural:(UIButton *)selectedButton
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Set Binaural Frequency" message:@"Enter Binaural Beat Frequency" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *myTextField = [alert textFieldAtIndex:0];
    myTextField.keyboardType=UIKeyboardTypeDecimalPad;
    alert.tag = 1;
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSString * inValue = [alertView textFieldAtIndex:0].text;
        float val = [inValue floatValue];
        if (alertView.tag == 0)
        {
            if (val > 0)
            {
                self.carrierFrequency = roundf(val * 100) / 100;
                [self ChangeFrequencies];
            }
        }
        else if (alertView.tag == 1)
        {
            if (val >= 0)
            {
            self.binauralFrequency = roundf(val * 100) / 100;
            [self ChangeFrequencies];
            }
        }
    }
}

- (IBAction)togglePlay:(UIButton *)selectedButton
{
    [self togglePlayTone];
}
- (void) togglePlayTone
{
    if (toneUnit)
    {
        AudioOutputUnitStop(toneUnit);
        AudioUnitUninitialize(toneUnit);
        AudioComponentInstanceDispose(toneUnit);
        toneUnit = nil;
        
        [playButton setTitle:NSLocalizedString(@"Play", nil) forState:0];
        UIImage *btnImage = [UIImage imageNamed:@"play.png"];
        [playButton setImage:btnImage forState:UIControlStateNormal];
    }
    else
    {
        [self createToneUnit];
        
        // Stop changing parameters on the unit
        OSErr err = AudioUnitInitialize(toneUnit);
        NSAssert1(err == noErr, @"Error initializing unit: %ld", (long)err);
        
        // Start playback
        err = AudioOutputUnitStart(toneUnit);
        NSAssert1(err == noErr, @"Error starting unit: %ld", (long)err);
        
        [playButton setTitle:NSLocalizedString(@"Stop", nil) forState:0];
        UIImage *btnImage = [UIImage imageNamed:@"stop.png"];
        [playButton setImage:btnImage forState:UIControlStateNormal];
    }
}

- (void)stop
{
	if (toneUnit)
	{
		[self togglePlay:playButton];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];

	sampleRate = 44100.f;
    carrierFrequency = 200;
    binauralFrequency = 8;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [self ChangeFrequencies];
    
}


@end
