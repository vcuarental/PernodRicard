public with sharing class VFC98_StreamsDisplay {
        
    public ESNProject__c currProject {get;set;}
    
    public Map<Id,List<ESNStream__c>> streamParent2Child_map {get;set;}
    public Map<Id,ESNStream__c> streamId2Stream_map {get;set;}
    public List<ESNStream__c> streamParents_list {get;set;}
    
    
    public String msg {get;set;}
    public Boolean displayTab {get;set;}
    
    public VFC98_StreamsDisplay(ApexPages.StandardController controller) {
        currProject = (ESNProject__c)controller.getRecord();
        msg = '';
        displayTab = true;
                
        List<ESNStream__c> listStreamsFULL = [SELECT ParentStream__r.Name,ParentStream__r.Id ,EndDate__c,Id,Name,ParentStream__c,Project__c,Situation__c,StartDate__c,Status__c,StreamLeader__c 
                                                        FROM ESNStream__c WHERE Project__c = :currProject.Id OR ParentStream__r.Project__c = :currProject.Id];
       
        buildMapStreamID2Stream(listStreamsFULL);
        buildRelationStreamParent2Child(listStreamsFULL);
        streamParents_list.sort();
    }
    
    public void buildMapStreamID2Stream(List<ESNStream__c> listStreams){
        streamId2Stream_map = new Map<Id,ESNStream__c>();
        
        for(ESNStream__c item : listStreams)
            streamId2Stream_map.put(item.Id, item);            
    }
    
    public void buildRelationStreamParent2Child(List<ESNStream__c> listStreams){
        streamParent2Child_map = new Map<Id,List<ESNStream__c>>();
        streamParents_list = new List<ESNStream__c>();
                
        for(ESNStream__c var : listStreams){  
            if(var.ParentStream__c == null){    // Parent Stream
                if(!streamParent2Child_map.containsKey(var.Id)){
                    streamParent2Child_map = addParent2Map(streamParent2Child_map, var);
                }
            } else {    // Child Stream
                if(streamParent2Child_map.containsKey(var.ParentStream__c)){
                    streamParent2Child_map = addChild2Map(streamParent2Child_map, var, var.ParentStream__c);
                } else {
                    streamParent2Child_map = addParent2Map(streamParent2Child_map, streamId2Stream_map.get(var.ParentStream__c));
                    streamParent2Child_map = addChild2Map(streamParent2Child_map, var, var.ParentStream__c);                    
                }
            }
        }
    }
    
    public Map<Id,List<ESNStream__c>> addParent2Map(Map<Id,List<ESNStream__c>> currmap, ESNStream__c parent){
        streamParents_list.add(parent);
          
        List<ESNStream__c> listChild = new List<ESNStream__c>();
        listChild.add(parent);
        
        currmap.put(parent.Id, listChild);

        msg += ' add a parent ('+parent.Name+' / '+parent.Id+').\n';
        
        return currmap;
    }
    
    public Map<Id,List<ESNStream__c>> addChild2Map(Map<Id,List<ESNStream__c>> currmap, ESNStream__c child, Id parentId){
        List<ESNStream__c> listChild = currmap.get(parentId);
                    
        listChild.add(child);
        
        currmap.put(parentId, listChild);
        
        msg += ' add a child to this parent ('+parentId+').';
        return currmap;
    }

}