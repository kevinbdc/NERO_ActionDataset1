%% Coleta gestos em tempo real Kinect XBox One


clear; close all;clc
addpath('Mex');
imaqreset;
k2 = Kin2('color','depth','body');
%% Importando rede Neural

AAA=load('RedeCompletaTKBLJSub15FPS2');
net=AAA.net;
%% Variáveis
%Variáveis do teste online
NumeroTestes=30;
NumeroGestos=14;
ListaAmostra=[];
MConfusao=zeros(14,14);
% Juntas selecionadas
Juntas=[5:12];
% Caso queira subamostrar
XX = 1:9:150;
YY = 2:9:150;  
ZZ = 3:9:150;
Subamostra = [XX YY ZZ];
Subamostra = sort(Subamostra);

TempoGesto = 1.7;% Tempo (1.7) de cada gesto +- 150 colunas, 50 frames
intervalo = 2*0.035;
c = 75;
skeletonAloca = zeros(25,c);
skeleton = []; 
% Flag:
% 0 - Mão não foi aberta
% 1 - Mão foi aberta, pode classificar
flag = 0;
%% Nomes

NomesGestos = ['Gesto A - Tchau com mão direita','Gesto B - Itau',...
    'Gesto C - Águia média com mão direita', 'Gesto D - T médio com mão direita',...
    'Gesto E - Tchau com mão esquerda', 'Gesto F - Power rangers',...
    'Gesto G - T médio com mão esquerda','Gesto H - Águia média com mão esquerda',...
    'Gesto I - Pare','Gesto J - Sirva-me','Gesto K - Vem','Fica Parado','Gira','Andando'];
% Com o todos os gestos
% Indicies = [1,31,32,45,46,82,83,115,116,147,148,170,171,204,205,242,243,256,257,274,275,287,288,299,288,299,288,299];
% Sem o B
% Indicies = [1,31,46,82,83,15,116,147,148,170,171,204,205,242,243,256,257,274,275,287,288,299,288,299,288,299];
% Especifica os nadas
% Indicies = [1,31,32,45,46,82,83,115,116,147,148,170,171,204,205,242,243,256,257,274,275,287,288,298,299,302,303,309];
% Sem o gira
% Indicies = [1,31,32,45,46,82,83,115,116,147,148,170,171,204,205,242,243,256,257,274,275,287,288,298,303,309];
% Sem Sirva-me,parado e girando
% Indicies = [1,31,32,45,46,82,83,115,116,147,148,170,171,204,205,242,243,256,275,287,303,309];
% Tirando os Ts e o Gira
Indicies = [1,31,32,45,46,82,116,147,148,170,205,242,243,256,257,274,275,287,288,298,303,309];
%% Inicia e altera as propriedades do Kinect
 
% % colorVid = videoinput('kinect',1);
% depthVid = videoinput('kinect',2);
% set(depthVid,'FramesAcquiredFcnCount',1)
% % set(depthVid,'TimerPeriod',0.1)
% % set(depthVid,'TimerFcn','TriggerFunction')
%
% set(depthVid,'FramesAcquiredFcn','TriggerFunction')
%
% % Trigger
% triggerconfig (depthVid,'manual');
% framesPerTrig = 200;
% depthVid.FramesPerTrigger = framesPerTrig;
% depthVid.TriggerRepeat = inf;
%
% % Propriedades do kinect
% prop = getselectedsource(depthVid);
% prop.EnableBodyTracking = 'on';
% start(depthVid)
%% Organiza para plotar

SkeletonConnectionMap = [ [4 3];  % Neck
    [3 21]; % Head
    [21 2]; % Right Leg
    [2 1];
    [21 9];
    [9 10];  % Hip
    [10 11];
    [11 12]; % Left Leg
    [12 24];
    [12 25];
    [21 5];  % Spine
    [5 6];
    [6 7];   % Left Hand
    [7 8];
    [8 22];
    [8 23];
    [1 17];
    [17 18];
    [18 19];  % Right Hand
    [19 20];
    [1 13];
    [13 14];
    [14 15];
    [15 16];
    ];
%% Coleta de gestos online

% trigger(depthVid);
h = figure;
pause
% pause(2)
tc = tic;
%% Criar lista para poder classificar online o experimento 
% Vai criar a lista pra ter um numero fixo de pedidos para cada gesto de
% forma aleatória

% for k=1:NumeroGestos
%    ListaAmostra=[ListaAmostra k*ones(1,NumeroTestes)]; 
% end
%Randomizando a Lsita
% ListaAmostra=ListaAmostra(randperm(numel(ListaAmostra)));
% save('Thinassi','ListaAmostra');

