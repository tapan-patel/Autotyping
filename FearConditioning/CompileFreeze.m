function CompileFreeze(analysis)
Ncells = length(analysis);
for i=1:Ncells
    try
    s = analysis{i};
    catch
        s = analysis(i);
    end
    vidname = s.Info.filename;
    if(~exist(vidname,'file'))
        error([vidname ' does not exist']);
        break;
    end
    try
    h = msgbox(['Gathering freezing bouts for ' vidname]);
    L = bwlabel(s.freezing_L);
    idx = find(L);
    if(~isempty(idx))
    V = mmread(vidname,idx);
    V = V(end);
    for k=1:length(idx)
        V.frames(k).cdata = imresize(rgb2gray(V.frames(k).cdata),0.3);
    end
    s.FreezeBouts = V;
    L(L==0) = [];
    s.L = L;
    [f1,f2] = fileparts(vidname);
    if(~exist([f1 '/Freeze_Bouts'],'dir'))
        mkdir([f1 '/Freeze_Bouts']);
    end
    fname = sprintf('%s/Freeze_Bouts/%s.mat',f1,f2);
    save(fname,'s','-v7.3');
    disp(['Freeze Bouts saved to ' fname]);
    end
    delete(h);
    catch
        msg = sprintf('Out of memory! Could not extract freezing bouts for %s\nYou will not be able to use the "inspect" GUI for this video.',vidname);
        msgbox(msg);
    end
end

