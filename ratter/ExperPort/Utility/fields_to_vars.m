function fields_to_vars(S)

if ~isstruct(S)
	warning('need struct input');
else
	fn=fieldnames(S);
	for fx=1:numel(fn)
		assignin('caller',fn{fx}, S.(fn{fx}));
	end
end
