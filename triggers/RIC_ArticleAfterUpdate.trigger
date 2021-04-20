trigger RIC_ArticleAfterUpdate on RIC_Article__c (after update) {
    RIC_AP01_RIC_Article.notifyRTCAOnArticleUpdate(trigger.new, trigger.OldMap);
    private static Id Produit_Fini= Schema.SObjectType.RIC_Article__c.getRecordTypeInfosByName().get('Produit Fini').getRecordTypeId();
    
    List<RIC_Article__c > ListArticleToUpdate = new List<RIC_Article__c >();
    for(RIC_Article__c art: trigger.new){
         if((art.RIC_Code_Article__c!= trigger.oldMap.get(art.Id).RIC_Code_Article__c || art.RIC_Magasin_usine__c!= trigger.oldMap.get(art.Id).RIC_Magasin_usine__c || art.RIC_Duplique__c!= trigger.oldMap.get(art.Id).RIC_Duplique__c) 
          &&  art.RIC_Duplique__c==true && (art.recordtypeid==Produit_Fini ))
        {
            ListArticleToUpdate.add(art);
        }
       
    }
     if(ListArticleToUpdate!=null && ListArticleToUpdate.size()>0)
        {
            RIC_AP03_RIC_Article.MAJFieldProjet(ListArticleToUpdate);
        }
}