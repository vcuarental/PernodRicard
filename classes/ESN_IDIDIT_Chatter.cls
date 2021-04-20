public with sharing class ESN_IDIDIT_Chatter {
    
    public Boolean error {get;set;}
    //public String counter {get; set;}
    public String message {get; set;}
    public ContentVersion file {get; set;}
    public String subjectId {get; set;}
    
    private static final List<CollaborationGroup> chatterGroup = [SELECT Id, Name FROM CollaborationGroup WHERE Name=:Label.ESN_IDIDIT_ChatterGroupName LIMIT 1];
    
    public ESN_IDIDIT_Chatter() {
        file = new ContentVersion();
    }
    
    public PageReference Post() {
        
        if(subjectId==null || subjectId == '' || subjectId.trim().length() == 0){
            subjectId = chatterGroup[0].Id;
        }
        
        if(message == Label.ESN_IDIDIT_FormText) {
            message = '';
        }
        
        error=false;
        /*if (counter == null || counter == '' || counter.trim().length() == 0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ESN_IDIDIT_ErrorMsg1));
            error=true;
        }
        else {
            try {
                Integer i = integer.valueOf(counter);
            } catch(Exception e) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ESN_IDIDIT_ErrorMsg2));
                error=true;
            }
        }*/
         
        if (!error) {
            if (file.PathOnClient != null) {        
                file.Title = file.PathOnClient.split('\\.')[0];
            }   
            
            // Get groupId
            String groupId = ApexPages.currentPage().getParameters().get('id');
            system.debug('groupId: ' +groupId);
        
            /* Insert post text */
            //Without Label.ESN_IDIDIT_PostMsg1 + ' ' + '(.*?)' + ' ' + Label.ESN_IDIDIT_PostMsg2;
            //String text = Label.ESN_IDIDIT_PostMsg1 + ' ' + '(.*?)' + ' ' + Label.ESN_IDIDIT_PostMsg2;
            
            String text;
            // If message field is filled
            if(!(message == null || message == '' || message.trim().length() == 0)) {
                text = message;
            }
            // If "I Did it" group -> no reference (@mention) to "I Did it" group
            if (!String.valueof(subjectId).contains(groupId)) {
                text += '\n\n' + '{' + subjectId + '}' + '\n'; 
            }
        
            ESN_IDIDIT_ConnectApiHelper.postFeedItemWithMentions(null, groupId, text, file);            
        }
        
        //file.PathOnClient = null;
        file = null;
        file = new ContentVersion();
        return null;
    }
}