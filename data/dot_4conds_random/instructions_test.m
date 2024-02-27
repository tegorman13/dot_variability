function instructions_test(wind1,rect)
%yoffset=input('yoffset ');
yoffset=30;
%instructsize=input('instructsize ');
instructsize=20;
% centerx=(rect(3)-rect(1))/2;
% centery=(rect(4)-rect(2))/2;
% xadjust=70;
%[wind1 rect] = Screen('OpenWindow',0,[100 100 175],[50 50 1700 900]);
% [wind1 rect] = Screen('OpenWindow',0,[100 100 175]);
sent1='You will now start the final test phase of the experiment. ';
sent2='In this phase, you will be assigning patterns to the same categories as before.';
sent3='There will be old patterns that you saw during the training phase';
sent4=' and also new patterns that you did not see during the training phase.';
sent5='For each pattern, press the A, B or C key to indicate its category';
sent6='In this phase, the computer will not tell you whether or not ';
sent7='  your answer was correct.';
sent8='Instead, the computer will just say ''Okay''';
sent9=' to let you know it recorded your response.';
sent10='However, it will tell you your overall percent correct ';
sent11=' at the end of the test.';
sent12='This final test phase of the experiment ';
sent13=' has 87 trials.';
sentlast=' PRESS SPACE TO CONTINUE';
blank=' ';
sentence={sent1 sent2 sent3 sent4 sent5 sent6 sent7 sent8 sent9 sent10 sent11 sent12 sent13 sentlast};
Screen('TextSize',wind1,instructsize);
textbounds_sentlast=Screen('Textbounds',wind1,sentlast);

for i=1:13
    Screen('DrawText',wind1,sentence{i},50,1000-(21-i)*yoffset-400)
end
Screen('DrawText',wind1,sentlast,rect(3)/2-textbounds_sentlast(3)/2,rect(4)-50)
Screen('Flip',wind1)
%%
%      user presses space when ready to start
%
legal=0;
while legal == 0
    [keydown secs keycode]=KbCheck;
    key=KbName(keycode);
    if strcmp(key,'space')
        legal=1;
    end
end
Screen('Flip',wind1);
WaitSecs(.5);

