trigger RIC_ArticleAfterInsert on RIC_Article__c (after insert) {
private static Id Produit_Fini= Schema.SObjectType.RIC_Article__c.getRecordTypeInfosByName().get('Produit Fini').getRecordTypeId();
    
    List<RIC_Article__c > ListArticleToUpdate = new List<RIC_Article__c >();
    for(RIC_Article__c art: trigger.new){
        if((art.RIC_Code_Article__c!=null || art.RIC_Magasin_usine__c!=null)
          && (art.recordtypeid==Produit_Fini) &&  art.RIC_Duplique__c==true) 
        {
            ListArticleToUpdate.add(art);
        }
       
    }
     if(ListArticleToUpdate!=null && ListArticleToUpdate.size()>0)
        {
            RIC_AP03_RIC_Article.MAJFieldProjet(ListArticleToUpdate);
        }
}