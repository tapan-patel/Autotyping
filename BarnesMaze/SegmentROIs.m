function BW = SegmentROIs(I,L)

global BW;

roiwindow = CROIEditor(I,L); drawnow;

while(roiwindow.isvalid & isempty(roiwindow.number))
    pause(1)
    
    if(roiwindow.isvalid & roiwindow.number)
        break
    end
end
if(roiwindow.isvalid)
    BW = roiwindow.getROIData;
    delete(roiwindow);
end