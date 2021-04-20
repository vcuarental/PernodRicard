public class MMPJ_XRM_Create_contact_ctrl {
    public Contact con{get;set;}
    public MMPJ_Ext_Vign_Societe__c societe{get;set;}
    public MMPJ_Ext_Vign_Societe_Contact__c societeContact{get;set;}
    public String error_message;
    
    public MMPJ_XRM_Create_contact_ctrl(ApexPages.StandardController ctrl){
        String societeId = ApexPages.currentPage().getParameters().get('Idsociete');
        societe = [SELECT Id,Name From MMPJ_Ext_Vign_Societe__c Where Id =: societeId];
        this.con = (Contact)ctrl.getRecord();
        Id rtId = [SELECT Id from RecordType where SobjectType='Contact' and DeveloperName='MMPJ_Ext_Vign_Contact' LIMIT 1].Id;
        con.RecordTypeId = rtId;
        societeContact = new MMPJ_Ext_Vign_Societe_Contact__c();
    }
    
    public PageReference doSaveToContact(){
        return Sauvegarde(true);
    }
    
    public PageReference doSaveAndReturn(){
        return Sauvegarde(false);
    }
    
    public PageReference doAnnuler(){
        PageReference pageRef = new PageReference('/'+societe.Id);          
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    private PageReference Sauvegarde(Boolean isSaveAndCreate) {
        Savepoint sp = Database.setSavepoint();
        try {
            insert con;
            societeContact.MMPJ_Ext_Vign_Contact__c = con.Id;
            societeContact.MMPJ_Ext_Vign_Societe__c = societe.Id;
            societeContact.MMPJ_Ext_Vign_SocietContact_Segmentation__c = con.MMPJ_Ext_Vign_Contact_Segmentation__c;
            insert societeContact;
            PageReference pageRef;
            if(isSaveAndCreate)
                 pageRef = new PageReference('/'+con.Id+'/e?retURL=/'+con.id);
            else
                 pageRef = new PageReference('/'+societe.Id);
            
            pageRef.setRedirect(true);
            return pageRef;
        } catch (Exception e) {
            Database.rollback(sp);
            con.Id = null;
            ApexPages.addMessages(e);
            return null;
        }
    }
}