% load('Kevin');
%% Inicio de Classificação
% for ii=1:length(ListaAmostra)% Tira 1 frame
    %% A cada 60 para
%     if mod(ii,60)==0
%         disp('CALMA')
%         MConfusao
%         save(['Workspace',num2str(ii)])
%         pause
%         pause(5)
%     end
%% continua
    while ishandle(h);
        tic
        if toc(tc)>intervalo
    %         tic;
    %% Anuncio do gesto
%             if flag~=1
%                 Anuncio=[NomesGestos(Indicies(2*ListaAmostra(ii)-1):Indicies(2*ListaAmostra(ii)))];
%                 disp(Anuncio)
%             end
%% Continua
           
            tc=tic;
            validData = k2.updateData;
           
            while validData ~= 1
                validData = k2.updateData;
            end
            if validData
                
                [bodies, fcp, timeStamp] = k2.getBodies('Quat');
                numBodies = size(bodies,2);
                %disp(['Bodies Detected: ' num2str(numBodies)])

                % Example of how to extract information from getBodies output.
                if numBodies > 0
                    %% Extraindo juntas:

                    skeletonJoints=bodies.Position';
                    %% Plotar as juntas

                    try
                        delete(h)
                    end
                    h = plot(skeletonJoints(:,1), skeletonJoints(:,2),'.','MarkerSize',15); % Plota no imshow as juntas
                    axis([-2.1 2.1 -2.1 2.1])
                    drawnow;
                    %% Refina a entrada

    %                 Gestos = skeletonAloca(Juntas,:);
    %                 Hip_Center_Gesto = Gestos(1,:); % Pega o x,y,z dos esqueletos
    %                 Gestos = Gestos - (ones(length(Juntas),1) * Hip_Center_Gesto); % Centraliza
    %                 Gestos_Quadrado = Gestos*Gestos'; % Transforma [Gestos] em quadrada, multiplica ela pela transposta
    %                 AVSample = eig(Gestos_Quadrado);
                    %% Teste de gatilho

    %                 Gatilho:
    %                 Se a mão esquerda ou a direita estiver fechada, classifica
    %                 0 unknown
    %                 1 not tracked
    %                 2 open
    %                 3 closed
    %                 4 lasso
    %                 Teste de confiança:
    %                 HandLeftConfidence, HandRightConfidence
    %                 0 low
    %                 1 high
                    %% Verifica se as juntas da mão são confiáveis e muda a flag de gatilho

                    if sum(bodies.TrackingState([22:25]))==8% Verifica se as mãos estão confiáveis
                        if bodies.LeftHandState== 2 ||  bodies.RightHandState == 2% Verifica se a mao ta aberta
                           flag = 1;
                        end
                    end
                    %% Verifica a flag e armazena o gesto

                    if flag == 1
                       skeleton = [skeleton skeletonJoints];                   
                       if size(skeleton,2) == c
                           %% Refina a entrada
%                             tic
                           Gestos = skeleton(Juntas,:);
    %                        Gestos = Gestos(:,Subamostra);
                           Hip_Center_Gesto = Gestos(1,:); % Pega o x,y,z dos esqueletos
                           Gestos = Gestos - (ones(length(Juntas),1) * Hip_Center_Gesto); % Centraliza
                           Gestos_Quadrado = Gestos*Gestos'; % Transforma [Gestos] em quadrada, multiplica ela pela transposta
                           AVSample = eig(Gestos_Quadrado);
                           %% Classifica
                           Saida = net(AVSample);
%                             toc
                           [~,pos] = max(Saida)                       
                           flag = 0; % Retorna flag ao estado normal
                           skeleton=[]; % Reseta o esqueleto
%                            pause(1)
                           Classificado = [NomesGestos(Indicies(2*pos-1):Indicies(2*pos))];
                           disp(Classificado)
                           toc
                           pause(0.5)
                           %% Preencher matriz de Confusão
%                            MConfusao(pos,ListaAmostra(ii))=MConfusao(pos,ListaAmostra(ii))+1;
%                            break;
                       end
                    end
                            %% Classificação

    %                         Se o gatilho funcionar, classifica

    %                         Saida = net(AVSample)
    %                         toc
    %                         [~,pos] = max(Saida);
    %                         disp(['Classificou como: ',num2str(pos)])

                end
            end
        end
        
    end
% end
% save('MConfusão','MConfusão');