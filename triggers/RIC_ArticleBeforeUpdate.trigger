trigger RIC_ArticleBeforeUpdate on RIC_Article__c (before update) {
    
    RIC_AP01_RIC_Article.unlockRecordBeforeUpdate(trigger.new, trigger.OldMap);
    RIC_AP01_RIC_Article.updateTechChangedFiels(trigger.new, trigger.OldMap);
    
    
    //TMA JSA 156
    List<RIC_Article__c> ListArtToUpdate = new  List<RIC_Article__c>();
    private static Id Produit_Fini= Schema.SObjectType.RIC_Article__c.getRecordTypeInfosByName().get('Produit Fini').getRecordTypeId();
    set<id> ProjectId = new set<id>();
    for(RIC_Article__c eachArt:Trigger.new)
    {
        if((eachArt.recordtypeid==Produit_Fini ) && 
           eachArt.RIC_Duplique__c!=trigger.oldMap.get(eachArt.Id).RIC_Duplique__c && eachArt.RIC_Duplique__c==true  )
        {
            ListArtToUpdate.add(eachArt);
            ProjectId.add(eachArt.RIC_Project__c); 
        }
    }
    if(ListArtToUpdate!=null && ListArtToUpdate.size()>0)
    {
        RIC_AP02_RIC_Article.DuplicateFieldError(ListArtToUpdate,ProjectId);
    }
}