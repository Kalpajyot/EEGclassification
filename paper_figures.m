clf;
% l_data = load(data);
% X = l_data.X;
X = permute(data,[2,1,3]);
[T,D,N] = size(X);
fs = 32; %sampling frequency
tiv =  1/fs; % sampling interval
time = 1000*(0:tiv:(1-tiv)); %set of the time interval
locfile = 'H:\pojects docs\BCI_classification\coord.loc';

% compute inter-trial correlation on the raw data
[~,ITCx]=corrca(X,'fixed',eye(D));

% subplot(5,3,1);
% SNRx=(ITCx+1/(N-1))./(1-ITCx)*sqrt(N);
% bar(SNRx); xlabel('EEG channels'); ylabel('SNR*\surd N')
% axis([0 D 0 3.5])

% electrodes picked 'by hand' by looking at ERP (FCz and Cz)
% [~,indx]=sort(SNRx);
% n=4; 
% channel_id = [2,3];



% find corrca components, and evalute performance on
% leave-one-out sample
for i=N:-1:1
    Xtrain = X; Xtrain(:,:,i)=[];
    [W(:,:,i),~,~,A(:,:,i)] = corrca(Xtrain,'shrinkage',0.4);
    Sign = -diag(sign(diag(inv(W(:,:,N))*W(:,:,i)))); % fix arbitrary sign
    Ytest(:,:,i) = X(:,:,i)*W(:,:,i)*Sign;
end
[~,ITCy,~,~]=corrca(Ytest,'fixed',eye(D));


% find corrca components + establish significance through
% random circular shifting
[K, p] = est_K_shift(X, 100, 0.2);
disp(['Number of significant components using circular shuffle p<0.05:' num2str(K)]);

% subplot(5,3,2);
% SNRy=(ITCy+1/(N-1))./(1-ITCx)*sqrt(N);
% bar(SNRy); hold on 
% i=K+1:D; bar(i,SNRy(i),'FaceColor',[0.75 0.75 1]);
% axis([0 D 0 3.5])
% xlabel('CorrCA components'); ylabel('SNR*\surd N ');

% Plot of channel ERP and the averaged across the CorrCA components

x=squeeze(X(:,3,:));
subplot(1,2,1); 
ploterp(x',[],250,time);
title('Trial averaged across channel Pz');
ylabel('\mu V')
xlabel('time (ms)');

y=squeeze(Ytest(:,1,:));
subplot(1,2,2);
ploterp(y',[],250,time);
title('Trial averaged across the first CorrCA component')
ylabel('\mu V')
xlabel('time (ms)');

%% Single trial across channel
figure(2)
subplot(1,2,1)
imagesc(time,[],x');
ylabel('Trials');
title('All the trials across the Channel Pz ')
colorbar
caxis([-1 1]*prctile(abs(x(:)),100))
subplot(1,2,2)
imagesc(time,[],y');
ylabel('CorrCA component for all single trials');
title('First CorrCA components of all the trials')
caxis([-1 1]*prctile(abs(y(:)),100))
colorbar


% add some helpful lines
for i=[4 5 7 8]
    subplot(5,3,i);
    ax = axis;
    hold on;
    plot([0 0], ax(3:4), 'k')
    plot([800 800], ax(3:4), 'r')
end
