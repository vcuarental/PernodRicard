/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       | External User Requests                                                             |
|     - Description     | Let the PR Employee to choose a group where added the external User                |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 27/11/2012                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
public class EXT_USR_RQT_GroupChoiceCON {
    
    /*############################################################################
    #   A.T.T.R.I.B.U.T.E.S
    ##############################################################################*/
    public ApexPages.StandardController stdController;  
    public String searchString{get;set;}
    public List<CollaborationGroup> searchResults{get;set;}
    public String uid {get;set;}
    public String soslQuery {get;set;}
    public String baseURL {get;set;}
    
    public String groupNameEncoded;
    public String groupIdSelected;
    
    public Map<Id,Integer> mapGroupID2MemberCount {get;set;}
    
    public String msg {get;set;}
    
    /*############################################################################
    #   G.E.T.T.E.R.S..A.N.D..S.E.T.T.E.R.S
    ##############################################################################*/    
    public void setGroupNameEncoded(String s) {    
        groupNameEncoded = EncodingUtil.urlEncode(s, 'UTF-8');
    }
    public String getGroupNameEncoded() {
        return groupNameEncoded;
    }
    
    public void setGroupIdSelected(String s) {    
        groupIdSelected = s;
    }
    public String getGroupIdSelected() {
        return groupIdSelected ;
    }
    
    /*############################################################################
    #   C.O.N.S.T.R.U.C.T.O.R
    ##############################################################################*/
    public EXT_USR_RQT_GroupChoiceCON(ApexPages.StandardController controller) {
        stdController = controller;
        uid = UserInfo.getUserId();
        msg = 'begin';
        groupNameEncoded = '';
        searchString = '';
        searchResults = new List<CollaborationGroup>();
        baseURL = ''+System.URL.getSalesforceBaseUrl().toExternalForm();
        
        initGroupList();
    }
    
    /*############################################################################
    #   M.E.T.H.O.D.S
    ##############################################################################*/  
    
    /*
     * Search all group where the user is a manager or the owner. 
     ***/ 
    public void initGroupList() {    
   /*     searchResults = [SELECT OwnerId, Name, Id, MemberCount,InformationTitle,InformationBody,Description, tolabel(CollaborationType), CanHaveGuests
                                FROM CollaborationGroup WHERE OwnerId = :uid AND CanHaveGuests = true AND CollaborationType = 'Private']; */
      	searchResults = [SELECT OwnerId, Name, Id, MemberCount,InformationTitle,InformationBody,Description, tolabel(CollaborationType), CanHaveGuests
                                FROM CollaborationGroup WHERE CanHaveGuests = true AND CollaborationType = 'Private' 
                                AND Id IN (SELECT CollaborationGroupId FROM CollaborationGroupMember WHERE MemberId = :uid AND CollaborationRole = 'admin')];
     
        mapGroupID2MemberCount = new Map<Id,Integer>();
        
        for(CollaborationGroup item : searchResults ) {
            mapGroupID2MemberCount.put(item.Id, item.Membercount);
        }
    }
    
    /*
     * Search group belong to the query of the user. 
     ***/ 
    public void search(){
        searchString = String.escapeSingleQuotes(searchString);
        if(searchString != '' && searchString != null) {   
            soslQuery = 'FIND {*' + searchString + '*} IN NAME FIELDS RETURNING CollaborationGroup';
            List<List<SObject>> searchList = search.query(soslQuery);
            List<CollaborationGroup> resultGroups = (List<CollaborationGroup>)searchList[0]; 
            
            if (resultGroups != null) {
                try{
                    searchResults = [SELECT OwnerId, Name, Id, MemberCount,InformationTitle,InformationBody,Description, tolabel(CollaborationType), CanHaveGuests FROM CollaborationGroup WHERE Id IN :resultGroups AND Id IN (SELECT CollaborationGroupId FROM CollaborationGroupMember WHERE MemberId = :uid AND CollaborationRole = 'admin') AND CanHaveGuests = true AND CollaborationType = 'Private'];
                    
                    if(searchResults.size()==0 ){ // No results                                   
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, Label.EXT_USR_RQT_ErrGroupNotElligible);                              
                        Apexpages.addMessage(myMsg);
                    }
                } catch (Exception ex) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getTypeName()+': '+ex.getMessage()+'. Cause :'+ex.getCause()+'.');
                        ApexPages.addMessage(myMsg);
                        msg = ' error';
                }        
            } else { // No results
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, Label.EXT_USR_RQT_ErrNoResults);                               
                Apexpages.addMessage(myMsg);
                        msg += ' no result';
            } 
        } else {
                searchResults = [SELECT OwnerId, Name, Id, MemberCount,InformationTitle,InformationBody,Description, tolabel(CollaborationType), CanHaveGuests
                                FROM CollaborationGroup WHERE CanHaveGuests = true AND CollaborationType = 'Private' 
                                AND Id IN (SELECT CollaborationGroupId FROM CollaborationGroupMember WHERE MemberId = :uid AND CollaborationRole = 'admin')];
        }
    }
    
    /*
     * Go to the create page with 2 parameters : groupID & groupName
     ***/ 
    public PageReference goToCreatePage(){
        PageReference pageResult = new PageReference('/apex/EXT_USR_RQT_CreateNewRequest?groupID='
        + groupIdSelected + '&groupName=' + groupNameEncoded + '&retURL=/apex/EXT_USR_RQT_GroupChoice'); 
        pageResult.setRedirect(true);
        return pageResult;
    }
    
    /*
     * Return to the previous screen
     ***/   
    public PageReference cancel(){
        PageReference pageResult = new PageReference(ApexPages.currentPage().getParameters().get('retURL')); 
        pageResult.setRedirect(true);
        return pageResult;
    }
}