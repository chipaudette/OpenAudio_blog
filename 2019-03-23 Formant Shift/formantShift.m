%
% formantShift.m
%
% Created: Chip Audette (OpenAudio), March 2019
% Purpose: Process an audio file by shifting the formants up or down
%    as desired.  This can be used to make very silly helium voice
%    or a silly deep-bass voice.  It's fun!
%
% Note that this does NOT slow down or speed up the recording.  The duration
%    and speed are the same...it shifts the formants without changing
%    the underlying pitch.  
%
% License: MIT License, use at your own risk.
%
% The processing is done in the frequency domain, so this code is complicated
%    by the need to go into and out of the frequency domain via FFT/IFFT.
%    Also, typical of frequency domain processing, it needs to be done with
%    overlapping FFT/IFFT, which complicates the program flow.  Sorry!
%
% Algorithm Outline (for this outline assume Nfft = 1024 and block_size = 128
%    * Load full audio file
%    * Break up full audio file into blocks for block-wise processing
%        * The blocks (128 points) are shorter than the full FFT 
%          length (1024 points), which means that the current block must be
%          joined with previous blocks to get the full FFT.  This is how we
%          get the overlapping FFTs and IFFTs
%
%    * For each audio block (128 points):
%        * Join with a few previous audio blocks to get full FFT (1024 points)
%        * Apply a hanning window to the 1024-point audio
%        * Compute the FFT, which results in a complex 1024-point vector with
%              both the positive and negative frequency space
%        * Do the formant shifting by stepping through each frequency bin
%             * For the current bin, change its amplitude (but not its phase!)
%               to match the amplitude at a lower bin (if shifting formants up)
%               or at a higher bin (if shifting formants down)
%        * Compute the Inverse FFT (IFFT) to convert back to the time domain
%        * Apply another hanning window to reduce bad artifacts in the signal
%        * Do the overlap-and-add with previous results to build up your
%             output audio
%

%load audio
infname = 'my_voice.wav';
disp(['reading ' infname]);
[full_wav,sample_rate_Hz]=audioread(infname);
full_wav = full_wav(:,1); %if stereo, use just the left channel
full_wav = full_wav - mean(full_wav);  %remove any DC bias

%set the desired FFT parameters
Nfft=1024;  %for audio sampled at 44.1kHz, use 1024 or 512
block_size=Nfft/8;  %use either Nfft/8 (better) or Nfft/4 (good enough)
N_2 = Nfft / 2 + 1;  %nyquist bin
Nblocks_per_FFT = Nfft/block_size; %how many blocks are needed to do an FFT?
Nblocks_all = length(full_wav)/block_size; %how many blocks are in the full audio file?
hann_win = hanning(Nfft); %hanning window
    
%choose the range of formant shifting to try.  
%values less than 1.0 will shift formants downward.
%values greater than 1.0 will shift formants upward.
all_formant_scale_fac = [0.65 0.85 1.0 1.5 2.0]; %1.0 is no shifting.

%loop over a range of formant shifting values
for Iscale = 1:length(all_formant_scale_fac)
    formant_scale_fac = all_formant_scale_fac(Iscale);
    
    %initialize some variables
    all_blocks_in=zeros(block_size,Nblocks_per_FFT);
    out_full_wav = zeros(size(full_wav));

    %loop over each data block
    for Iblock=1:Nblocks_all
        inds = (Iblock-1)*block_size+[1:block_size]; %indices into the full audio array
        wav = full_wav(inds,:); %grab the audio for this block
        
        %shift stored blocks and add new data
        all_blocks_in(:,1:Nblocks_per_FFT-1) = all_blocks_in(:,2:Nblocks_per_FFT);
        all_blocks_in(:,Nblocks_per_FFT) = wav;
        
        %do big FFT
        foo_wav = all_blocks_in(:); %turn all blocks into a single data vector
        foo_wav = foo_wav(:).*hann_win(:); %apply windowing function to the audio
        fft_wav = fft(foo_wav);  %compute the FFT
        
        %% begin the formant shifting algorithm!!!
        
        %compute the magnitude for each FFT bin and store somewhere safe
        orig_mag = abs(fft_wav);
        
        %now, step throug each bin and compute the new magnitude based on 
        %shifting the formants.  Only step through the positive freqeuency
        %space.  We'll build the negative freuqency space later.
        for dest_ind = (1+1):N_2  %start on the 2nd bin (ie, skip over the DC bin)
            %In formant shifting, you shift the amplitude values (not phase 
            %values!) of the FFT bins up or down.  You do NOT shift them
            %by a fixed number of bins, but you shift them proportional to
            %their frequency.  So, if you count from zero (Matlab counts
            %from 1), shifting the formants upward by a factor of 2.0 results
            %in:  source_ind = dest_ind / formant_scale_fac;
            %
            %   dest_ind = 1  ->  source_ind = 0.5;   %if counting bins from zero
            %   dest_ind = 2  ->  source_ind = 1.0;   %if counting bins from zero
            %   dest_ind = 3  ->  source_ind = 1.5;   %if counting bins from zero
            %   dist_ind = 4  ->  source_ind = 2.0;   %if counting bins from zero
            %
            %Because Matlab counts from 1, the logic gets a little more complicated
            
            %what is the source bin for the new magnitude for this current destination bin
            source_ind_float = ((dest_ind-1) / formant_scale_fac) + 1 + 0.5;  
            
            %since source_ind_float is likely pointing between bins, let's
            %interpolate to get the amplitude at that between-bin location.
            source_ind = floor(source_ind_float); %the bin below our interpolation point
            source_ind = min(max(1+1, source_ind), (N_2 - 2 + 1)); % limit the lowest and highest values it can be
            interp_fac = max(0.0, source_ind_float - source_ind); %this will be used in the interpolation in a few lines

            % OK, now we're ready to compute the FFT magnitude to insert
            % into our destination bin
            
            %interpolate in the original magnitude vector to find the new magnitude that we want
            %new_mag=orig_mag[source_ind];  %the magnitude that we desire
            %scale = new_mag / orig_mag[dest_ind];%compute the scale factor
            new_mag = orig_mag(source_ind);
            new_mag = new_mag+ interp_fac * (orig_mag(source_ind) - orig_mag(source_ind + 1));
            scale = new_mag / orig_mag(dest_ind);

            %apply scale factor to the magnitude (which is a multiplication 
            %of both the real part and the imaginary part.  The key is to 
            %NOT change the phase of the value, just change the magnitude!
            fft_wav(dest_ind) = fft_wav(dest_ind)*scale;

        end
        
        %% formant shifting algorithm is done.  Now we "just" need to convert
        %  back to the time domain, including all of the overlap-and-add complication
        
        %rebuild the negative frequency space to reflect our changes to the
        %positive frequency space.  For a real signal, the negative frequency
        %space is the complex conjugate of the postivie space.  The DC bin and
        %the nyquist bin are not repeated in the negative frequency space.
        fft_wav(end:-1:(N_2+1)) = conj(fft_wav(2:(N_2)-1)); %for a re
        
        %compute inverse fft
        foo_wav = real(ifft(fft_wav));
        
        %window again...maybe makes it sound a little better?
        foo_wav = foo_wav(:).*hann_win(:);
    
        % do the overlap and add with previous results to build up the
        % output vector
        inds = (Iblock-1)*block_size+[1:length(foo_wav)];
        if inds(end) <= length(out_full_wav)
            out_full_wav(inds) = out_full_wav(inds) + foo_wav;
        end
    end
    
    % because of the overlap-and-add, the amplitude of the output signal
    % will be larger than it started.  So, let's normalize that out.
    
    % normalize amplitudes
    norm_fac = std(full_wav)/std(out_full_wav);
    %disp(['Normlizing volume by ' num2str(20*log10(norm_fac)) ' dB']);
    out_full_wav = out_full_wav * std(full_wav)/std(out_full_wav);
    
    % save the new audio file
    outfname = [infname(1:end-4) '_formatScaled_' sprintf('%4.2f',formant_scale_fac) '.wav'];
    disp(['writing audio to ' outfname]);
    audiowrite(outfname,out_full_wav,sample_rate_Hz);
    
end

disp(['Go forth and listen to the saved audio files!'])

%% plots
figure;
subplot(2,1,1);
t_sec = ([1:length(full_wav)]-1)/sample_rate_Hz;
plot(t_sec(1:10:end),full_wav(1:10:end));
xlabel('Time (sec)');
ylim([-1 1]);

subplot(2,1,2);
t_sec = ([1:length(out_full_wav)]-1)/sample_rate_Hz;
plot(t_sec(1:10:end),out_full_wav(1:10:end));
xlabel('Time (sec)');
ylim([-1 1]);

