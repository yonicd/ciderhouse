library(jsonlite)
library(magrittr)
library(reshape2)
library(dplyr)
load('gitLogs/gitLogs_old.rdata')

fields=c('Package','Type','Imports','Depends','URL','Packaged','Suggests',
         'Description','Date/Publication','Date','Publication',
         'Collate','Authors@R','Enhances','Title','ZipData','biocViews',
         'LinkingTo','Remotes','Maintainer','SystemRequirements',
         'AuthorUrl','License','LazyData','Author','Extends','RoxygenNote',
         'VignetteBuilder','swsModuleDepends','Note','Notes','Encoding',
         'Version','Recommends','Tags','AggregateMethods','AssignMethods',
         'BugReports','MailingList','BinaryFiles','Lazyload','Repository',
         'Contributors','Additional_repositories','BiocViews','RemoteSha',
         'Creator','Contents','NeedsCompilation','Roxygen','Copyright',
         'RcppModules','Requires','BuildVignettes','Additional_Repositories',
         'Archs','OS_type','ByteCompile','SystemRequirement','cache',
         'swsDatasetDepends','LazyLoad','SuggestsNote','Recommended','Authors',
         'Biarch','DependsSplus','HowToCite','License','ImportFrom','Uses',
         'Require','SystemDepends','Remote','DependsNote','LinksTo','Comment',
         'Dialect','Keywords','SystemRequirements','LazyDataCompression',
         'Log-Exceptions','BioViews')
fields=unique(fields)
fields0=paste0(sprintf('^%s: ',fields),collapse = '|')
fields1=paste0(sprintf('^%s:',fields),collapse = '|')

unlink(f)
JSONS1=rep(NA,length(JSONS))
pb <- txtProgressBar(min=1,initial = 1,max = length(JSONS),style = 3)
Ind=1:length(JSONS)
for(ind in 1:length(JSONS)){
  setTxtProgressBar(pb, ind)
  j=fromJSON(JSONS[ind])
  if(length(j[[1]])==0||ind%in%c(6616,7971,20438,24597)){
    JSONS1[ind]<-JSONS[ind]
  }else{
    fData=gsub(': NA$','',paste(names(j[[1]]),j[[1]],sep=': '))
    g0=grep("<<<<<<<",fData)
    if(length(g0)>0){
      g=grep("=======|>>>>>>>",fData)
      fData=fData[-c(g0,seq(g[1],g[2]))]
    }
    
    if(any(fData[!grepl(fields0,fData)]%in%fields)){
      m0=which(!grepl(fields0,fData))
      m1=match(fData[!grepl(fields0,fData)],fields)
      m2=m1[!is.na(m1)]
      m3=fields[m2]
      for(i in 1:length(m3)) {
        fData[m0[!is.na(m1)][i]]=gsub(m3[i],sprintf('%s:',m3[i]),fData[m0[!is.na(m1)][i]])
        }
    } 
    
    if(length(grep('^import:|^Import:',fData))==1) fData=gsub('import:|Import:','Imports:',fData)
    if(length(grep('^suggests|^Suggets:|^Suggest:',fData))==1) fData=gsub('^suggests|^Suggets:|^Suggest:','Suggests:',fData)
    if(length(grep('^Project|^IPackage|^liPackage',fData))==1) fData=gsub('^Project|IPackage|^liPackage','Package:',fData)
    if(length(grep('^Dependencies|^BuildDepends',fData))==1) fData=gsub('Dependencies|BuildDepends','Depends:',fData)
    if(length(grep('\r.[1-9]$',fData))>0) fData=gsub('\r.[1-9]','\r',fData)
    if(length(grep('\r[0-9]$',fData))>0) fData=gsub('\r[0-9]','\r',fData)
    if(length(grep('\\s+.[0-9]$',fData))>0) fData=fData[-grep('\\s+.[0-9]',fData)]
    if(length(grep('^[0-9]',fData))>0) fData=fData[-grep('^[0-9]',fData)]
    #if(length(grep('^SystemRequirements$',fData))>0) fData=fData[-grep('^SystemRequirements$',fData)]
    if(length(grep('^#',fData))>0) fData=fData[-grep('^#',fData)]
    if(length(grep('^GithubSHA1$',fData))>0) fData=fData[-grep('^GithubSHA1$',fData)]
    
    fData[which(!grepl(fields1,fData))]=sprintf('  %s',fData[which(!grepl(fields1,fData))])
    fData=fData[!grepl('^\\s+$',fData)]
        
    f=tempfile()
    cat(fData,file = f,sep = '\n')
    l<-list(as.list(as.data.frame(read.dcf(f),stringsAsFactors = FALSE)))
    names(l)=names(j)
    JSONS1[ind]<-toJSON(l)
    unlink(f)
  }
}
close(pb)

#JSONS=JSONS1
#save(JSONS,file='gitLogs/gitLogs.rdata')

#Networks

mat<-df2%>%select(Parent=value,Child=Package,Cran=ON_CRAN)%>%distinct()

smat<-mat[1:1000,1:2]
adjmat=matrix(0,nrow=length(unique(c(as.matrix(smat)))),ncol=length(unique(c(as.matrix(smat)))))
colnames(adjmat)=rownames(adjmat)=unique(c(as.matrix(smat)))

for(i in 1:length(smat[,1])){
  for(j in 1:length(smat[,2])){
    adjmat[smat[i,1],smat[j,2]]=1
  }
}

myGraph <- graph_from_adjacency_matrix(adjmat, mode = 'upper', 
                                          weighted = TRUE, diag = TRUE)
V(myGraph)$degree <- degree(myGraph)
ggraph(myGraph, 'igraph', algorithm = 'kk') + 
  geom_edge_link0(aes(width = weight), edge_alpha = 0.1) + 
  geom_node_point(aes(size = degree), colour = 'forestgreen') + 
  geom_node_text(aes(label = name, filter = degree > 600), color = 'white', 
                 size = 3) + 
  ggforce::theme_no_axes()