function instructions_train(wind1,rect)
%yoffset=input('yoffset ');
yoffset=30;
%instructsize=input('instructsize ');
instructsize=20;
% centerx=(rect(3)-rect(1))/2;
% centery=(rect(4)-rect(2))/2;
% xadjust=70;
%[wind1 rect] = Screen('OpenWindow',0,[100 100 175],[50 50 1700 900]);
% [wind1 rect] = Screen('OpenWindow',0,[100 100 175]);
sent1='In this experiment you will learn to assign patterns ';
sent2=' into three categories labeled A, B and C.';
sent3='The patterns are nine dots randomly positioned in different configurations.';
sent4='On each trial, a dot pattern will be presented on the screen.';
sent5='Do your best to assign it to its category ';
sent6= '  by pressing the A, B, or C key (letters on sticker) on the keyboard.';
sent7='After you make your response, ';
sent8=' the computer will tell you the correct answer.';
sent9='By paying attention to the patterns and the correct answers,';
sent10=' you should eventually learn the categories with high accuracy.';
sent11='In this first training part of the experiment, ';
sent12=' there will be a total of 270 training trials.';
sent13='After that, you will be tested on what you have learned.';
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
Screen('Flip',wind1)
WaitSecs(.5);

