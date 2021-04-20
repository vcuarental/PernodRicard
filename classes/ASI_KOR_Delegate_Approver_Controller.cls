public without sharing class ASI_KOR_Delegate_Approver_Controller{

    
    public sObject header{get;set;}
    public boolean closeWindow{set;get;}


        
    public ASI_KOR_Delegate_Approver_Controller(ApexPages.StandardController controller) {
            header = controller.getRecord(); 
            closeWindow = false;


    }

    public void saveNSDProposal(){
    
        String userID = UserInfo.getUserId();
        UserRole role = [Select ID from UserRole where Name = 'Business Development (Admin)' Limit 1];
        User loggedin = [Select UserRole.ID from User where ID = :userID limit 1];

        if(loggedin.userRole.ID != role.ID){
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'Insufficient permission to perform action.');
            apexpages.addmessage(err);
            return ;
        }  
            List< ASI_KOR_NSD_Proposal_Header__c> shared = 
                [Select ID from ASI_KOR_NSD_Proposal_Header__c where ID= :((ASI_KOR_NSD_Proposal_Header__c)header).ID AND ASI_KOR_Delegated_Approver__c != null];

                ASI_KOR_NSD_Proposal_Header__Share shareRecord = new ASI_KOR_NSD_Proposal_Header__Share();
                shareRecord.PARENTID = ((ASI_KOR_NSD_Proposal_Header__c)header).ID;    
                shareRecord.USERORGROUPID = ((ASI_KOR_NSD_Proposal_Header__c)header).ASI_KOR_Delegated_Approver__c;
                shareRecord.AccessLevel = 'Read';
                
                insert shareRecord; 
                update header;
        
                closeWindow = true;
                
                return ;

    
    }

       
     public void saveNSDPayment(){
    
        String userID = UserInfo.getUserId();
        //List<ASI_KOR_CRM_Admin__c> crmAdmin = [Select ID from ASI_KOR_CRM_Admin__c where ASI_KOR_CRM_Admin_ID__c = :userID];
        UserRole role = [Select ID from UserRole where Name = 'Business Development (Admin)' Limit 1];
        User loggedin = [Select UserRole.ID from User where ID = :userID limit 1];
        //if(crmAdmin == null || crmAdmin.size()==0){
        if(loggedin.userRole.ID != role.ID){
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'Insufficient permission to perform action.');
            apexpages.addmessage(err);
            return ;
        }  
            List< ASI_KOR_NSD_Payment_Settlement_Header__c> shared = 
                [Select ID from ASI_KOR_NSD_Payment_Settlement_Header__c where ID= :((ASI_KOR_NSD_Payment_Settlement_Header__c)header).ID AND ASI_KOR_Delegated_Approver__c != null];
                ASI_KOR_NSD_Payment_Settlement_Header__Share shareRecord = new ASI_KOR_NSD_Payment_Settlement_Header__Share();
                shareRecord.PARENTID = ((ASI_KOR_NSD_Payment_Settlement_Header__c)header).ID;    
                shareRecord.USERORGROUPID = ((ASI_KOR_NSD_Payment_Settlement_Header__c)header).ASI_KOR_Delegated_Approver__c;
                shareRecord.AccessLevel = 'Read';
                
                insert shareRecord; 
                update header;
        
              
                closeWindow = true;
                
                return ;
                 
               
            
    
    }
    /*
    public void deleteNSDPayment(){
    
        String userID = UserInfo.getUserId();
        List<ASI_KOR_CRM_Admin__c> crmAdmin = [Select ID from ASI_KOR_CRM_Admin__c where ASI_KOR_CRM_Admin_ID__c = :userID];
        if(crmAdmin == null || crmAdmin.size()==0){
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'Insufficient permission to perform action.');
            apexpages.addmessage(err);
            return;
        }  
            List< ASI_KOR_NSD_Payment_Settlement_Header__c> shared = 
                [Select ID from ASI_KOR_NSD_Payment_Settlement_Header__c where ID= :((ASI_KOR_NSD_Payment_Settlement_Header__c)header).ID AND ASI_KOR_Delegated_Approver__c =:((ASI_KOR_NSD_Payment_Settlement_Header__c)header).ASI_KOR_Delegated_Approver__c];

            if(shared.size()!=0){
                List <ASI_KOR_NSD_Payment_Settlement_Header__Share> shareRecords =
                    [Select ID From ASI_KOR_NSD_Payment_Settlement_Header__Share where PARENTID = :((ASI_KOR_NSD_Payment_Settlement_Header__c)header).ID AND   
                    USERORGROUPID = :((ASI_KOR_NSD_Payment_Settlement_Header__c)header).ASI_KOR_Delegated_Approver__c];
                
                
               
                ASI_KOR_NSD_Payment_Settlement_Header__c temp = ((ASI_KOR_NSD_Payment_Settlement_Header__c)header);
                temp.ASI_KOR_Delegated_Approver__c = null;
                
               // delete shareRecords; 

                update temp;
                closeWindow = true;
                 
                return ;
            }else{
                apexpages.message err = new apexpages.message(apexpages.severity.error, 'Current record has not been delegated to user specified.');
                apexpages.addmessage(err);
                return ;
            
            }
            
    
    } 
    */
    
    

}