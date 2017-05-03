function falff( ts )
 %% FALFF - fractional amplitude of low-frequency fluctuation
 %  * https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3902859/#S2title
 %  * 1s TR == 1HZ => nyquist is .5Hz)

 %%  ALFF 
 % The time series for each voxel was transformed to the frequency domain 
 % and the power spectrum was then obtained. Since the power of a given 
 % frequency is proportional to the square of the amplitude of this frequency
 % component, the square root was calculated at each frequency of the power 
 % spectrum and the averaged square root was obtained across 0.01–0.08 Hz 
 % at each voxel.  This averaged square root was taken as the ALFF.
 %
 % In the current work, the individual data was transformed to Z score 
 % (i.e., minus the global mean value and then divided by the standard 
 % deviation) other than simply being divided by the global mean. 
 
 %%  fALFF 
 % To improve the original ALFF approach, a ratio of the power of each
 % frequency at the low-frequency range (0.01–0.08 Hz) to that of the
 % entire frequency range (0–0.25 Hz), i.e., fractional ALFF (fALFF) was
 % used (Fig. 2c). The procedure of data analysis of fALFF was similar to
 % Section 2.4 mentioned above. After the linear trend was removed, the time
 % series for each voxel were transformed to a frequency domain without
 % band-pass filtering. The square root was calculated at each frequency of
 % the power spectrum. The sum of amplitude across 0.01–0.08 Hz was divided
 % by that across the entire frequency range, i.e., 0–0.25 Hz. Further
 % procedures were the same as in Section 2.4.

 %%
end

