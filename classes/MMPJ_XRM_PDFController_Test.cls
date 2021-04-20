@isTest
public class MMPJ_XRM_PDFController_Test {
    static testmethod void pdfControllerTest(){
        MMPJ_Ext_Vign_Societe__c societe = new MMPJ_Ext_Vign_Societe__c(Name='Corporate', RecordTypeId=getRecordTypeId('MMPJ_Ext_Vign_Centre_de_pressurage'));
        insert societe;
        
        Contact contact = new Contact(RecordTypeId=getRecordTypeId('MMPJ_Ext_Vign_Contact'), LastName='Person', MMPJ_Ext_Vign_Contact_Segmentation__c='Champagne');
        insert contact;

        MMPJ_Ext_Vign_Societe_Contact__c societeContact = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Societe__c=societe.Id, MMPJ_Ext_Vign_Contact__c=contact.Id);
        insert societeContact;

        MMPJ_Ext_Vign_Facture__c facture = new MMPJ_Ext_Vign_Facture__c(Name='777', RecordTypeId=getRecordTypeId('MMPJ_Ext_Vign_Facture'));
        insert facture;

        MMPJ_Ext_Vign_Contrat__c contrat = new MMPJ_Ext_Vign_Contrat__c(Name='1234', RecordTypeId=getRecordTypeId('MMPJ_Ext_Vign_Appro_Press'));
        insert contrat;

        MMPJ_XRM_SocieteConcurrent__c societeConcurrent = new MMPJ_XRM_SocieteConcurrent__c(MMPJ_XRM_Societe__c=societe.Id);
        insert societeConcurrent;

        MMPJ_XRM_Info_Visite__c infoVisite = new MMPJ_XRM_Info_Visite__c(Name='VisiteTest', MMPJ_XRM_Societe__c=societe.Id);
        insert infoVisite;
    
        PageReference pageRef1 = Page.MMPJ_XRM_FicheRapportPernod;
        Test.setCurrentPage(pageRef1);

        MMPJ_XRM_FicheRapportPernodController controller = new MMPJ_XRM_FicheRapportPernodController(new ApexPages.StandardController(societe));
        
        test.startTest();
  
        controller.getfactures();
        controller.getContact();
        controller.getContact();
        controller.getEvents();
        controller.getInfoVisites();
        controller.getConcurrents();
        controller.getNegociantConcurrents();
        controller.getContracts();
        
        test.stopTest();
    }
    
    //Récupère le RecordTypeId à partir du Name
    public static String getRecordTypeId(String str){
        List<RecordType> rt = [SELECT Id from RecordType where DeveloperName=:str LIMIT 1];
        If (rt != null && !rt.isEmpty())
            return rt[0].Id;
        return null;
    }
}