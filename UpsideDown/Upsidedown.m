%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                           UpsideDown.m                                 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function takes an audio signal of your chosing and reverses the low %
% and high frequency content. There's no other way of putting this other   %
% than the fact that anything you put through here probably won't sound    %
% good. That said, I'd reccomend inputting a sample, flipping it, applying %
% an effect to the sample and then flipping it back. If you use something  %
% like distortion or reverb that introduces new sounds/harmonics and then  %
% flip them, you can get some really interesting results.                  %
%                                                                          %
% At somepoint, if I can work out how to make this work using a circular   %
% buffer and do this in real-time, I'll make a .vst3/.au. For now have     %                                                           %                                                    
% fun with this.                                                           %
%                                                                          %
% Written: 22/11/24                                                        %
% Author: TSX514                                                           %
% Email: tsx514@york.ac.uk                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Boilerplate

inputFile = "YOUR_FILENAME_HERE.wav"; 

% Turning the frequency spectrum upside down also reverses the audio. Think
% like how a hotwheels care going around a loop faces backwards when it's
% upside down. This function reverses the output at the end so it's playing
% forward. However, if you don't want that, change reverse to 0

reverse = 1;

% This will also grab the sample rate
[input, fs] = audioread(inputFile);
[numSamples, numChannels] = size(input);

% Init the empty processed audio matrix/vector
processedAudio = [];

% Stereo / mono?

if numChannels == 1
    processedAudio = flipFrequencies(input);
else
    % Runs L/R channels separately 
    leftChannel = flipFrequencies(input(:, 1));
    rightChannel = flipFrequencies(input(:, 2));
    % Then smashes them back together
    processedAudio = [leftChannel, rightChannel];
end

function flippedAudio = flipFrequencies(audio)

    % Apply FFT to the input signal
    inputFFT = fft(audio);
    
    % Create the frequency flip
    n = length(inputFFT);
    half_n = floor(n/2);
    
    % Goes ahead and seperates the low to mid frequncies (positive) and the mid to high
    % frequencies (negative) to invert. Basically abusing the nyquist
    % frequency to to ensure that when we flip it back, it makes sense in the
    % time domain.

    positiveFreq = inputFFT(1:half_n);   
    negativeFreq = inputFFT(half_n+1:end); 
    
    % Flip the low to mid frequencies using matlaps flipud function which
    % inverts arrays, and then combine flipped frequencies together into
    % $flippedFFT. The flipped positive frequencies will be a mirror
    % of the negative
    
    flippedFFT = [flipud(positiveFreq); flipud(negativeFreq)];
    
    % Then we do an inverse FFT to get it back into the time domain.
    flippedAudio = ifft(flippedFFT, 'symmetric');

end

% Display the spectrogram of the original + flipped audio

figure;
subplot(2, 1, 1);
if numChannels == 1
    spectrogram(input, 1024, 512, 1024, fs, 'yaxis'); % Mono
else
    % Mono's the stereo signal for the purposes of displaying a spectrogram
    spectrogram(mean(input, 2), 1024, 512, 1024, fs, 'yaxis'); 
end
title('Original Audio Spectrogram');

subplot(2, 1, 2);
if numChannels == 1
    spectrogram(processedAudio, 1024, 512, 1024, fs, 'yaxis'); % 
else
    spectrogram(mean(processedAudio, 2), 1024, 512, 1024, fs, 'yaxis'); 
end
title('Frequency-Flipped Audio Spectrogram');


% SAVE!

if reverse == 1
    audiowrite("flipped_" + inputFile, flipud(processedAudio), fs);
else
    audiowrite("flipped_" + inputFile, processedAudio, fs);
end

% Uncomment this if you want the result to play in MATLAB
%soundsc(processedAudio,fs);


