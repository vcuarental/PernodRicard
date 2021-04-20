public without sharing class ESNProjectTriggerHandler {
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public ESNProjectTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public ESNProject__Share createESNProjectShare(String projectID, String contribID){
        system.debug('#### create contrib :'+contribID +' on project '+projectID);
        ESNProject__Share contrib = new ESNProject__Share();                
        contrib.ParentId = projectID;                               // Set the ID of record being shared
        contrib.AccessLevel = 'edit';                                   // Set the access level
        contrib.RowCause = Schema.ESNProject__Share.RowCause.Manual;    // Set the Apex sharing reason for hiring manager and recruiter         
        contrib.UserOrGroupId = contribID;
        System.debug('#### create new pshare : parentID='+contrib.ParentId+' userId='+contrib.UserOrGroupId);
        return  contrib;
    }
    
    public void deleteESNProjectShare(String projectID, String contribID){
        system.debug('#### delete contrib :'+contribID +' on project '+projectID);
        List<ESNProject__Share> listProjectShare = [SELECT Id, ParentId FROM ESNProject__Share WHERE ParentId = :projectID AND UserOrGroupId = :contribID];
        if(listProjectShare.size() != 0){
            delete listProjectShare.get(0);
        }
    }
    
    public Database.SaveResult[] OnAfterInsert(ESNProject__c[] newESNProjects){     
        System.debug('#### begin after insert ');
        // Create a new list of sharing objects for ESNProject     
        List<ESNProject__Share> allContribShrs  = new List<ESNProject__Share>();
                
        for(ESNProject__c projectNEW : newESNProjects){
            // Project Manager
            if(projectNEW.ProjectManager__c != null && projectNEW.ProjectManager__c != projectNEW.OwnerId){
                System.debug('#### project manager :' + projectNEW.ProjectManager__c);
                allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.ProjectManager__c)); }
            // Sponsor
            if(projectNEW.Sponsor__c != null && projectNEW.Sponsor__c != projectNEW.OwnerId)
                allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.Sponsor__c));
            // Contributor 1
            if(projectNEW.Contributor_1__c != null && projectNEW.Contributor_1__c != projectNEW.OwnerId)
                allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.Contributor_1__c));
            // Contributor 2
            if(projectNEW.Contributor_2__c != null && projectNEW.Contributor_2__c != projectNEW.OwnerId)
                allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.Contributor_2__c));
            // Contributor 3
            if(projectNEW.Contributor_3__c != null && projectNEW.Contributor_3__c != projectNEW.OwnerId)
                allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.Contributor_3__c));
            // Contributor 4
            if(projectNEW.Contributor_4__c != null && projectNEW.Contributor_4__c != projectNEW.OwnerId)
                allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.Contributor_4__c));
            // Contributor 5
            if(projectNEW.Contributor_5__c != null && projectNEW.Contributor_5__c != projectNEW.OwnerId)
                allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.Contributor_5__c));
            // Contributor 6
            if(projectNEW.Contributor_6__c != null && projectNEW.Contributor_6__c != projectNEW.OwnerId)
                allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.Contributor_6__c));
            // Contributor 7
            if(projectNEW.Contributor_7__c != null && projectNEW.Contributor_7__c != projectNEW.OwnerId)
                allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.Contributor_7__c));
            // Contributor 8
            if(projectNEW.Contributor_8__c != null && projectNEW.Contributor_8__c != projectNEW.OwnerId)
                allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.Contributor_8__c));
            // Contributor 9
            if(projectNEW.Contributor_9__c != null && projectNEW.Contributor_9__c != projectNEW.OwnerId)
                allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.Contributor_9__c));
            // Contributor 10
            if(projectNEW.Contributor_10__c != null && projectNEW.Contributor_10__c != projectNEW.OwnerId)
                allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.Contributor_10__c));
        }
        
        // Insert sharing records and capture save result
        // The false parameter allows for partial processing if multiple records are passed
        // into the operation
        return Database.insert(allContribShrs,true);
    }
    
    public Database.SaveResult[] OnBeforeUpdate(ESNProject__c[] oldESNProjects, ESNProject__c[] updatedESNProjects, Map<ID, ESNProject__c> ESNProjectMap){
        // Save the last version of the project. 
        ESNProject__c projectNEW = updatedESNProjects.get(updatedESNProjects.size()-1);        

        // Create a new list of sharing objects for ESNProject     
        List<ESNProject__Share> allContribShrs  = new List<ESNProject__Share>();
        
        for(ESNProject__c projectOLD : oldESNProjects){
            // Project Manager
            if(projectOLD.ProjectManager__c != projectNEW.ProjectManager__c && projectOLD.ProjectManager__c != projectNEW.OwnerId){
                deleteESNProjectShare(projectOLD.Id, projectOLD.ProjectManager__c);
                if(projectNEW.ProjectManager__c != null && projectNEW.ProjectManager__c != projectNEW.OwnerId){
                    createESNProjectShare(projectNEW.Id, projectNEW.ProjectManager__c);
                    allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.ProjectManager__c));
                }
            }
            // Sponsor
            if(projectOLD.Sponsor__c != projectNEW.Sponsor__c && projectOLD.Sponsor__c != projectNEW.OwnerId){
                deleteESNProjectShare(projectOLD.Id, projectOLD.Sponsor__c);
                if(projectNEW.Sponsor__c != null && projectNEW.Sponsor__c != projectNEW.OwnerId){
                    createESNProjectShare(projectNEW.Id, projectNEW.Sponsor__c);
                    allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.Sponsor__c));
                }
            }
            // Contributor 1
            if(projectOLD.Contributor_1__c != projectNEW.Contributor_1__c && projectOLD.Contributor_1__c != projectNEW.OwnerId){
                deleteESNProjectShare(projectOLD.Id, projectOLD.Contributor_1__c);
                if(projectNEW.Contributor_1__c != null && projectNEW.Contributor_1__c != projectNEW.OwnerId){
                    createESNProjectShare(projectNEW.Id, projectNEW.Contributor_1__c);
                    allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.Contributor_1__c));
                }
            }
            // Contributor 2
            if(projectOLD.Contributor_2__c != projectNEW.Contributor_2__c && projectOLD.Contributor_2__c != projectNEW.OwnerId){
                deleteESNProjectShare(projectOLD.Id, projectOLD.Contributor_2__c);
                if(projectNEW.Contributor_2__c != null && projectNEW.Contributor_2__c != projectNEW.OwnerId){
                    createESNProjectShare(projectNEW.Id, projectNEW.Contributor_2__c);
                    allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.Contributor_2__c));
                }
            }
            // Contributor 3
            if(projectOLD.Contributor_3__c != projectNEW.Contributor_3__c && projectOLD.Contributor_3__c != projectNEW.OwnerId){
                deleteESNProjectShare(projectOLD.Id, projectOLD.Contributor_3__c);
                if(projectNEW.Contributor_3__c != null && projectNEW.Contributor_3__c != projectNEW.OwnerId){
                    createESNProjectShare(projectNEW.Id, projectNEW.Contributor_3__c);
                    allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.Contributor_3__c));
                }
            }
            // Contributor 4
            if(projectOLD.Contributor_4__c != projectNEW.Contributor_4__c && projectOLD.Contributor_4__c != projectNEW.OwnerId){
                deleteESNProjectShare(projectOLD.Id, projectOLD.Contributor_4__c);
                if(projectNEW.Contributor_4__c != null && projectNEW.Contributor_4__c != projectNEW.OwnerId){
                    createESNProjectShare(projectNEW.Id, projectNEW.Contributor_4__c);
                    allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.Contributor_4__c));
                }
            }
            // Contributor 5
            if(projectOLD.Contributor_5__c != projectNEW.Contributor_5__c && projectOLD.Contributor_5__c != projectNEW.OwnerId){
                deleteESNProjectShare(projectOLD.Id, projectOLD.Contributor_5__c);
                if(projectNEW.Contributor_5__c != null && projectNEW.Contributor_5__c != projectNEW.OwnerId){
                    createESNProjectShare(projectNEW.Id, projectNEW.Contributor_5__c);
                    allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.Contributor_5__c));
                }
            }
            // Contributor 6
            if(projectOLD.Contributor_6__c != projectNEW.Contributor_6__c && projectOLD.Contributor_6__c != projectNEW.OwnerId){
                deleteESNProjectShare(projectOLD.Id, projectOLD.Contributor_6__c);
                if(projectNEW.Contributor_6__c != null && projectNEW.Contributor_6__c != projectNEW.OwnerId){
                    createESNProjectShare(projectNEW.Id, projectNEW.Contributor_6__c);
                    allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.Contributor_6__c));
                }
            }
            // Contributor 7
            if(projectOLD.Contributor_7__c != projectNEW.Contributor_7__c && projectOLD.Contributor_7__c != projectNEW.OwnerId){
                deleteESNProjectShare(projectOLD.Id, projectOLD.Contributor_7__c);
                if(projectNEW.Contributor_7__c != null && projectNEW.Contributor_7__c != projectNEW.OwnerId){
                    createESNProjectShare(projectNEW.Id, projectNEW.Contributor_7__c);
                    allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.Contributor_7__c));
                }
            }
            // Contributor 8
            if(projectOLD.Contributor_8__c != projectNEW.Contributor_8__c && projectOLD.Contributor_8__c != projectNEW.OwnerId){
                deleteESNProjectShare(projectOLD.Id, projectOLD.Contributor_8__c);
                if(projectNEW.Contributor_8__c != null && projectNEW.Contributor_8__c != projectNEW.OwnerId){
                    createESNProjectShare(projectNEW.Id, projectNEW.Contributor_8__c);
                    allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.Contributor_8__c));
                }
            }
            // Contributor 9
            if(projectOLD.Contributor_9__c != projectNEW.Contributor_9__c && projectOLD.Contributor_9__c != projectNEW.OwnerId){
                deleteESNProjectShare(projectOLD.Id, projectOLD.Contributor_9__c);
                if(projectNEW.Contributor_9__c != null && projectNEW.Contributor_9__c != projectNEW.OwnerId){
                    createESNProjectShare(projectNEW.Id, projectNEW.Contributor_9__c);
                    allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.Contributor_9__c));
                }
            }
            // Contributor 10
            if(projectOLD.Contributor_10__c != projectNEW.Contributor_10__c && projectOLD.Contributor_10__c != projectNEW.OwnerId){
                deleteESNProjectShare(projectOLD.Id, projectOLD.Contributor_10__c);
                if(projectNEW.Contributor_10__c != null && projectNEW.Contributor_10__c != projectNEW.OwnerId){
                    createESNProjectShare(projectNEW.Id, projectNEW.Contributor_10__c);
                    allContribShrs.add(createESNProjectShare(projectNEW.Id, projectNEW.Contributor_10__c));
                }
            }
        }
        return Database.insert(allContribShrs,true);
    }
    
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
    
    public boolean IsVisualforcePageContext{
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsWebServiceContext{
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsExecuteAnonymousContext{
        get{ return !IsTriggerContext;}
    }
}