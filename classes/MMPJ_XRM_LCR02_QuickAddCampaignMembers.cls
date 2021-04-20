public with sharing class MMPJ_XRM_LCR02_QuickAddCampaignMembers {
    /* @AuraEnabled
    public static List < Contact > fetchContact(String searchKeyWord) {
        String searchKey = '%' + searchKeyWord + '%';
        // List < Contact > returnList = new List < Contact > ();
        // List < Contact > lstOfContact = [select id, Name, LastName from contact where Name LIKE: searchKey];
        // if(lstOfContact.size() > 0){
        //     for (Contact acc: lstOfContact) {
        //         returnList.add(acc);
        //     }
        // }
        // return returnList;

        return [select id, Name, LastName from contact where Name LIKE: searchKey LIMIT 100];
    }    */

   /*  @AuraEnabled
    public static List < MMPJ_Ext_Vign_Societe_Contact__c > fetchSocieteContact(String searchKeyWord) {
        String searchKey = '%' + searchKeyWord + '%';
        // List < MMPJ_Ext_Vign_Societe_Contact__c > returnList = new List < MMPJ_Ext_Vign_Societe_Contact__c > ();
        // List < MMPJ_Ext_Vign_Societe_Contact__c > lstOfSociete = [SELECT MMPJ_Ext_Vign_Contact__r.Id, MMPJ_Ext_Vign_Contact__r.name, MMPJ_Ext_Vign_Societe__r.name  FROM MMPJ_Ext_Vign_Societe_Contact__c where MMPJ_Ext_Vign_Contact__r.name LIKE: searchKey order by MMPJ_Ext_Vign_Contact__r.Id];
        // for (MMPJ_Ext_Vign_Societe_Contact__c soc: lstOfSociete) {

        //     returnList.add(soc);
        // }
        // return returnList;

        return [SELECT MMPJ_Ext_Vign_Contact__r.Id, MMPJ_Ext_Vign_Contact__r.name, MMPJ_Ext_Vign_Societe__r.name  FROM MMPJ_Ext_Vign_Societe_Contact__c where MMPJ_Ext_Vign_Contact__r.name LIKE: searchKey order by MMPJ_Ext_Vign_Contact__r.Id LIMIT 100];
    } */

    @AuraEnabled
    public static Boolean isMypjCampaign(String pCampaignId){
        Campaign vCamp = [Select Id, RecordTypeId, RecordType.DeveloperName 
                        From Campaign 
                        Where Id = :pCampaignId];

        return vCamp.RecordType.DeveloperName == MYPJ_Constants.CAMPAIGN_RT_MYPJ ? true : false;
    }

@AuraEnabled
public static List <ContactClass> fetchSocieteContactFinal(String searchKeyWord, List<Id> contactIds, String campaignId) {
    Map<Id, ContactClass> contactMap = new Map<Id,ContactClass>();
    String searchKey = '%' + searchKeyWord + '%';

    Campaign vCamp = [Select Id, RecordTypeId, RecordType.DeveloperName 
                        From Campaign 
                        Where Id = :campaignId];

    // Used to do not put a "societeParDefaut" if a contact has two or more Societe "MMPJ_Ext_Vign_Contact_Principal__c"
    Map<String, Boolean> mapSocieteHasPrincipalCon = new Map<String, Boolean>();

    if(vCamp.RecordType.DeveloperName == MYPJ_Constants.CAMPAIGN_RT_MYPJ) {
        for(Contact vCon : [Select Id, Name
                            From Contact
                            Where RecordType.DeveloperName = :MYPJ_Constants.CONTACT_RT_MYPJ
                            AND Name LIKE :searchKey
                            LIMIT 100])
        {
            List<map<String,String>> listedesSocietes = new List<map<String,String>>();
            Boolean alreadyCM = contactIds.contains(vCon.Id) ? true : false;
            String defaultSociete = '';

            contactMap.put(vCon.Id, new contactClass(
                                                    vCon.Id,
                                                    vCon.name,
                                                    listedesSocietes,
                                                    alreadyCM,
                                                    defaultSociete
                                                ));
        }
    } else {
        for(MMPJ_Ext_Vign_Societe_Contact__c ctc: [SELECT MMPJ_Ext_Vign_Societe__c,
                                                            MMPJ_Ext_Vign_Contact__c,
                                                            MMPJ_Ext_Vign_Contact_Principal__c,
                                                            MMPJ_Ext_Vign_Contact__r.name, MMPJ_Ext_Vign_Societe__r.name
                                                    FROM MMPJ_Ext_Vign_Societe_Contact__c
                                                    WHERE MMPJ_Ext_Vign_Contact__r.name LIKE: searchKey 
                                                    OR MMPJ_Ext_Vign_Societe__r.name LIKE :searchKey
                                                    ORDER BY MMPJ_Ext_Vign_Societe__r.name LIMIT 100])
        {
            String vCon = ctc.MMPJ_Ext_Vign_Contact__c;
            if(!contactMap.containsKey(vCon)) {
                List<map<String,String>> listedesSocietes = new List<map<String,String>>(); 
                listedesSocietes.add(new map<String, String>{'label'=>ctc.MMPJ_Ext_Vign_Societe__r.name, 'value'=> (String)ctc.MMPJ_Ext_Vign_Societe__c}); 
                System.debug('listedesSocietes' + listedesSocietes); 
                Boolean alreadyCM = contactIds.contains(vCon) ? true : false;
                String defaultSociete = '';
                //modified by Amadou
                //désormais les sociétés ne sont plus affichées en concaténant leurs noms 
                //elles sont affichées désormais dans une picklist que l'utilisateur peut modifier à sa guise
                //lorsque le contact est contact principale dans une société, 
                //la société par défaut sera cette dernière, et les autres sociétés auxquelles il appartient 
                //s'afficheront dans une picklist par ordre alphabétique. 
                //si le contact n'est contact principale dans aucune société, 
                //on affichera la liste des sociétés par ordre alphabétique
                if (ctc.MMPJ_Ext_Vign_Contact_Principal__c){
                defaultSociete =  (String) ctc.MMPJ_Ext_Vign_Societe__r.Id;
                    mapSocieteHasPrincipalCon.put(vCon, true);
                } else {
                    mapSocieteHasPrincipalCon.put(vCon, false);
                }

                contactMap.put(vCon, new contactClass(
                                                        vCon,
                                                        ctc.MMPJ_Ext_Vign_Contact__r.name,
                                                        listedesSocietes,
                                                        alreadyCM,
                                                        defaultSociete
                                                    ));
                
            }
            else {
                contactMap.get(vCon).listSociete.add(new map<String, String>{'label'=>ctc.MMPJ_Ext_Vign_Societe__r.name, 'value'=> (String) ctc.MMPJ_Ext_Vign_Societe__c});
                System.debug('contactMap' + contactMap); 
                if (ctc.MMPJ_Ext_Vign_Contact_Principal__c){
                    if(!mapSocieteHasPrincipalCon.get(vCon)) {
                        String defaultSociete = (String) ctc.MMPJ_Ext_Vign_Societe__r.Id;
                        contactMap.get(vCon).societeParDefaut = ctc.MMPJ_Ext_Vign_Societe__r.Id;
                        mapSocieteHasPrincipalCon.put(vCon, true);
                    } else {
                        contactMap.get(vCon).societeParDefaut = '';
                    }
                }
            }
        }
    }

    // Select by default the societe if there is only one
    for(ContactClass vContact : contactMap.values()) {
        if(vContact.listSociete.size() == 1) {
            vContact.societeParDefaut = vContact.listSociete[0].get('value');
        }
    }

    System.debug('#######contactMap.values()' + contactMap.values());
    System.debug('#######contactMap ' + contactMap);
    return contactMap.values();

}

    @AuraEnabled
    public static CampaignMember addCampaignMemberApex(Id contactId, Id campaignId, Boolean isCheckIn, String societeId ) {
        try{
            CampaignMember cm = new CampaignMember(CampaignId = campaignId, ContactId = contactId,MMPJ_XRM_Societe__c =societeId );
        
            if (isCheckIn) {
                cm.MMPJ_Ext_Vign_Presence__c = 'Venu';
                cm.MMPJ_Ext_Vign_Participation__c = 'Accepté';
                cm.Status = 'Répondue';
            }
            System.debug('#####cm' +cm); 
            upsert cm;
            return cm;
        }
        catch(Exception e){
            return null;
        }
        
       
        
    }

    @AuraEnabled
    public static List<Id> getCampaignMembers(Id campaignId){
        List<Id> listContactsId = new List<Id>();
        for (CampaignMember cm : [SELECT ContactId FROM CampaignMember WHERE CampaignId =: campaignId]){
            listContactsId.add(cm.ContactId);
        }
        return listContactsId;
    }

    public class contactClass {
        @AuraEnabled public List<map<String, String>>  listSociete{get;set;}
        @AuraEnabled public Id contactId{get;set;}
        @AuraEnabled public String contactName{get;set;}
        @AuraEnabled public Boolean alreadyCM{get;set;}
        @AuraEnabled public String societeParDefaut{get;set;}

        public contactClass(Id contactId, String contactName, List<map<String, String>> mapSociete, Boolean alreadyCM, String societe)
        {
            this.listSociete = mapSociete;
            this.contactId = contactId;
            this.contactName = contactName;
            this.alreadyCM = alreadyCM;
            this.societeParDefaut = societe; 
        }
    }
}