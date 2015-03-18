function frame = TimeToFrame(vidname,low,high,value)
% Do a binary search to return the frame number corresponding to a
% timestamp (value). Search range is from low to high - time complexity
% log2(high-low) compared to (high-low)/8 on parallel processing, serial
% search



if(high<low)
    frame = -1;
    
else
    mid = floor(low + (high-low)/2);
    V = mmread(vidname,mid);
    if((V(end).times-value)>.1)
        frame = TimeToFrame(vidname,low,mid-1,value);
        
    elseif((V(end).times-value)<-.1)
        frame = TimeToFrame(vidname,mid+1,high,value);
    else
        frame = mid;
        
    end
end
