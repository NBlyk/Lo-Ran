function root = setup_loran()
%SETUP_LORAN Register the ranging pipeline and tests without a full PHY stack.
root = fileparts(mfilename('fullpath'));
addpath(fullfile(root, 'src'));
addpath(fullfile(root, 'tests'));
addpath(fullfile(root, 'examples'));
end
