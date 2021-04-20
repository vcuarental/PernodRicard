public class MMPJ_XRM_FicheRapportPernodController {
    //Getters & Setters
    public static MMPJ_Ext_Vign_Societe__c societe{get;set;}
    public MMPJ_Ext_Vign_Societe_Contact__c societeContact{get;set;}
    
   /*** Constructeur ***/

    public MMPJ_XRM_FicheRapportPernodController(ApexPages.StandardController controller){
        societe = (MMPJ_Ext_Vign_Societe__c) controller.getRecord();
        //titre du pdf téléchargé
        Apexpages.currentPage().getHeaders().put('content-disposition', 'filename='+societe.Name+'_'+Date.Today().format()+'.pdf');
        System.debug('societe');
    }
    
    //Récupère les Factures
    public List<MMPJ_Ext_Vign_Facture__c> getFactures(){
        System.debug('societe');
        return [select id,MMPJ_Ext_Vign_Societe__r.Name,Name,MMPJ_Ext_Vign_Date_de_Facturation__c,MMPJ_Ext_Vign_Facture_Nette__c,MMPJ_Ext_Vign_Date_de_virement_banque__c from MMPJ_Ext_Vign_Facture__c where MMPJ_Ext_Vign_Societe__c=:societe.Id order by MMPJ_Ext_Vign_Date_de_Facturation__c desc LIMIT 5];
    }
    
    //Récupère les Contacts
    public List<MMPJ_Ext_Vign_Societe_Contact__c> getContact(){
        return [select Id,MMPJ_Ext_Vign_Contact__r.FirstName,MMPJ_Ext_Vign_Contact__r.LastName,MMPJ_Ext_Vign_Contact__r.MMPJ_Ext_Vign_Telephone_portable_perso__c, MMPJ_XRM_Titre__c, MMPJ_Ext_Vign_Fonction__c, MMPJ_Ext_Vign_Contact_Principal__c from MMPJ_Ext_Vign_Societe_Contact__c where MMPJ_Ext_Vign_Societe__c=:societe.Id order by CreatedDate desc LIMIT 5];
    }
    
    //Récupère les Evenements
    public List<CampaignMember> getEvents(){
        List<Id> conIds = new List<Id>();
        for(MMPJ_Ext_Vign_Societe_Contact__c sc : [select MMPJ_Ext_Vign_Contact__c from MMPJ_Ext_Vign_Societe_Contact__c where MMPJ_Ext_Vign_Societe__c=:societe.Id order by CreatedDate desc LIMIT 5])
            conIds.add(sc.MMPJ_Ext_Vign_Contact__c);
        return [select Campaign.Name, MMPJ_Ext_Vign_Participation__c,Status,MMPJ_Ext_Vign_Presence__c,Contact.FirstName,Contact.LastName from CampaignMember where contactId IN:conIds];
    }
    
    //Récupère les Infos visite
    public List<MMPJ_XRM_Info_Visite__c> getInfoVisites(){
        return [select Id,MMPJ_XRM_Date__c,MMPJ_XRM_Info_Visite__c.Name from MMPJ_XRM_Info_Visite__c where MMPJ_XRM_Societe__c=:societe.id order by CreatedDate desc LIMIT 5];
    }
    
    //Récupère les Infos Concurents
    public List<MMPJ_XRM_SocieteConcurrent__c> getConcurrents(){
        System.debug('societe');
        System.debug(societe.recordTypeId);
        List<RecordType> lstrecord = [SELECT DeveloperName FROM RecordType WHERE Id = :societe.RecordTypeId LIMIT 1];
        RecordType record = lstRecord[0];
        if (record.DeveloperName == 'MMPJ_Ext_Vign_Centre_de_pressurage' || record.DeveloperName == 'MMPJ_Ext_Vign_Cooperative' || record.developerName == 'MMPJ_Ext_Vign_Vigneron')
        	return[select id,MMPJ_XRM_Negociant_Concurrent__r.Name,MMPJ_XRM_Prix_concurrent_par_Kg__c,MMPJ_XRM_Region_Viticole__c,MMPJ_XRM_Date_fin_contrat__c from MMPJ_XRM_SocieteConcurrent__c where MMPJ_XRM_Societe__c=:societe.id order by CreatedDate desc LIMIT 5];
    	else
            return null;
    }
    //Récupère les Negociants Concurents
    public List<MMPJ_XRM_SocieteConcurrent__c> getNegociantConcurrents(){
        List<RecordType> lstrecord = [SELECT DeveloperName FROM RecordType WHERE Id = :societe.RecordTypeId LIMIT 1];
        RecordType record = lstRecord[0];
        if (record.DeveloperName == 'MMPJ_Ext_Vign_Negociant')
            return[select id,MMPJ_XRM_Societe__r.Name,MMPJ_XRM_Prix_concurrent_par_Kg__c,MMPJ_XRM_Region_Viticole__c,MMPJ_XRM_Date_fin_contrat__c from MMPJ_XRM_SocieteConcurrent__c where MMPJ_XRM_Negociant_Concurrent__c=:societe.id order by CreatedDate desc LIMIT 5];
    	else
            return null;
    }

    //Récupère les Contrats
    public List<MMPJ_Ext_Vign_Contrat__c> getContracts(){
        return [select Id,MMPJ_Ext_Vign_Livreur__r.Name,MMPJ_Ext_Vign_Type_de_contrat__c,MMPJ_Ext_Vign_Millesime__c,MMPJ_Ext_Vign_Volume_mis_en_stock__c from MMPJ_Ext_Vign_Contrat__c where MMPJ_Ext_Vign_Livreur__c = :societe.id order by CreatedDate desc LIMIT 5];
    }
}