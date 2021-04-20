trigger RIC_ArticleBeforeinsert on RIC_Article__c (before insert) {
    List<RIC_Article__c> ListArtToInsert = new  List<RIC_Article__c>();
    private static Id Produit_Fini= Schema.SObjectType.RIC_Article__c.getRecordTypeInfosByName().get('Produit Fini').getRecordTypeId();
    set<id> ProjectId = new set<id>();
    for(RIC_Article__c eachArt:Trigger.new)
    {
        if((eachArt.recordtypeid==Produit_Fini ) && eachArt.RIC_Duplique__c==true )
        {
            ListArtToInsert.add(eachArt);
            system.debug('TestInsert');
            ProjectId.add(eachArt.RIC_Project__c); 
        }
    }
    if(ListArtToInsert!=null && ListArtToInsert.size()>0)
    {
        RIC_AP02_RIC_Article.DuplicateFieldError(ListArtToInsert,ProjectId);
    }
}