function p = give(p, amount)
%pds.behavior.reward.give(p, amount)    give a certaim amount of reward
% handles reward for newEraSyringePumps and via TTL over datapixx. Also
% send a reward bit via datapixx (if datapixx is used).
% stores the time and amount in p.trial.behavior.reward.timeReward
% If no amount is specified, the value set in
% p.trial.behavior.reward.defaultAmount will be used

if nargin < 2
    amount = p.trial.behavior.reward.defaultAmount;
end


pds.newEraSyringePump.give(p,amount);
if p.trial.newEraSyringePump.use
    if nargin <2 %repeat last given Volume
        IOPort('Write', p.trial.newEraSyringePump.h, ['RUN' p.trial.newEraSyringePump.commandSeparator],0);
    elseif amount>=0.001 && amount<=9999
        %             IOPort('Write', p.trial.newEraSyringePump.h, ['VOL ' num2str(amount) p.trial.newEraSyringePump.commandSeparator],0);
        %             IOPort('Write', p.trial.newEraSyringePump.h, ['RUN' p.trial.newEraSyringePump.commandSeparator],0);
        IOPort('Write', p.trial.newEraSyringePump.h, ['VOL ' sprintf('%*.*f', ceil(log10(amount)), min(3-ceil(log10(amount)),3),amount) p.trial.newEraSyringePump.commandSeparator 'RUN' p.trial.newEraSyringePump.commandSeparator],0);
    end
end
    

if p.trial.datapixx.use
    if  p.trial.datapixx.useForReward
        pds.datapixx.analogOut(amount);
    end
    %%flag
    pds.datapixx.flipBit(p.trial.event.REWARD,p.trial.pldaps.iTrial);
end


%%sound
if p.trial.sound.use && p.trial.sound.useForReward
    PsychPortAudio('Stop', p.trial.sound.reward);
    PsychPortAudio('Start', p.trial.sound.reward);
end


%% store data
if p.trial.behavior.reward.iReward==1%~isfield(p.trial.behavior.reward, 'iReward')
    p.trial.behavior.reward.timeReward = [GetSecs; amount];
else
    p.trial.behavior.reward.timeReward(:,p.trial.behavior.reward.iReward) = [GetSecs amount];
end
p.trial.behavior.reward.iReward = p.trial.behavior.reward.iReward + 1;

