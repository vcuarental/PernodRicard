public class RIC_AP03_RIC_Article {
    //private static Id Produit_Fini_PERNOD= Schema.SObjectType.RIC_Article__c.getRecordTypeInfosByName().get('Produit Fini PERNOD').getRecordTypeId();
    //private static Id Produit_Fini_RICARD= Schema.SObjectType.RIC_Article__c.getRecordTypeInfosByName().get('Produit Fini RICARD').getRecordTypeId();
    public static void MAJFieldProjet(List<RIC_Article__c> ListArticles){ 
        map<id,RIC_Article__c> mapProjArticle = new  map<id,RIC_Article__c>();
        LIST<RIC_Article__c> ListArticleToUpdate = new  List<RIC_Article__c>();
        for(RIC_Article__c eachArt: ListArticles){
            
            mapProjArticle.put(eachArt.RIC_Project__c, eachArt); 
        }
        
        Map<Id, Milestone1_Project__c> ProjMap= new Map<Id, Milestone1_Project__c>([select id,  RIC_Code_article__c,RIC_Lieu__c 
                                                                                    from Milestone1_Project__c
                                                                                    where  id IN: mapProjArticle.keySet()]);
        for(Milestone1_Project__c proj:ProjMap.values())
        {
            if (mapProjArticle.containsKey(proj.id)){ 
                if(mapProjArticle.get(proj.id).RIC_Code_article__c != proj.RIC_Code_article__c){
                    proj.RIC_Code_article__c= mapProjArticle.get(proj.id).RIC_Code_article__c; 
                }
                if(mapProjArticle.get(proj.id).RIC_Magasin_usine__c != proj.RIC_Lieu__c){
                    proj.RIC_Lieu__c= mapProjArticle.get(proj.id).RIC_Magasin_usine__c; 
                }
                if(mapProjArticle.get(proj.id).RIC_Statut_du_projet__c=='En création')
                {
                    proj.RIC_Tech_VR__c=!(proj.RIC_Tech_VR__c);  
                }   
        }
        } 
        update ProjMap.values();
        
    }
}