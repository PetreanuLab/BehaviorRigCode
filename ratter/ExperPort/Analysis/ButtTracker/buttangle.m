function buttangle(moviename,ratname,dstr,varargin)

%
% buttangle(ratname,dstr,varargin)
%

pairs={...
  'framerate',      [];
  'ffmpeg_options', '';
  };
parseargs(varargin,pairs);

if ~iscell(moviename), moviename={moviename}; end
if ~iscell(ratname),   ratname={ratname};     end
if ~iscell(dstr),      dstr={dstr};           end
if isempty(framerate), fr_string=[]; 
else fr_string=[' -r ' sprintf('%d',framerate) ' ']; 
end

for k=1:numel(moviename)
    disp(repmat('~',1,80));
    disp(['Fitting rat ' ratname{k} ' on ' dstr{k} '.']);
    try
        system(['ffmpeg -i ' moviename{k} ' ' ffmpeg_options ' -vframes 1 -an -v 0 -y tmp.jpg']);
        homedir=get_path(fullpath(moviename{k}));
        omoviename=[homedir ratname{k} '_' dstr{k} '.avi'];
        img=imread('tmp.jpg');
        wdth=size(img,2);
        hght=size(img,1);
        clear img
        system('rm tmp.jpg');
        divisor=ceil(wdth/100);
        wdth=round(wdth/divisor);
        hght=round(hght/divisor);
        if mod(wdth,2)~=0, wdth=wdth+1; end
        if mod(hght,2)~=0, hght=hght+1; end
        % transcode movie
        fprintf('%s ---------------- TRANSCODING',char(37))
        system(['ffmpeg -i ' moviename{k} ' -s ' sprintf('%d',wdth) 'x' sprintf('%d',hght) ...
          ' ' ffmpeg_options ' -an -g 2 -v 0 -y ' fr_string omoviename]);
        % create movieframes object
        obj=MovieFrames(omoviename);
        % now collect a background frame
        fprintf('%s ---------------- ESTIMATING BACKGROUND',char(37))
        obj.EstimateBackground(500,true);
%         pos=obj.EstimatePosition('frameinds',1:30000);
%         obj.RecalculateBackground(1:30000);
        for irbg=1:3
            [boxvals,frameinds]=obj.EstimateBoxPDF('dthresh',90,'usebright',true,'nframes',2000);
            obj.RecalculateBackground(boxvals);
        end
        % estimate time alignment
        fprintf('%s ---------------- SYNCHING MOVIE',char(37))
        [bv,~,bvt]=obj.BlockPixels(1:15000,'blocksize',[8 8]);
        sessid=bdata('select sessid from sessions where ratname="{S}" and sessiondate="{S}"',ratname{k},dstr{k});
        peh=get_peh(sessid);
        [protocol pd]=bdata('select protocol,protocol_data from sessions where sessid="{S}"',sprintf('%d',sessid));
        [state_name,delay,lrfieldname]=water_deliverer(protocol,ratname{k},datestr(datenum(dstr{k},'yyyymmdd'),'yyyy-mm-dd'),peh);
        obj.AlignMovie(bv,bvt,peh,pd{1},state_name,'delay',delay,'lrfieldname',lrfieldname);
        % perform fit
        fprintf('%s ---------------- FITTING MOVIE',char(37))
        obj.Fit
        % put data on sql server
        fprintf('%s ---------------- UPDATING DATABASE',char(37))
        bdata('connect','sonnabend.princeton.edu','jkjun','THELm0nk')
        bdata(['insert into jkjun.butt_tracking ' ...
          '(sessid, ts      , phi      , x           , y           , length      , width       , t0    ) values' ...
          '("{Si}", "{M}"   , "{M}"    , "{M}"       , "{M}"       , "{M}"       , "{M}"       , "{Sn}")'],      ...
            sessid, obj.Time, obj.Angle, obj.Pos(1,:), obj.Pos(2,:), obj.Axs(1,:), obj.Axs(2,:), obj.T0);
    catch exception
        disp(exception.message)
        disp(['Skipping ' ratname{k} ' on ' dstr{k} '.']);
    end
    disp(repmat('~',1,80));
end
