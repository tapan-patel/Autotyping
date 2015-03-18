
function P = Parse_FNames(FNames, Tag)

switch Tag
    
    case 'Folder'
        P = FNames{1,1};
        
    case 'Threshold'
        P = FNames{1,2};
        

    otherwise
        disp('*** Parse_FNames unrecognized Tag');
        P = [];
end
