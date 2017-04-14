#'@export
setwd.url=function(path){
  r.script=readLines(path)
  r.file=basename(path)
  urlPath=gsub(r.file,'',path)
  url.loc=gsub('master(.*?)$','',path)
  dat.loc=gsub(paste0(url.loc,'master/'),'',urlPath)
  r.script=gsub('\\s+','',r.script)
  r.script=r.script[!grepl('^#',r.script)]
  r.script=r.script[nchar(r.script)>0]
  yInd=grep('read|source',r.script)
  y=grep('read|source',r.script,value=T)
  str.old=stringr::str_extract(y,'\\"(.*?)\\"')
  str.change=basename(gsub('[\\"]','',str.old))
  
  if(grepl('source',y)){ 
    newScript=sprintf("list2env(runGit(urlPath,'%s',flag=F),envir = environment())",str.change)
  }else{
    newScript=mapply(function(x,str.old){
      str.new=paste0("'",dat.loc,str.change,"'")
      file.name=gsub(' ','',strsplit(x,'<-|=')[[1]][1])
      eval(parse(text=paste0(file.name,' <<- tempfile()')))
      eval(parse(text=sprintf("download.file('%s%s,%s,quiet = T,method='curl')",urlPath,basename(str.new),file.name)))
      gsub(str.old,file.name,x)      
    },x=y,str.old=str.old,USE.NAMES = F)
    
  }
  
  r.script[yInd]=newScript
}