global class ASI_KOR_SRProposalDetailsActualVolJob implements Database.Batchable<sObject>, database.allowscallouts, database.stateful
{ 
    private String query;
    private String yearProposal;
    private String monthProposal;
    private Date cutOffDate;
    
    public ASI_KOR_SRProposalDetailsActualVolJob(String year, String month, Date cutOff)
    {
     query = ' Select ASI_KOR_SR_Proposal_ID__r.Id, ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Month__c,ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Year__c, ' +
     ' ASI_KOR_SR_Proposal_ID__r.OwnerId, ASI_KOR_SR_Proposal_ID__r.Owner.Email, Id, ASI_KOR_UOM__c, ASI_KOR_Brand__c,ASI_KOR_Venue__c, ' + 
     ' ASI_KOR_Incentive_Scheme__c, ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Status__c from ASI_KOR_SR_Proposal_Detail__c where ' +
     ' ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Year__c=\'' + year + '\' AND ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Month__c=\'' +month + '\' AND ' +
     ' ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Status__c = \'Approved by BM\' order by ASI_KOR_SR_Proposal_ID__c ';
     yearProposal = year;
     monthProposal = month; 
     cutOffDate = cutOff;
    
    }
        
    global ASI_KOR_SR_Proposal_Detail__c currentProposal;
    global List<String> tmktRoleEmails;
    
    global database.querylocator start(Database.BatchableContext batchableContext)
    {
        return database.getquerylocator(query); 
    }
    
    global void execute(Database.BatchableContext batchableContext, List<sObject> scope)
    {     
        /*
        if (tmktRoleEmails== null)
        {
        tmktRoleEmails = new List<String>();
        List<User> tmktroles = [select email from user where userrole.name in 
        ('Trade Marketing Director','Trade Marketing Team','Business Development (Admin)')];        
        for (User user: tmktroles)
        {
            tmktRoleEmails.add(user.email);       
        }        
        }
        */
        List<ASI_KOR_SR_Proposal_Detail__c> srProposalDetailToUpdate = new List<ASI_KOR_SR_Proposal_Detail__c>();
        //EmailTemplate  emailTemplate = [select Id,Name,Subject,body,HtmlValue from EmailTemplate where name = 'ASI KOR SR Payment Details Creation'];
        
        for (sObject cObject : scope)
        {
            Decimal volume = 0;
            ASI_KOR_SR_Proposal_Detail__c srProposalDetail = (ASI_KOR_SR_Proposal_Detail__c) cObject;
            
            System.debug(srProposalDetail.ASI_KOR_Brand__c+','+srProposalDetail.ASI_KOR_Venue__c+','+srProposalDetail.ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Year__c+','+srProposalDetail.ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Month__c);
            
            if (!Test.isRunningTest())
            {
            if(srProposalDetail.ASI_KOR_UOM__c == 'Actual Case'){
             volume  = ASI_KOR_Payment_Settlement_Detail_ActVol.getVolumeByCase(srProposalDetail.ASI_KOR_Brand__c,srProposalDetail.ASI_KOR_Venue__c,srProposalDetail.ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Year__c, srProposalDetail.ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Month__c );
            } else if(srProposalDetail.ASI_KOR_UOM__c == 'Bottle'){
             volume  = ASI_KOR_Payment_Settlement_Detail_ActVol.getVolumeByBottle(srProposalDetail.ASI_KOR_Brand__c,srProposalDetail.ASI_KOR_Venue__c,srProposalDetail.ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Year__c , srProposalDetail.ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Month__c );
            }
            } else
            {
                volume = 9000;
            }   
            
           if (volume > 0)
           {
            System.debug('Flag XXXX' + volume + ' Proposal Id: ' + srProposalDetail.id + ' Incentive: ' + srProposalDetail.ASI_KOR_Incentive_Scheme__c);
            Decimal unitCostBasedActualVolume =  getUnitCostCapBasedActualCase(srProposalDetail.ASI_KOR_Incentive_Scheme__c,volume );
            srProposalDetailToUpdate.add(new ASI_KOR_SR_Proposal_Detail__c(Id=srProposalDetail.Id,ASI_KOR_Unit_Cost_Cap_Actual_Volume__c=unitCostBasedActualVolume ,
            ASI_KOR_Actual_Volume__c=volume)); 
           }             
           
           if  (currentProposal != null && srProposalDetail.ASI_KOR_SR_Proposal_ID__c != currentProposal.ASI_KOR_SR_Proposal_ID__c )
           {
             // sendEmailUpdateCompletion(currentProposal,emailTemplate);   
              currentProposal = srProposalDetail;
           } else if (currentProposal == null)
           {
               currentProposal = srProposalDetail;           
           }
       }    
       update srProposalDetailToUpdate;
    }
    
 /*  public void sendEmailUpdateCompletion( ASI_KOR_SR_Proposal_Detail__c currentProposal ,EmailTemplate  emailTemplate)
   { 
     System.debug('Flag XXXX Email: ' + currentProposal.ASI_KOR_SR_Proposal_ID__r.Owner.Email);
     
     if (currentProposal.ASI_KOR_SR_Proposal_ID__r.Owner.Email != null) {
     
     User currentUser = 
     [select manager.email, manager.manager.email, manager.manager.manager.email 
     from user where id =:currentProposal.ASI_KOR_SR_Proposal_ID__r.OwnerID];
     
     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
     List<String> emailAddresses = new List<String>();
     emailAddresses.addAll(tmktRoleEmails);
     emailAddresses.add(currentProposal.ASI_KOR_SR_Proposal_ID__r.Owner.Email);  
     
     if (currentUser.manager.email != null)
     {
       emailAddresses.add(currentUser.manager.email);
     }
     
     if (currentUser.manager.manager.email != null)
     {
       emailAddresses.add(currentUser.manager.manager.email);   
     }
     
     if (currentUser.manager.manager.email != null)
     {
       emailAddresses.add(currentUser.manager.manager.email);   
     }
     
     ASI_KOR_NSD_Proposal_Header__c  nsdHeader = [select ASI_KOR_SYS_Cut_off_Date__c from ASI_KOR_NSD_Proposal_Header__c where 
     ASI_KOR_Year__c=:currentProposal.ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Year__c 
     and ASI_KOR_Month__c=:currentProposal.ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Month__c];
     
     
     mail.setToAddresses(emailAddresses);
     mail.setSubject(emailTemplate.Subject);
     String htmlBody = emailTemplate.HtmlValue;
     htmlBody = htmlBody.replaceAll('ASI_KOR_Year__c',currentProposal.ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Year__c);
     htmlBody = htmlBody.replaceAll('ASI_KOR_Month__c',currentProposal.ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Month__c);
     htmlBody = htmlBody.replaceAll('ASI_KOR_Cutoff_Date__c',String.valueOf(nsdHeader.ASI_KOR_SYS_Cut_off_Date__c));
   
     DescribeSObjectResult describeSObjectResult  = ASI_KOR_SR_Payment_Settlement_Header__c.sObjectType.getDescribe();
     String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + describeSObjectResult.getKeyPrefix(); 
     
     htmlBody = htmlBody.replaceAll('paymentSettlementURL',fullRecordURL);
     
     mail.setHtmlBody(htmlBody);              
     mail.saveAsActivity = false;
     Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
     }            
   } 
    */
   public static Decimal getUnitCostCapBasedActualCase(Id incentiveScheme, Decimal actualVolume){
    Decimal unitCost = 0;
    try{
        List<ASI_KOR_Incentive_Scheme__c> ic = [select
        ASI_KOR_Brand__c
        ,
        ASI_KOR_Branch__c
        ,
        ASI_KOR_UOM__c
        ,
        ASI_KOR_Grade__c
        ,
        ASI_KOR_Effective_Start_Date__c
        ,
        ASI_KOR_Effective_End_Date__c
        ,
        ASI_KOR_Contract__c
        from ASI_KOR_Incentive_Scheme__c
        where id =: incentiveScheme];
        
        System.debug('Flag1 xxx:' + actualVolume + ' ' +ic);
        
        if (ic.size() > 0)
        {
        List<ASI_KOR_Incentive_Scheme__c> ic2 = [select ASI_KOR_UOM__c, ASI_KOR_CA_Unit_Cost__c,ASI_KOR_Basic_Unit_Cost__c from ASI_KOR_Incentive_Scheme__c
        where 
        ASI_KOR_Brand__c = :ic.get(0).ASI_KOR_Brand__c
        and
        ASI_KOR_Branch__c=:ic.get(0).ASI_KOR_Branch__c
        and
        ASI_KOR_UOM__c=:ic.get(0).ASI_KOR_UOM__c
        and
        ASI_KOR_Sales_Bracket__c <=:actualVolume
        and
        ASI_KOR_Grade__c=:ic.get(0).ASI_KOR_Grade__c
        and
        ASI_KOR_Effective_Start_Date__c = :ic.get(0).ASI_KOR_Effective_Start_Date__c 
        and
        ASI_KOR_Effective_End_Date__c =:ic.get(0).ASI_KOR_Effective_End_Date__c 
        and
        ASI_KOR_Contract__c =:ic.get(0).ASI_KOR_Contract__c 
        order by ASI_KOR_Sales_Bracket__c DESC limit 1];
        if (ic2.size()>0)
        {
        unitCost  = ic2.get(0).ASI_KOR_CA_Unit_Cost__c;
        }
        }
    
    }catch(DmlException exc){
         ApexPages.addMessages(exc);
    }
    return unitCost;
}

    
    global void finish(Database.BatchableContext batchableContext)
    {         
    
         List<String> users = new List<String>(); 
              List<ASI_KOR_NSD_Proposal_Header__c> NSDProp = 
                  [Select OwnerID 
                   From  ASI_KOR_NSD_Proposal_Header__c 
                   Where ASI_KOR_Year__c = :yearProposal and 
                   ASI_KOR_Month__c = :monthProposal
                  ];
              List<ASI_KOR_RSD_Proposal_Header__c> RSDProp = 
                  [Select OwnerID 
                  From  ASI_KOR_RSD_Proposal_Header__c 
                  where ASI_KOR_Year__c = :yearProposal and 
                  ASI_KOR_Month__c = :monthProposal
                  ];
              List<ASI_KOR_BM_Proposal_Header__c> BMProp =
                  [Select OwnerID, ASI_KOR_SYS_Branch_Code__c 
                  From  ASI_KOR_BM_Proposal_Header__c 
                  where ASI_KOR_Year__c = :yearProposal and
                  ASI_KOR_Month__c = :monthProposal];
               
               List<String> SRBranchCode = new List<String>();

               
               for(ASI_KOR_NSD_Proposal_Header__c user : NSDProp){ 
                   users.add(user.OwnerID);
                   
               }
               for(ASI_KOR_RSD_Proposal_Header__c user : RSDProp){ 
                    users.add(user.OwnerID);
                 
               }
               for(ASI_KOR_BM_Proposal_Header__c user : BMProp){ 
                    users.add(user.OwnerID);
                    if(user.ASI_KOR_SYS_Branch_Code__c != null)
                    SRBranchCode.add(user.ASI_KOR_SYS_Branch_Code__c); 
               }
         
         
              List<User> salesRep=
                  [Select 
                      ID
                   From 
                      User 
                   Where 
                      UserRole.DeveloperName Like 'ASI_KOR_SR%' AND 
                      ASI_KOR_User_Branch_Code__c IN :SRBranchCode
                   ];
              
              
              for(User sr : salesRep){                
                  users.add(sr.ID);  
              }
              
              List<User> tmktroles = [select id from user where userrole.DeveloperName in 
            ('ASI_KOR_Trade_Marketing_Team','ASI_KOR_Business_Development_Admin')];  
            
              for(User tmkt :tmktroles){
                  users.add(tmkt.ID);
              }
              
              List<Group> notificationGroup = [Select id from group where DeveloperName ='ASI_KOR_TMKT_Director_Notification' ];
              List<GroupMember> groupm = new List<GroupMember>();
              if(notificationGroup.size()>0){
                  groupm =  [Select UserOrGroupId From GroupMember Where GroupId = :notificationGroup.get(0).id];
                  
              }
              for(GroupMember member : groupm){
                  users.add(member.UserOrGroupID);
              }
                
              List<List<String>> usersList = new List<List<String>>(); 
              integer count = 0 ;
              List<String> tempList; 
              
              for(String user : users){             
                  if(count == 0){
                      tempList = new List<String>();
                      tempList.add(user);
                      count++;
                  }else if( count <99 && count >0){
                      tempList.add(user);
                      count++;
                  }else{
                      tempList.add(user);
                      usersList.add(tempList);
                      count=0;
                  }  
              }
              
              if(count <99 && count >0){
                  usersList.add(tempList);
              }
              
             for(List<String> mailUser : usersList){
               // try{
                    sendPaymentSettlementNotificationEmail(mailUser);      
               // }catch(Exception e){
                   // apexpages.message err = 
                     //   new apexpages.message(apexpages.severity.error, 
                       //                 e.getMessage());
                    //apexpages.addmessage(err); 
                    
                    //return;
                 //   System.debug('Send email in settlement batch ');
                    
                //}
             }
               //EmailTemplate  emailTemplate = [select Id,Name,Subject,body,HtmlValue from EmailTemplate where name = 'ASI KOR SR Payment Details Creation'];
              //sendEmailUpdateCompletion(currentProposal,emailTemplate);
           
    }
    
     public void sendPaymentSettlementNotificationEmail(List<String> UserIDs){
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      List<User> recepients = [Select Name , email from User where ID IN :UserIDs ];
      List<String> toAddresses = new List<String>();
      for(User recepient : recepients ){
      
          toAddresses.add(recepient.email);
      
      }
      mail.setToAddresses(toAddresses);
      //Mailing Subject
      String mailingSubject = 'Trade Spend Cycle Start Notification – Payment Settlement';
      mail.setSubject(mailingSubject);
      
      //Mailing Message
        
       String mailingMessage  = 'Trade Spend Cycle Start Notification – Payment Settlement'+'\r\n\r\n';
          
          mailingMessage  += 'Year: '  + yearProposal+ '\r\n';
          mailingMessage  += 'Month: '  + monthProposal +  '\r\n';
          mailingMessage  += 'Cut-off Date: '  + cutOffDate.year()+ '-' + cutOffDate.month() + '-' + cutOffDate.day()+  '\r\n\r\n';
          mailingMessage  += 'VMS depletion data has been uploaded into the system, and the incentive calculation has been completed.'+  '\r\n';
          mailingMessage  += 'Now you can start your process for CA settlement. '+  '\r\n\r\n';
          mailingMessage  += 'Thanks.'+  '\r\n\r\n';
      mail.setPlainTextBody(mailingMessage);
      mail.setEmailPriority('High');
      try{
          Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
      }catch(Exception e){
          System.debug('XXX Email ' + e.getMessage());
      } 

 }

}