function [val] = ReadJSON(Name)

% Name = 'example.json'

fname = Name; 
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
val = jsondecode(str);

end

