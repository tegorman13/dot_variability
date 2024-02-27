%%
% training patterns generated 
%   training phase: 27 patterns (3 category) per block with different
%   patterns across blocks
%   transfer phase: 27 training patterns randomly sampled for each training block,
%     27 new high distortions, 9 low distortions,18 medium distortions,
%       and 3 prototypes 


try       
    clear all;
    Screen('Preference', 'SkipSyncTests', 1); 
    data_location=[pwd '\data\'];
    subid=input(' Subject # ');
    cond=input (' Condition # ');

    filename=[data_location 'dot_cond' num2str(cond) '_sub' num2str(subid) '.txt'];
    allvars=[data_location 'dot_cond' num2str(cond) '_sub' num2str(subid)];
    if ~exist('data','dir')
        mkdir('data')
    end
    if ~exist(filename,'file')
        fid=fopen(filename,'wt');
        s_pat=RandStream('mt19937ar','Seed','Shuffle');
        RandStream.setGlobalStream(s_pat);
        HideCursor;
        KbName('UnifyKeyNames');
        %
        % upload the training and transfer pattern
        
        % define design parameters
        ncat = 3;
        n_old = 3;
        n_newlow = 1;
        n_newmed = 1;
        n_newhigh = 1;
        n_proto = 1;
        ntrain = n_old*ncat;
        ntrans = (n_old+n_newlow+n_newmed+n_newhigh+n_proto)*ncat;
        nblocktrain= 10;
        nblocktest= 1;
%         nblocktrain=5;
%         nblocktest=1;

        % generate dot coordinates
        p1 = genDotPatterns(9, 'prototype');
        p2 = genDotPatterns(9, 'prototype');
        p3 = genDotPatterns(9, 'prototype');
        proto(1,:,:) = p1;
        proto(2,:,:) = p2;
        proto(3,:,:) = p3;
        
        n_old_tot = n_old*nblocktrain;
        switch cond
            case 1 %low distortion
                for ipat = 1:n_old_tot
                    train(1,ipat,:,:) = genDotPatterns(9, 'low', p1);
                    train(2,ipat,:,:) = genDotPatterns(9, 'low', p2);
                    train(3,ipat,:,:) = genDotPatterns(9, 'low', p3);
                    distort_old(1,ipat) = 1;
                    distort_old(2,ipat) = 1;
                    distort_old(3,ipat) = 1;
                end
            case 2 %medium distortion
                for ipat = 1:n_old_tot
                    train(1,ipat,:,:) = genDotPatterns(9, 'med', p1);
                    train(2,ipat,:,:) = genDotPatterns(9, 'med', p2);
                    train(3,ipat,:,:) = genDotPatterns(9, 'med', p3);
                    distort_old(1,ipat) = 2;
                    distort_old(2,ipat) = 2;
                    distort_old(3,ipat) = 2;
                end
            case 3 %high distortion
                for ipat = 1:n_old_tot
                    train(1,ipat,:,:) = genDotPatterns(9, 'high', p1);
                    train(2,ipat,:,:) = genDotPatterns(9, 'high', p2);
                    train(3,ipat,:,:) = genDotPatterns(9, 'high', p3);
                    distort_old(1,ipat) = 3;
                    distort_old(2,ipat) = 3;
                    distort_old(3,ipat) = 3;
                end
            case 4 %mixed distortions
                for ipat_set = 1:(n_old_tot/3)
                    ld1 = genDotPatterns(9, 'low', p1);
                    ld2 = genDotPatterns(9, 'low', p2);
                    ld3 = genDotPatterns(9, 'low', p3);
                    md1 = genDotPatterns(9, 'med', p1);
                    md2 = genDotPatterns(9, 'med', p2);
                    md3 = genDotPatterns(9, 'med', p3);
                    hd1 = genDotPatterns(9, 'high', p1);
                    hd2 = genDotPatterns(9, 'high', p2);
                    hd3 = genDotPatterns(9, 'high', p3);
                    ipats = (ipat_set-1)*3 + (1:3);
                    distort_old(1,ipats) = [1 2 3];
                    distort_old(2,ipats) = [1 2 3];
                    distort_old(3,ipats) = [1 2 3];
                    train(1,ipats,:,:) = permute(cat(3,ld1,md1,hd1),[3 1 2]);
                    train(2,ipats,:,:) = permute(cat(3,ld2,md2,hd2),[3 1 2]);
                    train(3,ipats,:,:) = permute(cat(3,ld3,md3,hd3),[3 1 2]);
                end
        end

        for ipat=1:n_newlow
            testlow(1,ipat,:,:) = genDotPatterns(9, 'low', p1);
            testlow(2,ipat,:,:) = genDotPatterns(9, 'low', p2);
            testlow(3,ipat,:,:) = genDotPatterns(9, 'low', p3);
        end

        for ipat=1:n_newmed
            testmed(1,ipat,:,:) = genDotPatterns(9, 'med', p1);
            testmed(2,ipat,:,:) = genDotPatterns(9, 'med', p2);
            testmed(3,ipat,:,:) = genDotPatterns(9, 'med', p3);
        end

        for ipat=1:n_newhigh
            testhigh(1,ipat,:,:) = genDotPatterns(9, 'high', p1);
            testhigh(2,ipat,:,:) = genDotPatterns(9, 'high', p2);
            testhigh(3,ipat,:,:) = genDotPatterns(9, 'high', p3);
        end 


        ntrial=ntrain;
        textsize=30;
        fixation_size=20;
        yoffset=100;
        yoffset2=200;
        xadjust=100;
        feedcorroffset=400;%400
        feedxnameoffset=100;%100
        feedynameoffset=50;%100
        
        %isi=input('isi (secs) ');
        %scale=input(' scale [10] ');
        %radius=input(' radius [5] ');
        isi=.5;
        scale=10;
        radius=5;
        %
        %  set up Screen and define screen-related constants
        %
        %[wind1 rect] = Screen('OpenWindow',0,[255 255 255],[50 50 1200 700]);
        [wind1 rect] = Screen('OpenWindow',0,[255 255 255]);
        
        centerx=(rect(3)-rect(1))/2;
        centery=(rect(4)-rect(2))/2;
        topscreen=rect(2)+200; % adjust the vertical position of prompt
        bottomscreen=rect(4)-20;
        %
        fixation='*';
        press_space='When Ready, Press Space to Begin ';
        endblock='End of Test Block ';
        training_end='End of Training Phase';
        thanks='Thank You, the Experiment is Over!';
        pressq='(Press ''q'' to exit)';
        prompt='Category A, B, or C?';
        prompt2='Category A, B, or C?';
        text_correct='CORRECT!';
        text_incorrect='INCORRECT';
        text_okay='OKAY';
        percentage='Percent Correct= ';
        
        catname{1}='A';
        catname{2}='B';
        catname{3}='C';
        
        Screen('TextSize',wind1,textsize);
        textbounds_thanks=Screen('TextBounds',wind1,thanks);
        textbounds_pressq=Screen('TextBounds',wind1,pressq);
        textbounds_press_space=Screen('TextBounds',wind1,press_space);
        textbounds_endblock=Screen('TextBounds',wind1,endblock);
        textbounds_training_end=Screen('TextBounds',wind1,training_end);
        textbounds_prompt=Screen('TextBounds',wind1,prompt);
        textbounds_prompt2=Screen('TextBounds',wind1,prompt2);
        textbounds_correct=Screen('TextBounds',wind1,text_correct);
        textbounds_incorrect=Screen('TextBounds',wind1,text_incorrect);
        textbounds_okay=Screen('TextBounds',wind1,text_okay);
        textbounds_percentage=Screen('TextBounds',wind1,percentage);
        
        phase_store=[];
        block_store=[];
        trial_store=[];
        itemtype_store=[];
        token_store=[];
        resp_store=[];
        correct_store=[];
        cat_store=[];
        rt_store=[];
        
        legalkeys={'r','t','y'};
        
        %%
        s_expt=RandStream('mt19937ar','Seed','Shuffle'); % randomize the order of pattern presentation
        RandStream.setGlobalStream(s_expt);
        WaitSecs(1)
        %%
        %  start of training phase of experiment
        %
        %   present instructions
        %
        instructions_train(wind1,rect);
        %
        Screen('TextSize',wind1,textsize)
        Screen('DrawText',wind1,press_space,rect(3)/2-textbounds_press_space(3)/2,rect(4)/2-textbounds_press_space(4)/2)
        Screen('Flip',wind1);
        WaitSecs(.5);
        legal=0;
        while legal == 0
            [keydown secs keycode]=KbCheck;
            key=KbName(keycode);
            if strcmp(key,'space')
                legal=1;
            end
        end
        Screen('Flip',wind1);
        WaitSecs(1);
        %
        tot_trials=0;
        itemtype=1;
        phase=1;
        %
        %  nblock blocks of ntrial training trials
        %
        for block=1:nblocktrain
            order=randperm(ntrain);
            block_correct = 0; % initialize block accuracy to 0
            for trial=1:ntrial
                tot_trials=tot_trials+1;
                istim=order(trial);
                icat=fix((istim-1)/n_old)+1; 
                token=istim-n_old*(icat-1)+n_old*(block - 1);
                distort = distort_old(icat,token);    
                for k=1:9
                    image(k,1)=train(icat,token,k,1);
                    image(k,2)=train(icat,token,k,2);
                end
                %
                %  present dot pattern and collect response
                dot_coords = repmat([centerx;centery],1,9)+scale*image';
                Screen('DrawDots',wind1,dot_coords,10,[0 0 0],[],2);
                Screen('DrawText',wind1,prompt,rect(3)/2-textbounds_prompt(3)/2,topscreen);
                Screen('Flip',wind1);
                legal=0;
                start=GetSecs;
                while legal == 0
                    [keydown secs keycode] = KbCheck;
                    key=KbName(keycode);
                    if ischar(key)
                        if any(strcmp(key,legalkeys))
                            legal=1;
                            rt=secs-start;
                        elseif strcmp(key,'q')
                            error('Debug quit!')
                        end
                    end
                end
                %
                % determine the subject's response
                %
                resp=0;
                switch key
                    case 'r'
                        resp=1;
                    case 't'
                        resp=2;
                    case 'y'
                        resp=3;
                end
                corr=0;
                if resp == icat
                    corr=1;
                end
                KbReleaseWait();
                Screen('Flip',wind1);
                
                %   present feedback while pattern remains on screen
                %
                actualname=catname{icat};
                dot_coords = repmat([centerx;centery],1,9)+scale*image';
                Screen('DrawDots',wind1,dot_coords, 10,[0 0 0],[],2);
                if corr == 1
                    Screen('DrawText',wind1,text_correct,rect(3)/2-textbounds_correct(3)/2,centery+feedcorroffset);
                else
                    Screen('DrawText',wind1,text_incorrect,rect(3)/2-textbounds_incorrect(3)/2,centery+feedcorroffset);
                end
                Screen('DrawText',wind1,actualname,centerx,centery+feedcorroffset+feedynameoffset);
                Screen('Flip',wind1);
                if corr == 1
                    block_correct = block_correct + 1;
                end
                WaitSecs(1)
                Screen('Flip',wind1);
                %%
                %record results
                tot_trials=tot_trials+1;
                phase_store(tot_trials)=phase;
                block_store(tot_trials)=block;
                trial_store(tot_trials)=trial;
                itemtype_store(tot_trials)=itemtype;
                resp_store(tot_trials)=resp;
                cat_store(tot_trials)=icat;
                rt_store(tot_trials)=rt;
                corr_store(tot_trials)=corr;
                token_store(tot_trials)=token;
                distort_store(tot_trials)=distort;
                for k=1:9
                    coord_store(tot_trials,k,1)=image(k,1);
                    coord_store(tot_trials,k,2)=image(k,2);
                end
                %%
                % write to output text file
                %
                fprintf(fid,'%5d',phase_store(tot_trials),block_store(tot_trials),trial_store(tot_trials),itemtype_store(tot_trials),...
                    cat_store(tot_trials),token_store(tot_trials),distort_store(tot_trials),...
                    resp_store(tot_trials),corr_store(tot_trials));
                fprintf(fid,'%10d',round(1000*rt_store(tot_trials)));
                for k=1:9
                    for m=1:2
                        fprintf(fid,'%5d',coord_store(tot_trials,k,m));
                    end
                end
                fprintf(fid,'\n');
                WaitSecs(isi)
            end   % trial
            block_accuracy = block_correct/ntrial; 
            acc_text = sprintf('Block Accuracy: %.2f%%', block_accuracy*100);
            textbounds_acc=Screen('TextBounds',wind1,acc_text);
            block_end_text = ['block' num2str(block) '_end'];
            textbounds_block_end=Screen('TextBounds',wind1,block_end_text);
            Screen('DrawText',wind1,block_end_text,centerx-textbounds_block_end(3)/2,centery);
            Screen('DrawText', wind1, acc_text, centerx-textbounds_acc(3)/2, centery+feedynameoffset);
            Screen('Flip', wind1);
            WaitSecs(2)
        end   %  block
        %
        Screen('DrawText',wind1,training_end,rect(3)/2-textbounds_training_end(3)/2,rect(4)/2-textbounds_training_end(4)/2)
        Screen('Flip',wind1);
        WaitSecs(2);
        %
        %  start test phase
        %
        %   present instructions
        %
        instructions_test(wind1,rect);
        %
        Screen('TextSize',wind1,textsize)
        Screen('DrawText',wind1,press_space,rect(3)/2-textbounds_press_space(3)/2,rect(4)/2-textbounds_press_space(4)/2)
        Screen('Flip',wind1);
        WaitSecs(.5);
        legal=0;
        while legal == 0
            [keydown secs keycode]=KbCheck;
            key=KbName(keycode);
            if strcmp(key,'space')
                legal=1;
            end
        end
        Screen('Flip',wind1);
        WaitSecs(1);
        
        %
        %   nblocktest blocks of ntrans test trials
        %
        phase=2;
        for block=1:nblocktest
            blockcount=0;
            blockrand_full = [repmat(1:nblocktrain,[1,2]),randperm(nblocktrain)];
            blockrand = blockrand_full(1:n_old*ncat);
            percent_correct=0;
            tot_test=0;
            order=randperm(ntrans);
            for trial=1:ntrans
                tot_trials=tot_trials+1;
                tot_test=tot_test+1;
                istim=order(trial);
                %
                % compute itemtype and construct the dot-pattern image
                %
                if istim <= (n_old*ncat)
                    itemtype=1;
                    icat=fix((istim-1)/n_old)+1;
                    blockcount=blockcount+1;
                    token=istim- n_old*(icat-1)+ n_old*(blockrand(blockcount)-1);
                    distort = distort_old(icat,token);
                    for k=1:9
                        for m=1:2
                            image(k,m)=train(icat,token,k,m);
                        end
                    end
                elseif istim >= (n_old*ncat)+1 && istim <= ((n_old+n_newlow)*ncat)
                    itemtype=3;
                    jstim=istim - (n_old*ncat);
                    icat=fix((jstim-1)/n_newlow)+1;
                    token=jstim-n_newlow*(icat-1);
                    distort = 1;
                    for k=1:9
                        for m=1:2
                            image(k,m)=testlow(icat,token,k,m);
                        end
                    end
                elseif istim >= ((n_old+n_newlow)*ncat)+1 && istim <= ((n_old+n_newlow+n_newmed)*ncat)
                    itemtype=4;
                    jstim=istim - ((n_old+n_newlow)*ncat);
                    icat=fix((jstim-1)/n_newmed)+1;
                    token=jstim-n_newmed*(icat-1);
                    distort = 2;
                    for k=1:9
                        for m=1:2
                            image(k,m)=testmed(icat,token,k,m);
                        end
                    end
                elseif istim >= ((n_old+n_newlow+n_newmed)*ncat)+1 && istim <= ((n_old+n_newlow+n_newmed+n_newhigh)*ncat)
                    itemtype=5;
                    jstim=istim - ((n_old+n_newlow+n_newmed)*ncat);
                    icat=fix((jstim-1)/n_newhigh)+1;
                    token=jstim-n_newhigh*(icat-1);
                    distort = 3;
                    for k=1:9
                        for m=1:2
                            image(k,m)=testhigh(icat,token,k,m);
                        end
                    end
                elseif istim >= ((n_old+n_newlow+n_newmed+n_newhigh)*ncat)+1 && istim <= ((n_old+n_newlow+n_newmed+n_newhigh+n_proto)*ncat)
                    itemtype=2;
                    jstim=istim - ((n_old+n_newlow+n_newmed+n_newhigh)*ncat);
                    icat=fix((jstim-1)/n_proto)+1;
                    token=0;
                    distort=0;
                    for k=1:9
                        for m=1:2
                            image(k,m)=proto(icat,k,m);
                        end
                    end
                end
                %
                % present image and prompt and collect classification response
                dot_coords = repmat([centerx;centery],1,9)+scale*image';
                Screen('DrawDots',wind1,dot_coords, 10,[0 0 0],[],2);
                Screen('DrawText',wind1,prompt2,rect(3)/2-textbounds_prompt2(3)/2,topscreen);
                Screen('Flip',wind1);
                legal=0;
                start=GetSecs;
                while legal == 0
                    [keydown secs keycode] = KbCheck;
                    key=KbName(keycode);
                    if ischar(key)
                        if any(strcmp(key,legalkeys))
                            rt=secs-start;
                            legal=1;
                        elseif strcmp(key,'q')
                            error('Debug quit!')
                        end
                    end
                end
                %%
                %
                % determine the subject's response and whether it is correct
                %
                resp=0;
                switch key
                    case 'r'
                        resp=1;
                    case 't'
                        resp=2;
                    case 'y'
                        resp=3;
                end
                corr=0;
                if resp == icat
                    corr=1;
                end
                KbReleaseWait();
                Screen('Flip',wind1);
                if corr == 1
                    percent_correct=percent_correct+1;
                end
                
                %
                %  let subject know the response was recorded
                %
                Screen('DrawText',wind1,text_okay,rect(3)/2-textbounds_okay(3)/2,centery+feedcorroffset);
                Screen('Flip',wind1);
                WaitSecs(1);
                Screen('Flip',wind1);
                %%
                % record results
                %
                tot_trials=tot_trials+1;
                phase_store(tot_trials)=phase;
                block_store(tot_trials)=block;
                trial_store(tot_trials)=trial;
                itemtype_store(tot_trials)=itemtype;
                resp_store(tot_trials)=resp;
                cat_store(tot_trials)=icat;
                rt_store(tot_trials)=rt;
                corr_store(tot_trials)=corr;
                token_store(tot_trials)=token;
                distort_store(tot_trials)=distort;
                for k=1:9
                    coord_store(tot_trials,k,1)=image(k,1);
                    coord_store(tot_trials,k,2)=image(k,2);
                end
                %%
                % write to output text file
                %
                fprintf(fid,'%5d',phase_store(tot_trials),block_store(tot_trials),trial_store(tot_trials),itemtype_store(tot_trials),...
                    cat_store(tot_trials),token_store(tot_trials),distort_store(tot_trials),...
                    resp_store(tot_trials),corr_store(tot_trials));
                fprintf(fid,'%10d',round(1000*rt_store(tot_trials)));
                for k=1:9
                    for m=1:2
                        fprintf(fid,'%5d',coord_store(tot_trials,k,m));
                    end
                end
                fprintf(fid,'\n');
                WaitSecs(isi)
            end   % trial
            percent_correct=percent_correct/tot_test;
            pcvalue=round(100*percent_correct);
            Screen('DrawText',wind1,[endblock num2str(block)],rect(3)/2-textbounds_endblock(3)/2,rect(4)/2-textbounds_endblock(4)/2)
            pcvalue_report=[percentage num2str(pcvalue)];
            Screen('DrawText',wind1,pcvalue_report,rect(3)/2-textbounds_percentage(3)/2,rect(4)/2-textbounds_percentage(4)/2+200);
            Screen('Flip',wind1);
            WaitSecs(3);
            Screen('Flip',wind1);
            WaitSecs(1);
        end   %  block
        %
        fclose(fid);
        save(allvars);
        Screen('DrawText',wind1,thanks,rect(3)/2-textbounds_thanks(3)/2,rect(4)/2-textbounds_thanks(4)/2);
        %    Screen('DrawText',wind1,pressq,rect(3)/2-textbounds_pressq(3)/2,rect(4)/2-textbounds_pressq(4)/2+50);
        Screen('Flip',wind1);
        WaitSecs(5);
        clear screen
    else
        disp('Error: the file already exists!')
    end
    
catch
    fclose('all');
    sca;
    psychrethrow(psychlasterror);
end
