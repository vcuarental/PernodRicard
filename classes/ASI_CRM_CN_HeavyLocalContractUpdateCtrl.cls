public without sharing  class ASI_CRM_CN_HeavyLocalContractUpdateCtrl {
    public string new_action;
    ASI_TH_CRM_Contract__c ContractSelected = new ASI_TH_CRM_Contract__c();
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;}
    public String Msg {get;set;} {Msg='';}
    
    public ASI_CRM_CN_HeavyLocalContractUpdateCtrl(apexpages.standardController sc) {
        new_action = apexpages.currentPage().getParameters().get('action');
        ContractSelected = [SELECT Id,ASI_CRM_CN_Contract_Upload__c,ownerId,ASI_CRM_CN_Last_Approved_Date__c,recordTypeId,ASI_CRM_Last_RBA_Approver__c,Name, ASI_CRM_CN_Two_Party_Contract_Template__c,ASI_CRM_CN_No_of_Months__c,ASI_CRM_CN_Outlet_WS__r.Name,ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_CRM_CN_Status__c,ASI_CRM_Martell_BC_Rate__c,
                            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,ASI_CRM_Contract_Template_Id__c,
                            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c,ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c FROM ASI_TH_CRM_Contract__c where id = :sc.getId()];
    }
    
    public pageReference PerformAction() {
        UpsertPermission=true;
        Msg='';
        
        
        if(new_action=='UploadComplete'){
            List<Attachment> AttachmentList  = new List<Attachment>();
            if(ContractSelected.ASI_CRM_CN_Last_Approved_Date__c!=null){
                AttachmentList = [select id,createdDate  from Attachment WHERE ParentId = : ContractSelected.Id and createdDate >: ContractSelected.ASI_CRM_CN_Last_Approved_Date__c ];
            }else{
                AttachmentList = [select id,createdDate  from Attachment WHERE ParentId = : ContractSelected.Id ];
            }
            
            if(AttachmentList.size()>0 && ContractSelected.ASI_CRM_Last_RBA_Approver__c !=null ){
                ContractSelected.ASI_CRM_CN_Contract_Upload__c=true;
                update ContractSelected;
                Msg+='Upload completed.';
                UpsertPermission=true;
                
                try{
                    User ContractOwner = [Select id, Email from User Where id= :ContractSelected.ASI_CRM_Last_RBA_Approver__c ];
                    String templateApiName='ASI_CRM_CN_Heavy_LGC_UC_Email';
                    List <String> ToAddresses=  new List <String>();
                    id  templateId = [select id, name from EmailTemplate where developername = : templateApiName].id; 
                    ToAddresses.add(ContractOwner.email);
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                    email.setTargetObjectId(ContractSelected.ownerId);
                    email.setToAddresses( ToAddresses ); 
                    email.setWhatId(ContractSelected.Id);
                    email.setSaveAsActivity(false);
                    email.setBccSender(false);
                    email.setUseSignature(false);
                    email.setTemplateId(templateId);
                    if(!Test.isRunningTest()){
                        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                    }
                }catch(dmlException e){
                    ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyLocalContractUpdateCtrl.PerformAction. UploadComplete <br/>  have Error  '+'Save Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_HeavyLocalContractUpdateCtrl','Calculation function failed! with contract Id: '+ContractSelected.id );
                    
                }
                
                
            }else{
                Msg+=System.Label.ASI_CRM_CN_Upload_Contract_Msg;
                UpsertPermission=false;
            }            
        }else if(new_action=='UncheckUploadCompletion'){
            Boolean BypassFlag =ASI_MFM_ByPass_Setting.CheckingBypassByCurrentUser('LGCUncheckUploadCompletion'); //select id,BypassTriggers__c from user where id= ''
            if(ContractSelected.ASI_CRM_Last_RBA_Approver__c==null && ! BypassFlag ){
                Msg+=System.Label.ASI_CRM_CN_Cant_Find_RBA_Msg;
                UpsertPermission=false;
                
            }else if( ContractSelected.ASI_CRM_Last_RBA_Approver__c!=UserInfo.getUserId() && !BypassFlag){
                Msg+='You are not RBA, cannot change this contract to Final.';
                UpsertPermission=false;
            }else{
                try{
                    ContractSelected.ASI_CRM_CN_Contract_Upload__c=false;
                    update ContractSelected;
                    
                    String templateApiName='ASI_CRM_CN_Heavy_LGC_UUC_Email';
                    
                    User ContractOwner = [Select id, Email from User Where id= :ContractSelected.ownerId ];
                    
                    List <String> ToAddresses=  new List <String>();
                    id  templateId = [select id, name from EmailTemplate where developername = : templateApiName].id; 
                    ToAddresses.add(ContractOwner.email);
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                    email.setTargetObjectId(ContractSelected.ownerId);
                    email.setToAddresses( ToAddresses ); 
                    email.setWhatId(ContractSelected.Id);
                    email.setSaveAsActivity(false);
                    email.setBccSender(false);
                    email.setUseSignature(false);
                    email.setTemplateId(templateId);
                    if(!Test.isRunningTest()){
                        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                    }
                    
                    
                }catch(dmlException e){
                    ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyLocalContractUpdateCtrl.PerformAction. UncheckUploadCompletion <br/>  have Error  '+'Save Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_HeavyLocalContractUpdateCtrl','contract Id: '+ContractSelected.id );
                }
            }
            
            
        }else if(new_action=='SetFinal'){
            //Set to Final
            User u =[select id,BypassTriggers__c from user where Id=:UserInfo.getUserId()]; 
            Boolean BypassFlag= false;
            if(u.BypassTriggers__c!=null && u.BypassTriggers__c.contains('LocalGroupContractCNSetToFinal')){
                BypassFlag=true;
            }
            
            
            if(ContractSelected.ASI_CRM_Last_RBA_Approver__c==null && !BypassFlag ){
                Msg+=System.Label.ASI_CRM_CN_Cant_Find_RBA_Msg;
                UpsertPermission=false;
                
            }else if( ContractSelected.ASI_CRM_Last_RBA_Approver__c!=UserInfo.getUserId() && !BypassFlag){
                Msg+='You are not RBA, cannot change this contract to Final.';
                UpsertPermission=false;
            }else if(!ContractSelected.ASI_CRM_CN_Contract_Upload__c){
                 Msg+='Please upload Attachments.附件还没有上传。';
                UpsertPermission=false;
            }else{
                ContractSelected.ASI_CRM_CN_Status__c='Final';
                ContractSelected.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Local_Group_Contract_Final');
                //Select All Child Contract and set status to Final 
                List <ASI_TH_CRM_Contract__c> ChildContractList = [select Id, ASI_CRM_CN_Status__c from ASI_TH_CRM_Contract__c where ASI_CRM_CN_Group_Contract__c =:ContractSelected.Id and ASI_CRM_CN_Status__c='Approved' ];
                
                try{
                    
                    
                    //Sending Final email template to Contract Owner
                    User ContractOwner = [Select id, Email from User Where id= :ContractSelected.ownerId ];
                    String templateApiName='ASI_CRM_CN_Heavy_LGC_Final_Email';
                    List <String> ToAddresses=  new List <String>();
                    id  templateId = [select id, name from EmailTemplate where developername = : templateApiName].id; 
                    ToAddresses.add(ContractOwner.email);
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                    email.setTargetObjectId(ContractSelected.ownerId);
                    email.setToAddresses( ToAddresses ); 
                    email.setWhatId(ContractSelected.Id);
                    email.setSaveAsActivity(false);
                    email.setBccSender(false);
                    email.setUseSignature(false);
                    email.setTemplateId(templateId);
                    if(!Test.isRunningTest()){
                        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                    }
                    
                    
                    
                    //Set header to Final 
                    update ContractSelected;
                    
                    for(ASI_TH_CRM_Contract__c Contarct:ChildContractList ){
                        Contarct.ASI_CRM_CN_Status__c='Final';
                    }
                    
                    if(ChildContractList.size()>0){
                        update ChildContractList;
                    }
                    
                    Msg+='Change successfully to Final.合同已批准.';
                }catch(dmlException e){
                    ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyLocalContractUpdateCtrl<br/> class have Error  '+'Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_HeavyLocalContractUpdateCtrl','Contract Id: '+ContractSelected.Id +'new_action : '+new_action );
                }
                
            }
            
            
        }
        
        
        
        return Null;
    }
    
}