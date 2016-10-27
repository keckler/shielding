clear all;
close all;

display('starting...\n');

%user values
tallyFile = './meshtal';

%shielding block coordinates
EBWF = -624.84;
EBEF = -533.40;
EBNF = 457.20;
EBSF = 0.0;

WBWF = -807.72;
WBEF = -716.28;
WBSF1 = 259.08;
WBSF2 = 624.84;
WBNF = 716.28;

shieldTop = 365.76;
shieldBottom = 0.0;

hfngWF = -624.84;
hfngEF = 0.0;
hfngNF = 1109.08;
hfngSF = 624.84;
hfngBottom = 0.0;
hfngTop = 625.16;

%wall coordinates
WO = -3683.254;
EO = 25.40;
SO = -25.40;
NO = 1854.454;
WI = -3657.854;
EI = 0.0;
SI = 0.0;
NI = 1829.054;

%floor/ceiling coordinates
BFB = -25.40;
BFT = 0.0;
BCB = 1021.08;
BCT = 1046.48;
SFCB = 1595.12;
SFCT = 1620.52;

display('reading...\n');

%read values from mcnp tally file
ft = fopen(tallyFile);
tally = textscan(ft, '%*f %f %f %f %f %*f', 'headerlines', 14); %will give [[x], [y], [z], [tally]], skipping the header
fclose(ft);

display('formatting...\n')

%reformat the data
i = 1;
while i < 4
    display(i);
    tally{i} = unique(tally{i});
    i = i + 1;
end

%normalize the tallies to the beam power


%create the meshgrid
[X, Y, Z] = meshgrid(tally{1}, tally{2}, tally{3});

%reorder values in tally{4} (tally values) as a 3D matrix
tallyMatrix = zeros(length(tally{2}), length(tally{1}), length(tally{3}));

i = 1;
while i < length(tally{1})+1
    disp(['i = ', num2str(i)]);
    j = 1;
    while j < length(tally{2})+1
        disp(['j = ', num2str(j)]);
        k = 1;
        while k < length(tally{3})+1
            %disp(['k = ', num2str(k)]);
            tallyMatrix(j, i, k) = 1000*3600*tally{4}(1); %convert from rad/s to mrad/hr and add the value to the new 3D matrix
            tally{4}(1) = []; %remove the value from the original vector
            k = k + 1;
        end
        j = j + 1;
    end
    i = i + 1;
end

display('plotting...\n')

%set the values at which contour lines should be printed
contourLineValues = [2E-2, 2E-1, 2E0];

%print the 3D map
figure('visible', 'off');
tallyMap = contourslice(X, Y, Z, log(tallyMatrix), [], [], linspace(-26, 1621, 20), log(contourLineValues));
axis([-3684 26 -26 1855 -26 1621])
xlabel('x (cm)')
ylabel('y (cm)')
zlabel('z (cm)')
title('contour of dose to human tissue from X-ray machine in scenario 2 (mrad/hr)');
colorbar('eastoutside', 'FontSize', 11, 'YTick', log(contourLineValues), 'YTickLabel', contourLineValues)
daspect([1,1,1]) %keep the aspect ratio the same on all sides
campos([0.4737E4, -1.4684E4, 1.3768E4]) %set the camera position
box on; grid on;
%set(gca, 'ydir', 'reverse') %for some strange reason the plot axes were not facing the correct ways...

%add in shielding blocks to plot
hold on;

%east shield block
fill3([EBWF, EBWF, EBWF, EBWF], [EBSF, EBNF, EBNF, EBSF], [shieldBottom, shieldBottom, shieldTop, shieldTop], 'c'); %east block, west face
fill3([EBEF, EBEF, EBEF, EBEF], [EBSF, EBNF, EBNF, EBSF], [shieldBottom, shieldBottom, shieldTop, shieldTop], 'c'); %east block, east face
fill3([EBEF, EBEF, EBWF, EBWF], [EBNF, EBNF, EBNF, EBNF], [shieldBottom, shieldTop, shieldTop, shieldBottom], 'c'); %east block, south face
fill3([EBEF, EBEF, EBWF, EBWF], [EBSF, EBSF, EBSF, EBSF], [shieldBottom, shieldTop, shieldTop, shieldBottom], 'c'); %east block, north face
fill3([EBEF, EBEF, EBWF, EBWF], [EBSF, EBNF, EBNF, EBSF], [shieldTop, shieldTop, shieldTop, shieldTop], 'c'); %east block, top
fill3([EBEF, EBEF, EBWF, EBWF], [EBSF, EBNF, EBNF, EBSF], [shieldBottom, shieldBottom, shieldBottom, shieldBottom], 'c'); %east block, bottom

%west shield block, long portion
fill3([WBWF, WBWF, WBWF, WBWF], [WBSF1, WBNF, WBNF, WBSF1], [shieldBottom, shieldBottom, shieldTop, shieldTop], 'c');
fill3([WBEF, WBEF, WBEF, WBEF], [WBSF1, WBNF, WBNF, WBSF1], [shieldBottom, shieldBottom, shieldTop, shieldTop], 'c');
fill3([WBEF, WBEF, WBWF, WBWF], [WBSF1, WBSF1, WBSF1, WBSF1], [shieldBottom, shieldTop, shieldTop, shieldBottom], 'c');
fill3([WBEF, WBEF, WBWF, WBWF], [WBNF, WBNF, WBNF, WBNF], [shieldBottom, shieldTop, shieldTop, shieldBottom], 'c');
fill3([WBEF, WBEF, WBWF, WBWF], [WBSF1, WBNF, WBNF, WBSF1], [shieldTop, shieldTop, shieldTop, shieldTop], 'c');
fill3([WBEF, WBEF, WBWF, WBWF], [WBSF1, WBNF, WBNF, WBSF1], [shieldBottom, shieldBottom, shieldBottom, shieldBottom], 'c');

