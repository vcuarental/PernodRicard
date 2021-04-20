public class RIC_AP02_RIC_Article {
    private static Id Produit_Fini= Schema.SObjectType.RIC_Article__c.getRecordTypeInfosByName().get('Produit Fini').getRecordTypeId();
    public static void DuplicateFieldError(List<RIC_Article__c> ListArticles, set<id> Idprojects){  
  
        List<RIC_Article__c> ListArticleDupp = new List <RIC_Article__c>(); 
        map<id,RIC_Article__c> mapProjArticle = new map<id,RIC_Article__c>();       
       
        ListArticleDupp=[select id from RIC_Article__c where RIC_Project__c in :Idprojects and  RIC_Duplique__c=true and 
                        (recordtypeid =: Produit_Fini )];

        if(ListArticleDupp!=null && ListArticleDupp.size()>0)
        { 
            for(RIC_Article__c EachArt: ListArticles)
            {
                EachArt.addError(Label.RIC_DupError);
            }
        } 
    } 
}