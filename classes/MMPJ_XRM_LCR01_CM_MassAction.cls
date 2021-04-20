public class MMPJ_XRM_LCR01_CM_MassAction {
    
    public MMPJ_XRM_LCR01_CM_MassAction(){ 
        
    }
    
    @AuraEnabled
    @testVisible 
    public static List<CampaignMember> getCampaignMembers(Id campaignId){ 
        List<CampaignMember> campaignMembers = new List<CampaignMember>();
        try{
            campaignMembers = [SELECT Id, FirstName, LastName,MMPJ_XRM_Societe__r.Id,MMPJ_XRM_Societe__r.Name, Status, MMPJ_Ext_Vign_Presence__c, MMPJ_Ext_Vign_Participation__c, contactId,MMPJ_Ext_Accompagnants__c,MMPJ_Ext_Vign_Commentaire__c,Campaign.Name, MMPJ_XRM_Date_heure_d_acceptation__c FROM CampaignMember WHERE CampaignId = :campaignId order by lastName];
            return campaignMembers;
        }
        catch(Exception e){
            System.debug(e);
            return null;
        } 
    }
    
    @AuraEnabled 
    public static Boolean majPresenceParticipationInvites (List<String> checkedCampaignMembers, String valStatus, String valPresence, String valParticipation, String valAccompagnant, String valCommentaire) {
        List<CampaignMember> cmToUpdate = new List<CampaignMember>();
        
        for(String cmId : checkedCampaignMembers){
            CampaignMember cm = new CampaignMember(Id = cmId);
            if(valStatus != 'none') {cm.Status = valStatus;}
            if(valPresence != 'none') {cm.MMPJ_Ext_Vign_Presence__c = valPresence;}
            if(valParticipation != 'none') {cm.MMPJ_Ext_Vign_Participation__c = valParticipation;}
            System.debug('### '+cm);
            System.debug(valAccompagnant);
            if(valAccompagnant !='') {cm.MMPJ_Ext_Accompagnants__c = Decimal.valueOf(valAccompagnant);}
            if(valCommentaire !='') {cm.MMPJ_Ext_Vign_Commentaire__c = valCommentaire;}
            cmToUpdate.add(cm);
        }
        
        if(cmToUpdate.size() > 0){
            try{
                update cmToUpdate;
                System.debug('## cmToUpdate : ' + cmToUpdate);
                return true;
            }
            catch(Exception e){
                System.debug('e.getMessage() : ' + e.getMessage());
                return false;
            }
        }
        else{
            return false;
        }
    }
    
    
    @AuraEnabled
    public static Boolean deleteCM_Apex (List<String> checkedCampaignMembers) {
        if(checkedCampaignMembers!= null && ! checkedCampaignMembers.isEmpty()){
            delete [SELECT id FROM CampaignMember WHERE id IN:checkedCampaignMembers]; 
            return true; 
        }
            return false; 
        /*List<CampaignMember> cmToDelete = new List<CampaignMember>();
        for(String cmId : checkedCampaignMembers){
            CampaignMember cm = new CampaignMember(Id = cmId);
            cmToDelete.add(cm);
        }
        System.debug('cmToDelete.size() : ' + cmToDelete.size());
        if(cmToDelete.size() > 0){
            try{
                delete cmToDelete;
                return true;
            }
            catch(Exception e){
                System.debug('e.getMessage() : ' + e.getMessage());
                return false;
            }
        }
        else{
            return false;
        }*/
    }
    
    @AuraEnabled 
    public static List<String> getStatusValues () {
        String statusString = Label.MMPJ_XRM_Segmentation_CampaignMember_Status;
        List<String> statusList = statusString.split(';');
        return statusList;
    }
    
    @AuraEnabled
    public static Boolean getRecordTypeMYPJCampaign (Id campaignId) {
        Boolean isMYPJCampaign = false;
	 List<Campaign> camp = [select id,name, RecordType.Developername from campaign where id= :campaignId];
        if(camp.size() > 0){
            if(camp.get(0).RecordType.Developername == 'MYPJ_Campaign'){
                system.debug('camp.get(0).RecordType.Developername : '+ camp.get(0).RecordType.Developername);
                isMYPJCampaign = true;
            }
        }
        
        return isMYPJCampaign;
    }
    
    
}