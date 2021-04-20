public without sharing class RIC_AP01_RIC_Projet { 
    
    private static Id Produit_Fini= Schema.SObjectType.RIC_Article__c.getRecordTypeInfosByName().get('Produit Fini').getRecordTypeId();
    public static void MAJChampsOnArticle(List<Milestone1_Project__c> listProjets){ 
        Set<Id> ProjectID= new Set<Id>();
        List<RIC_Article__c> ListArticleToupdate= new List<RIC_Article__c>();
        for(Milestone1_Project__c eachprojet:listProjets){
            ProjectID.add(eachprojet.id);
        }
        Map<Id, RIC_Article__c> ArticleMap= new Map<Id, RIC_Article__c>([select id,RIC_Code_Article__c,RIC_Magasin_usine__c,RIC_Project__r.RIC_Code_Article__c,RIC_Project__r.RIC_Lieu__c
                                                                         from RIC_Article__c
                                                                         where  RIC_Project__c IN: ProjectID and RIC_Duplique__c=true and 
                                                                         (recordtypeid =: Produit_Fini )]);
        
        for(RIC_Article__c art:ArticleMap.values()){      
            
            if(art.RIC_Project__r.RIC_Code_Article__c!=null)
            {
                art.RIC_Code_Article__c= art.RIC_Project__r.RIC_Code_Article__c;
            }
            if(art.RIC_Project__r.RIC_Lieu__c!=null)
            {
                art.RIC_Magasin_usine__c= art.RIC_Project__r.RIC_Lieu__c;
            } 
            
        }
        update ArticleMap.values();
    }
}