%west shield block, nub
fill3([hfngWF, hfngWF, hfngWF, hfngWF], [WBSF2, WBNF, WBNF, WBSF2], [shieldBottom, shieldBottom, shieldTop, shieldTop], 'c');
fill3([WBEF, WBEF, WBEF, WBEF], [WBSF2, WBNF, WBNF, WBSF2], [shieldBottom, shieldBottom, shieldTop, shieldTop], 'c');
fill3([hfngWF, hfngWF, WBEF, WBEF], [WBSF2, WBSF2, WBSF2, WBSF2], [shieldBottom, shieldTop, shieldTop, shieldBottom], 'c');
fill3([hfngWF, hfngWF, WBEF, WBEF], [WBNF, WBNF, WBNF, WBNF], [shieldBottom, shieldTop, shieldTop, shieldBottom], 'c');
fill3([hfngWF, hfngWF, WBEF, WBEF], [WBSF2, WBNF, WBNF, WBSF2], [shieldTop, shieldTop, shieldTop, shieldTop], 'c');
fill3([hfngWF, hfngWF, WBEF, WBEF], [WBSF2, WBNF, WBNF, WBSF2], [shieldBottom, shieldBottom, shieldBottom, shieldBottom], 'c');

%hfng
fill3([hfngEF, hfngEF, hfngEF, hfngEF], [hfngSF, hfngNF, hfngNF, hfngSF], [hfngBottom, hfngBottom, hfngTop, hfngTop], 'c');
fill3([hfngWF, hfngWF, hfngWF, hfngWF], [hfngSF, hfngNF, hfngNF, hfngSF], [hfngBottom, hfngBottom, hfngTop, hfngTop], 'c');
fill3([hfngEF, hfngEF, hfngWF, hfngWF], [hfngSF, hfngSF, hfngSF, hfngSF], [hfngBottom, hfngTop, hfngTop, hfngBottom], 'c');
fill3([hfngEF, hfngEF, hfngWF, hfngWF], [hfngNF, hfngNF, hfngNF, hfngNF], [hfngBottom, hfngTop, hfngTop, hfngBottom], 'c');
fill3([hfngEF, hfngEF, hfngWF, hfngWF], [hfngSF, hfngNF, hfngNF, hfngSF], [hfngTop, hfngTop, hfngTop, hfngTop], 'c');
fill3([hfngEF, hfngEF, hfngWF, hfngWF], [hfngSF, hfngNF, hfngNF, hfngSF], [hfngBottom, hfngBottom, hfngBottom, hfngBottom], 'c');

%add in walls
w01 = fill3([WO, WO, WO, WO], [SO NO NO SO], [BFB BFB SFCT SFCT], 'c'); %outer walls
w02 = fill3([EO, EO, EO, EO], [SO NO NO SO], [BFB BFB SFCT SFCT], 'c'); %outer walls
w03 = fill3([WO EO EO WO], [SO SO SO SO], [BFB BFB SFCT SFCT], 'c'); %outer walls
w04 = fill3([WO EO EO WO], [NO NO NO NO], [BFB BFB SFCT SFCT], 'c'); %outer walls
w05 = fill3([WI, WI, WI, WI], [SI NI NI SI], [BFB BFB SFCT SFCT], 'c'); %inner walls
w06 = fill3([EI, EI, EI, EI], [SI NI NI SI], [BFB BFB SFCT SFCT], 'c'); %inner walls
w07 = fill3([WI EI EI WI], [SI SI SI SI], [BFB BFB SFCT SFCT], 'c'); %inner walls
w08 = fill3([WI EI EI WI], [NI NI NI NI], [BFB BFB SFCT SFCT], 'c'); %inner walls
w09 = fill3([WO EO EO WO], [SO SO NO NO], [BFB BFB BFB BFB], 'c'); %ceiling/floor
w10 = fill3([WO EO EO WO], [SO SO NO NO], [BFT BFT BFT BFT], 'c'); %ceiling/floor
w11 = fill3([WO EO EO WO], [SO SO NO NO], [BCB BCB BCB BCB], 'c'); %ceiling/floor
w12 = fill3([WO EO EO WO], [SO SO NO NO], [BCT BCT BCT BCT], 'c'); %ceiling/floor
w13 = fill3([WO EO EO WO], [SO SO NO NO], [SFCB SFCB SFCB SFCB], 'c'); %ceiling/floor
w14 = fill3([WO EO EO WO], [SO SO NO NO], [SFCT SFCT SFCT SFCT], 'c'); %ceiling/floor

%make walls transparent
alpha(w01, 0.05);
alpha(w02, 0.05);
alpha(w03, 0.05);
alpha(w04, 0.05);
alpha(w05, 0.05);
alpha(w06, 0.05);
alpha(w07, 0.05);
alpha(w08, 0.05);
alpha(w09, 0.05);
alpha(w10, 0.05);
alpha(w11, 0.05);
alpha(w12, 0.05);
alpha(w13, 0.05);
alpha(w14, 0.05);

display('saving...\n')

%save the figure
savefig('scenario2');
print('scenario2', '-dtiff')