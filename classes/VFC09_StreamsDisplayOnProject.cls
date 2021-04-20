/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       | External User Requests                                                             |
|     - Description     | Display streams and its sub-streams of a project.                                  |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 18/12/2012                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
public class VFC09_StreamsDisplayOnProject {
        
    /*############################################################################
    #   A.T.T.R.I.B.U.T.E.S
    ##############################################################################*/
    public ESNProject__c currProject {get;set;}
    
    public Map<Id,List<ESNStream__c>> streamParent2Child_map {get;set;}
    public Map<Id,ESNStream__c> streamId2Stream_map {get;set;}
    public List<ESNStream__c> streamParents_list {get;set;}
    public List<ESNStream__c> projectMilestones_list {get;set;}

    public String msg {get;set;}
    public Boolean displayTab {get;set;}
    public Boolean hasChild {get;set;}
    
    /*############################################################################
    #   C.O.N.S.T.R.U.C.T.O.R
    ##############################################################################*/
    public VFC09_StreamsDisplayOnProject(ApexPages.StandardController controller) {
        streamParent2Child_map = new Map<Id,List<ESNStream__c>>();
        streamParents_list = new List<ESNStream__c>();
        
        currProject = (ESNProject__c)controller.getRecord();
        msg = '';
        displayTab = true;
        hasChild = true;
                
        List<ESNStream__c> listStreamsFULL = [SELECT ParentStream__r.Name,ESN_Type__c,ESN_ActualStartDate__c,ESN_ActualEndDate__c,ParentStream__r.Id, ESN_SituationText__c ,ParentStream__r.ParentStream__c ,EndDate__c,Id,Name,ParentStream__c,Project__c,Situation__c,StartDate__c,Status__c,StreamLeader__r.Name,StreamLeader__c 
                                                        FROM ESNStream__c WHERE RecordType.DeveloperName = 'ESN_Stream' AND Project__c = :currProject.Id ORDER BY ESN_ActualStartDate__c,StreamLeader__r.Name];
              
        projectMilestones_list = [SELECT ParentStream__r.Name,ESN_Type__c,ParentStream__r.Id, ESN_ActualDeadline__c ,ESN_SituationText__c , ParentStream__r.ParentStream__c ,EndDate__c,Id,Name,ParentStream__c,Project__c,Situation__c,StartDate__c,Status__c,StreamLeader__r.Name,StreamLeader__c 
                                                        FROM ESNStream__c WHERE RecordType.DeveloperName = 'ESN_Milestone' AND Project__c = :currProject.Id ORDER BY ESN_ActualDeadline__c,StreamLeader__r.Name];
        System.debug('####### '+listStreamsFULL);
        if(listStreamsFULL.size() == 0 && projectMilestones_list.size() == 0)
            hasChild = false;
            
        buildRelationStreamParent2Child(listStreamsFULL);
        streamParents_list.sort();
    }
    
    /*############################################################################
    #   M.E.T.H.O.D.S
    ##############################################################################*/
    
    /*
     * Build a map to get a list child stream per parent stream.
     *  - Key : parent stream Id
     *  - Value : list of its child streams
     ***/ 
    public void buildRelationStreamParent2Child(List<ESNStream__c> listStreams){
        streamId2Stream_map = new Map<Id,ESNStream__c>(listStreams);
        
        for(ESNStream__c var : listStreams){  
            if(var.ParentStream__c == null){    // Parent Stream
                if(!streamParent2Child_map.containsKey(var.Id)){
                    streamParent2Child_map = addParent2Map(streamParent2Child_map, var);
                }
            } else {    // Child Stream
                if(streamParent2Child_map.containsKey(var.ParentStream__c)){
                    streamParent2Child_map = addChild2Map(streamParent2Child_map, var, var.ParentStream__c);
                } else {
                    if(var.ParentStream__r.ParentStream__c == null){
                        streamParent2Child_map = addParent2Map(streamParent2Child_map, streamId2Stream_map.get(var.ParentStream__c));
                        streamParent2Child_map = addChild2Map(streamParent2Child_map, var, var.ParentStream__c);                    
                    }
                }
            }
        }
    }
        
    /*
     * Add a parent stream to the map in parameters.
     ***/ 
    public Map<Id,List<ESNStream__c>> addParent2Map(Map<Id,List<ESNStream__c>> currmap, ESNStream__c parent){
        streamParents_list.add(parent);
          
        List<ESNStream__c> listChild = new List<ESNStream__c>();
        listChild.add(parent);
        
        currmap.put(parent.Id, listChild);
        
        return currmap;
    }
    
    /*
     * Add a child stream to the map in parameters.
     ***/ 
    public Map<Id,List<ESNStream__c>> addChild2Map(Map<Id,List<ESNStream__c>> currmap, ESNStream__c child, Id parentId){
        List<ESNStream__c> listChild = currmap.get(parentId);
        listChild.add(child);
        
        currmap.put(parentId, listChild);
        
        return currmap;
    }
}