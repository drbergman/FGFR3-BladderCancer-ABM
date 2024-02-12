function identifier = setIdentifier(root)

identifier = string(datetime("now","Format","yyMMddHHmm")); % default to this for determining an id if none given

while exist(sprintf("%s/%s",root,identifier),"dir") % just in case this directory already exists somehow (not sure how to processes could start at the same time to the millisecond and then one create this folder before the other looks for it)
    identifier = string(datetime("now","Format","yyMMddHHmmss")); % default to this for determining an id if none given
end
