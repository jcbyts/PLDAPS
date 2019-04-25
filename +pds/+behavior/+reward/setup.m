function p = setup(p)

% 
% 
%  s.newEraSyringePump.use      = true;
%  s.newEraSyringePump.port     = '/dev/cu.usbserial';
%  s.newEraSyringePump.diameter = 19.05;
%  s.newEraSyringePump.rate     = 10;
%  s.newEraSyringePump.vol      = 0.005;
 
if p.trial.newEraSyringePump.use % create an @newera object for delivering liquid reward
    p.trial.reward = marmoview.newera(p.trial.newEraSyringePump);
    %     'port', p.trial.newEraSyringePump.port, ...
    %         'diameter',p.trial.newEraSyringePump.diameter,...
    %         'volume',p.trial.newEraSyringePump.volume,'rate',...
    %         p.trial.newEraSyringePump.rate);
else % no syringe pump? use the @dbgreward object object instead
    p.trial.reward = marmoview.dbgreward(p);
end

% 
% %pds.behavior.reward.setup(p)    setup reward systems before the experiment
% % This is mostly a wrapper to the other reward modules.
%     pds.newEraSyringePump.setup(p);

%allocate memory in case reward is given during pause
p.trial.behavior.reward.iReward     = 1; % counter for reward times
p.trial.behavior.reward.timeReward  = nan(2,15);

% match functionality of standard trial setup & cleanup to prevent extraneous empty fields in saved data struct (see reward.cleanupandsave )
p.trial.behavior.reward.timeReward(isnan(p.trial.behavior.reward.timeReward))=[];