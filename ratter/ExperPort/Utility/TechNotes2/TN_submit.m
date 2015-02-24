function handles = TN_submit(handles)

dstr = get(handles.date_text,'string');
tstr = datestr(now,13);

initials = lower(get(handles.initials_edit,'string'));
note = get(handles.note_edit,'string');
if isempty(note); return; end
if get(handles.rat_button,'value') == 1
    
    for i = 1:length(handles.active);
        ratname = handles.active{i};
        mym(bdata,['INSERT INTO ratinfo.technotes (datestr, timestr, ratname, techinitials, note)',...
                   ' values ("{S}","{S}","{S}","{S}","{S}")'],dstr,tstr,ratname,initials,note);
    end
    
elseif get(handles.rig_button,'value') == 1 || get(handles.tower_button,'value') == 1
    
    for i = 1:length(handles.active);
        R = handles.active{i};
        if ischar(R); R(R == ',') = ' '; R = str2num(R); end %#ok<ST2NM>
        
        for r = 1:length(R);
            mym(bdata,['INSERT INTO ratinfo.technotes (datestr, timestr, rigid, techinitials, note)',...
                       ' values ("{S}","{S}","{S}","{S}","{S}")'],dstr,tstr,R(r),initials,note);
        end
    end
    
elseif get(handles.session_button,'value') == 1
    
    for i = 1:length(handles.active);
        S = handles.active{i};
        mym(bdata,['INSERT INTO ratinfo.technotes (datestr, timestr, timeslot, techinitials, note)',...
                   ' values ("{S}","{S}","{S}","{S}","{S}")'],dstr,tstr,S,initials,note);
    end
    
elseif get(handles.experimenter_button,'value') == 1
    
    for i = 1:length(handles.active);
        EXP = handles.active{i};
        mym(bdata,['INSERT INTO ratinfo.technotes (datestr, timestr, experimenter, techinitials, note)',...
                   ' values ("{S}","{S}","{S}","{S}","{S}")'],dstr,tstr,EXP,initials,note);
    end
    
else
    mym(bdata,['INSERT INTO ratinfo.technotes (datestr, timestr, techinitials, note)',...
               ' values ("{S}","{S}","{S}","{S}")'],dstr,tstr,initials,note);
end

set(handles.submit_button,'enable','off');