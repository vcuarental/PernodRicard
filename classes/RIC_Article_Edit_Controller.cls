public class RIC_Article_Edit_Controller {
    
    public RIC_Article__c ricArticle {get; set;}
    public boolean canEdit {get; set;}
    
    public RIC_Article_Edit_Controller(ApexPages.StandardController std) {
        String recordId = std.getId();
        ricArticle = [SELECT Id, RIC_Tech_isLocked__c, RIC_Tech_LockDateTime__c, RIC_Tech_LockingUser__c 
                      FROM RIC_Article__c 
                      WHERE Id = :recordId];
    }
    
    public PageReference verifyEditPermission() {
        
        PageReference pageRef;
        if(ricArticle != null) {
            if(!ricArticle.RIC_Tech_isLocked__c) {
                ricArticle.RIC_Tech_isLocked__c = true;
                ricArticle.RIC_Tech_LockDateTIme__c = DateTime.now();
                ricArticle.RIC_Tech_LockingUser__c = UserInfo.getUserId();
                update ricArticle;
                
                ricArticle = [SELECT ID, RIC_Tech_isLocked__c FROM RIC_Article__c WHERE ID = :ricArticle.Id];
                pageRef = new PageReference('/' + ricArticle.Id + '/e?retURL=' + ricArticle.Id + '&nooverride=1');
            }
            else {
                Long currentTime = DateTime.now().getTime();
                if(ricArticle.RIC_Tech_LockDateTIme__c != null && (currentTime - ricArticle.RIC_Tech_LockDateTIme__c.getTime() >= 60000) && !UserInfo.getUserId().equals(ricArticle.RIC_Tech_LockingUser__c)) {
                    ricArticle.RIC_Tech_LockDateTIme__c = DateTime.now();
                    ricArticle.RIC_Tech_LockingUser__c = UserInfo.getUserId();
                    update ricArticle;
                    
                    pageRef = new PageReference('/' + ricArticle.Id + '/e?retURL=' + ricArticle.Id + '&nooverride=1');
                }
                else if(ricArticle.RIC_Tech_LockDateTIme__c != null && (currentTime - ricArticle.RIC_Tech_LockDateTIme__c.getTime() < 60000)) {                
                    pageRef = new PageReference('/' + ricArticle.Id);
                }
            }
        }
        
        if(pageRef != null)
            pageRef.setRedirect(true);
        return pageRef;
    }
    
    public void unlockRecordOnLoad() {
        Long currentTime = DateTime.now().getTime();
        canEdit = true;
        if(ricArticle.RIC_Tech_isLocked__c && (ricArticle.RIC_Tech_LockingUser__c.equals(UserInfo.getUserId()))) {
            ricArticle.RIC_Tech_isLocked__c = false;
            ricArticle.RIC_Tech_LockDateTIme__c = null;
            ricArticle.RIC_Tech_LockingUser__c = '';
            update ricArticle;
        }
        else if(ricArticle.RIC_Tech_isLocked__c && ricArticle.RIC_Tech_LockDateTIme__c != null && (currentTime - ricArticle.RIC_Tech_LockDateTIme__c.getTime() < 60000)) {
            canEdit = false;
        }
        
        System.debug('### canEdit: ' + canEdit);
    }
}