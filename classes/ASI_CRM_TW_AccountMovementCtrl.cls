public with sharing class ASI_CRM_TW_AccountMovementCtrl {
    public AccountMovementPage accountMovementPage { get; set; } 
    
    private List<ASI_CRM_AccountMovement__c> movements;
    private Map<String,Account> accountMap;
    private String checkSoql = '';

    public ASI_CRM_TW_AccountMovementCtrl(ApexPages.StandardController controller) {
        accountMovementPage = new AccountMovementPage();
        search();      
    }
   
    public void search(){
        String searchUpdateDateTime = '';
        String soql = 'SELECT Id, ASI_CRM_Account__r.Id,ASI_CRM_Account__r.Name,ASI_CRM_Approved__c, ASI_CRM_Account__r.ASI_KOR_Customer_Code__c, Owner.Name, ASI_CRM_Field__c, ASI_CRM_IsDeleted__c, ASI_CRM_NewValueName__c, ASI_CRM_NewValue__c, ASI_CRM_OldValueName__c, ASI_CRM_OldValue__c, ASI_CRM_Rejected__c, ASI_CRM_UpdateDateTime__c,ASI_CRM_RejectedReason__c, ASI_CRM_Account__r.Owner.Name, LastModifiedBy.name FROM ASI_CRM_AccountMovement__c WHERE ASI_CRM_Account__c != null AND ASI_CRM_Approved__c = FALSE AND ASI_CRM_IsDeleted__c = FALSE AND ASI_CRM_Rejected__c = FALSE';    
        checkSoql = soql;
    
        if(AccountMovementPage.region != null){
            soql = soql + ' AND ASI_CRM_Account__r.ASI_TH_CRM_Region__c = \'' + AccountMovementPage.region + '\'';
        }
        
        if(AccountMovementPage.channel != null){
            soql = soql + ' AND ASI_CRM_Account__r.ASI_HK_CRM_Channel__c = \'' + AccountMovementPage.channel + '\'';
        }
        
        if(AccountMovementPage.subChannel != null){
            soql = soql + ' AND ASI_CRM_Account__r.Sub_Channel__c = \'' + AccountMovementPage.subChannel + '\'';
        }

        //System.debug('AccountMovementPage.updateDate.ASI_CRM_UpdateDateTime__c:' + AccountMovementPage.updateDate.ASI_CRM_UpdateDateTime__c);     
        
        if(AccountMovementPage.updateDate.ASI_CRM_UpdateDateTime__c != null){
            searchUpdateDateTime = AccountMovementPage.updateDate.ASI_CRM_UpdateDateTime__c.format('YYYY-MM-dd');
        }        
                        
        //System.debug('soql:' + soql);        
        soql = soql + ' ORDER BY ASI_CRM_Account__r.ASI_KOR_Customer_Code__c ASC, ASI_CRM_UpdateDateTime__c DESC LIMIT 250';
    
        movements = Database.query(soql);
        
        accountMovementPage.accountMovementMap = new Map<String, AccountMovement>();
        accountMap = new Map<String,Account>();
        //System.debug('movements:' + movements);
        for(ASI_CRM_AccountMovement__c movement : movements){
            String updateDateTime = movement.ASI_CRM_UpdateDateTime__c.format('YYYY-MM-dd HH:mm:ss');
            
            if(!(searchUpdateDateTime != null && searchUpdateDateTime != '' && !updateDateTime.contains(searchUpdateDateTime))){
                accountMap.put(movement.ASI_CRM_Account__r.ASI_KOR_Customer_Code__c,movement.ASI_CRM_Account__r);
         
                AccountMovement accountMovement = accountMovementPage.accountMovementMap.get(movement.ASI_CRM_Account__r.ASI_KOR_Customer_Code__c + updateDateTime);
                if (accountMovement == null){
                    accountMovement = new AccountMovement();
                    accountMovement.updateDateTime = updateDateTime;
                }
                accountMovement.Modifiedby = movement.Owner.Name;
                //accountMovement.isApproved = true;
                accountMovement.accountMap.put(movement.ASI_CRM_Field__c, movement);  
                //System.debug('Add field change ' + movement.ASI_CRM_Field__c + ' : ' + accountMovement.accountMap);
                accountMovementPage.accountMovementMap.put(movement.ASI_CRM_Account__r.ASI_KOR_Customer_Code__c + updateDateTime, accountMovement);
            }
        }
        
        List<ASI_CRM_AccountsAdditionalField__c> accountAdditionals = [SELECT Id, ASI_CRM_IsParentAccount__c, ASI_CRM_Approval_Status__c, ASI_CRM_Account__r.Id,Name,ASI_CRM_CN_Legal_Name__c,ASI_CRM_Account__r.ASI_KOR_Customer_Code__c,ASI_CRM_Account__r.ASI_HK_CRM_JDE_Account_Number__c, ASI_CRM_CN_Address__c,ASI_CRM_CN_Inactive_Flag__c, Owner.Id, Owner.Name, ASI_TH_CRM_OutletType__r.Id, ASI_TH_CRM_OutletType__r.Name,ASI_CRM_CN_Grade__c,ASI_CRM_Sales_Potential__c,ASI_CRM_Region__c,ASI_CRM_Channel__r.Name,ASI_CRM_CN_Sub_Channel__r.Name,ASI_CRM_ToJDE__c,ASI_CRM_TW_canUpdate__c, ASI_CRM_Account__r.Owner.Name, LastModifiedBy.Name, ASI_TH_CRM_OutletImage__c, ASI_TH_CRM_OutletImage__r.Name, ASI_CRM_TW_Warehouse_Address__c, ASI_CRM_TW_Invoice_Address__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__r.ASI_KOR_Customer_Code__c IN :accountMap.keySet() FOR UPDATE];
    
        for(String key: accountMovementPage.accountMovementMap.keySet()){
            AccountMovement accountMovement = accountMovementPage.accountMovementMap.get(key);
          
            for(ASI_CRM_AccountsAdditionalField__c accountAdditional : accountAdditionals){                    
                if (key.contains(accountAdditional.ASI_CRM_Account__r.ASI_KOR_Customer_Code__c)){           
                    accountMovement.accountAdditional = accountAdditional;
                }           
            }
            
            if(accountMovement.accountAdditional == null){
                accountMovement.accountAdditional = new ASI_CRM_AccountsAdditionalField__c();
            }                
        }           
    }
    
    public void reset(){
        accountMovementPage = new AccountMovementPage();

        search();     
    }
    
    public void save(){
        Map<String, ASI_CRM_AccountsAdditionalField__c> accountAdditionals = new Map<String,ASI_CRM_AccountsAdditionalField__c>();
    
        for(String key : accountMovementPage.accountMovementMap.keySet()){
            AccountMovement accountMovement = accountMovementPage.accountMovementMap.get(key);
          
            if (accountMovement.isApproved){
                //Set new Account ASI_CRM_ToJDE__c flag to true    
                if(accountMovement.accountAdditional.ASI_CRM_ToJDE__c == false){    
                    //Remarked by William Yang (Introv) 20141217 to allow re-approve Rejected Outlet
                    //if(accountMovement.accountMap.get('Name') != null){
                        //ASI_CRM_AccountMovement__c movement = accountMovement.accountMap.get('Name');
                        //if(movement.ASI_CRM_OldValue__c == null){                       
                            accountMovement.accountAdditional.ASI_CRM_ToJDE__c = true;
                            
                            for(String key1 : accountMovementPage.accountMovementMap.keySet()){
                                AccountMovement accountMovement1 = accountMovementPage.accountMovementMap.get(key1);
                                if(accountMovement.accountAdditional.Id == accountMovement1.accountAdditional.Id){
                                    accountMovement1.accountAdditional.ASI_CRM_ToJDE__c = true;
                                }
                            }
                            
                            break;
                        //}    
                    //}
                }
             }
         }
         
        for(String key : accountMovementPage.accountMovementMap.keySet()){
            AccountMovement accountMovement = accountMovementPage.accountMovementMap.get(key);
            if (accountMovement.isApproved || accountMovement.isDeleted) 
                accountAdditionals.put(accountMovement.accountAdditional.Id,accountMovement.accountAdditional);
                
            if (accountMovement.isApproved || (accountMovement.isDeleted && accountMovement.accountAdditional.ASI_CRM_ToJDE__c == false)){              
                ASI_CRM_AccountMovement__c movement = null;        
                boolean needUpdate = false;     
                
                //Modified by William Yang 20141217
                if(accountMovement.isApproved)
                    accountMovement.accountAdditional.ASI_CRM_Approval_Status__c= '';
                
                //Updated by William Yang(Introv)20141217 to fix Rejected status if being rejected for the second time
                if(accountMovement.isDeleted && accountMovement.accountAdditional.ASI_CRM_ToJDE__c == false ) 
                {
                    System.debug('ToJDE = ' + accountMovement.accountAdditional.ASI_CRM_ToJDE__c);
                    accountMovement.accountAdditional.ASI_CRM_Approval_Status__c= 'Rejected';
                    System.debug('Status = ' + accountMovement.accountAdditional.ASI_CRM_Approval_Status__c);
                    needUpdate = true;
                }
                
                if(accountMovement.accountMap.get('Name') != null){
                    movement = accountMovement.accountMap.get('Name');
                    /*
                    if(accountMovement.isDeleted && accountMovement.name.contains('[New Account]')){
                        accountMovement.accountAdditional.ASI_CRM_Approval_Status__c= 'Rejected';
                    }
                    */
                    accountMovement.accountAdditional.Name = movement.ASI_CRM_NewValue__c;
                    
                    needUpdate = true;
                }
                // End update by William Yang (Introv) 20141217
                
                if(accountMovement.accountMap.get('ASI_CRM_CN_Legal_Name__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_CN_Legal_Name__c');
                    accountMovement.accountAdditional.ASI_CRM_CN_Legal_Name__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                } 
                
                if(accountMovement.accountMap.get('ASI_CRM_City__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_City__c');
                    accountMovement.accountAdditional.ASI_CRM_City__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }                

                if(accountMovement.accountMap.get('ASI_CRM_Town__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_Town__c');
                    accountMovement.accountAdditional.ASI_CRM_Town__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_TW_Street__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Street__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Street__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_TW_Section__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Section__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Section__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }                

                if(accountMovement.accountMap.get('ASI_CRM_TW_Lane__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Lane__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Lane__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_TW_Alley__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Alley__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Alley__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_TW_Number__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Number__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Number__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }                

                if(accountMovement.accountMap.get('ASI_CRM_TW_Number_Hyphen__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Number_Hyphen__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Number_Hyphen__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_TW_Floor__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Floor__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Floor__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_TW_Hyphen__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Hyphen__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Hyphen__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }                                                              

                if(accountMovement.accountMap.get('ASI_CRM_TW_Suite__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Suite__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Suite__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_CN_Address__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_CN_Address__c');
                    accountMovement.accountAdditional.ASI_CRM_CN_Address__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }                

                if(accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_City__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_City__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Warehouse_City__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }                

                if(accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_Town__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_Town__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Warehouse_Town__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_Street__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_Street__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Warehouse_Street__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_Section__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_Section__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Warehouse_Section__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }                

                if(accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_Lane__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_Lane__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Warehouse_Lane__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_Alley__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_Alley__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Warehouse_Alley__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_Number__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_Number__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Warehouse_Number__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }                

                if(accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_Number_Hyphen__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_Number_Hyphen__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Warehouse_Number_Hyphen__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_Floor__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_Floor__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Warehouse_Floor__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_Hyphen__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_Hyphen__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Warehouse_Hyphen__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }                                                              

                if(accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_Suite__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_Suite__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Warehouse_Suite__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_Address__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Warehouse_Address__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Warehouse_Address__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }

                if(accountMovement.accountMap.get('ASI_CRM_TW_Invoice_City__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Invoice_City__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Invoice_City__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }                

                if(accountMovement.accountMap.get('ASI_CRM_TW_Invoice_Town__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Invoice_Town__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Invoice_Town__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_TW_Invoice_Street__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Invoice_Street__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Invoice_Street__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_TW_Invoice_Section__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Invoice_Section__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Invoice_Section__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }                

                if(accountMovement.accountMap.get('ASI_CRM_TW_Invoice_Lane__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Invoice_Lane__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Invoice_Lane__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_TW_Invoice_Alley__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Invoice_Alley__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Invoice_Alley__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_TW_Invoice_Number__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Invoice_Number__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Invoice_Number__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }                

                if(accountMovement.accountMap.get('ASI_CRM_TW_Invoice_Number_Hyphen__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Invoice_Number_Hyphen__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Invoice_Number_Hyphen__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_TW_Invoice_Floor__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Invoice_Floor__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Invoice_Floor__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_TW_Invoice_Hyphen__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Invoice_Hyphen__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Invoice_Hyphen__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }                                                              

                if(accountMovement.accountMap.get('ASI_CRM_TW_Invoice_Suite__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Invoice_Suite__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Invoice_Suite__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_TW_Invoice_Address__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_TW_Invoice_Address__c');
                    accountMovement.accountAdditional.ASI_CRM_TW_Invoice_Address__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                          
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_CN_Inactive_Flag__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_CN_Inactive_Flag__c');
                    accountMovement.accountAdditional.ASI_CRM_CN_Inactive_Flag__c = Boolean.valueOf(movement.ASI_CRM_NewValue__c);
                            
                    needUpdate = true;                         
                }
                
                if(accountMovement.accountMap.get('ASI_CRM_IsParentAccount__c') != null){
                    movement = accountMovement.accountMap.get('ASI_CRM_IsParentAccount__c');
                    accountMovement.accountAdditional.ASI_CRM_IsParentAccount__c = Boolean.valueOf(movement.ASI_CRM_NewValue__c);
                            
                    needUpdate = true;                         
                }                

                if(accountMovement.accountMap.get('ASI_TH_CRM_OutletType__c') != null){
                    movement = accountMovement.accountMap.get('ASI_TH_CRM_OutletType__c');
                    accountMovement.accountAdditional.ASI_TH_CRM_OutletType__c = movement.ASI_CRM_NewValue__c;
                            
                    needUpdate = true;                               
                }                        
                        
                if(accountMovement.accountMap.get('Owner') != null){
                    movement = accountMovement.accountMap.get('Owner');
                    
                    Account account = accountMap.get(accountMovement.accountAdditional.ASI_CRM_Account__r.ASI_KOR_Customer_Code__c);
                    if(account != null)
                    {
                        account.OwnerId = movement.ASI_CRM_NewValue__c;
                        account.ASI_KOR_Venue_Diageo_Managed__c = true;
                        account.ASI_KOR_SYS_NeedRefreshGeolocation__c = true;
                        //accountMovement.accountAdditional.OwnerId = account.OwnerId;
                        accountAdditionals.get(accountMovement.accountAdditional.id).OwnerId = account.OwnerId;
                        accountMap.put(accountMovement.accountAdditional.ASI_CRM_Account__r.ASI_KOR_Customer_Code__c,account);  
                        
                        needUpdate = true;   
                    }                   
                }
                        
                if(needUpdate){
                    accountMovement.accountAdditional.ASI_CRM_TW_canUpdate__c = true;     
                }      
            }
            
            if (accountMovement.isApproved || accountMovement.isDeleted){
                for(String field : accountMovement.accountMap.keySet()){
                    ASI_CRM_AccountMovement__c movementCurrent = accountMovement.accountMap.get(field);
                    
                    for(ASI_CRM_AccountMovement__c movement : movements){
                        if(movementCurrent.Id == movement.Id){
                            movement.ASI_CRM_Approved__c = accountMovement.isApproved;
                            movement.ASI_CRM_IsDeleted__c = accountMovement.isDeleted;
                            
                            break;
                        }
                    }
                }
            }    
            //System.debug('movements:'+ movements);             
            
        }

        //System.debug('accountAdditionals:' + accountAdditionals);
        //System.debug('movements:' + movements);
        
        //Modified by Introv @20190426 - fix approval issue by same record
        //1) check account current status
        List<ASI_CRM_AccountsAdditionalField__c> check_late_status = [SELECT Id, ASI_CRM_Approval_Status__c, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id IN :accountAdditionals.keySet() AND ASI_CRM_Approval_Status__c  != 'Pending for Approval'];
        if (check_late_status.size() > 0) {
            ApexPages.Message oCustomMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Account(s) has/have been approved/rejected!');
            ApexPages.addMessage(oCustomMsg);
            return;
        }
        //2) mark isdelete for remaining movements of same account
        Set<Id> set_check_accound_id = new Set<Id>();
        Set<Id> set_check_movement_id = new Set<Id>();
        for(ASI_CRM_AccountMovement__c movement : movements){
            set_check_accound_id.add(movement.ASI_CRM_Account__c);
            set_check_movement_id.add(movement.id);
        }
        List<ASI_CRM_AccountMovement__c> check_movements = [SELECT Id, ASI_CRM_IsDeleted__c
                                                            FROM ASI_CRM_AccountMovement__c 
                                                            WHERE ASI_CRM_Account__c != NULL AND ASI_CRM_Approved__c = FALSE AND ASI_CRM_IsDeleted__c = FALSE AND ASI_CRM_Rejected__c = FALSE
                                                           		AND Id NOT IN :set_check_movement_id AND ASI_CRM_Account__c IN :set_check_accound_id];
        if (check_movements.size() > 0) {
            for(ASI_CRM_AccountMovement__c movement : check_movements){
                movement.ASI_CRM_IsDeleted__c = TRUE;
            }
            movements.addAll(check_movements);
        }
        //End Modify @20190426
        
        //Modified by Introv @20190114
        try {
            update movements;
        } catch (System.DMLException e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
        }
        //End Modify @20191114
        
        checkSoql = checkSoql + ' AND ASI_CRM_Account__r.ASI_KOR_Customer_Code__c IN (';
        for(String key : accountMap.keySet()){
            checkSoql = checkSoql + '\'' + key + '\',';        
        }
        //Modified by William Yang 20140711
        //checkSoql = checkSoql + '\'\')';
        checkSoql = checkSoql + '\'\')';
        
        List<ASI_CRM_AccountMovement__c> checkMovements = Database.query(checkSoql);
        
        for(String key : accountAdditionals.keySet()){
            ASI_CRM_AccountsAdditionalField__c accountAdditional = accountAdditionals.get(key);
            //Updated by William Yang(Introv) to allow editing Rejected Outlet
            if(accountAdditional.ASI_CRM_Approval_Status__c != 'Rejected'){
                accountAdditional.ASI_CRM_Approval_Status__c = '';
                System.debug('Status = ' + accountAdditional.ASI_CRM_Approval_Status__c);
                
                for(ASI_CRM_AccountMovement__c movement : checkMovements ){
                    if(movement.ASI_CRM_Account__r.Id == accountAdditional.ASI_CRM_Account__r.Id){
                        accountAdditional.ASI_CRM_Approval_Status__c = 'Pending for Approval';
                        break;
                    }
                }
            }
        }
        if(accountMap != null && accountMap.size() > 0)
            try {
                update accountMap.values();
            } catch (System.DMLException e)
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                ApexPages.addMessage(myMsg);
            }
            
        if(accountAdditionals != null && accountAdditionals.size() > 0 )
            try {
                update accountAdditionals.values();
            } catch (System.DMLException e)
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                ApexPages.addMessage(myMsg);
            }
            
        search();
    }
    
    public class AccountMovementPage{
        public String region { get; set; }
        public String channel { get; set; }
        public String subChannel { get; set; }
        public String finel { get; set; }
        public ASI_CRM_AccountMovement__c updateDate { get; set; }
        public String status { get; set; }
        
        public AccountMovementPage(){
            updateDate = new ASI_CRM_AccountMovement__c();
        }
 
        public List<SelectOption> regions {
            get{
                Schema.sObjectType objType = ASI_CRM_AccountsAdditionalField__c.getSObjectType();
                Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
                Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
                List<Schema.PicklistEntry> values = fieldMap.get('ASI_CRM_Region__c').getDescribe().getPickListValues();
                
                List<SelectOption> regions = new List<SelectOption>();
                regions.add(new SelectOption('', ''));
                
                for(Schema.PicklistEntry picklist: values){
                    regions.add(new SelectOption(picklist.getLabel(), picklist.getValue()));
                }
                return regions;
            }
        }
        
        public List<SelectOption> channels {
            get{
                List<ASI_CRM_CN_Channel__c> channelList = [SELECT id, Name FROM ASI_CRM_CN_Channel__c WHERE RecordType.DeveloperName = 'ASI_CRM_TW_Channel'];
                
                List<SelectOption> channels = new List<SelectOption>();
                channels.add(new SelectOption('', ''));
                
                for(ASI_CRM_CN_Channel__c channel : channelList){
                    channels.add(new SelectOption(channel.Name, channel.Name));
                }
                return channels;
            }
        }
        
        public List<SelectOption> subChanels {
            get{
                List<ASI_MFM_Sub_Channel__c> subChannelList = [SELECT id, Name FROM ASI_MFM_Sub_Channel__c WHERE RecordType.DeveloperName = 'ASI_CRM_TW_SubChannel'];
                
                List<SelectOption> subChannels = new List<SelectOption>();
                subChannels.add(new SelectOption('', ''));
                
                for(ASI_MFM_Sub_Channel__c subChannel : subChannelList){
                    subChannels.add(new SelectOption(subChannel.Name, subChannel.Name));
                }
                return subChannels;
            }
        }                   
        
        public Map<String,AccountMovement> accountMovementMap { get; set; }
    }
    
    public class AccountMovement{
        public ASI_CRM_AccountsAdditionalField__c accountAdditional {get; set;}
        
        Map<String,ASI_CRM_AccountMovement__c> accountMap {get; set;}       
        
        public AccountMovement(){
            accountMap = new Map<String,ASI_CRM_AccountMovement__c>();
        }
        
        public String updateDateTime {get; set;}
        public boolean isApproved {get; set;}
        public boolean isDeleted {get; set;} 
        
        public String highlight(String str){
            if(str == null) return str;
            return '<span style="color:red"><b>' + str + '</b></span>';
        }        
        
        public String name {
            get{
                if(accountMap.get('Name') != null){
                    ASI_CRM_AccountMovement__c accountMovement = accountMap.get('Name');
                    
                    return highlight((accountMovement.ASI_CRM_OldValue__c == null?'[New Account]':accountMovement.ASI_CRM_OldValue__c) + ' --> ' + accountMovement.ASI_CRM_NewValue__c);
                }else{
                    return accountAdditional.Name;
                }
            }
        }
        
        public String legalName{
            get{
                if(accountMap.get('ASI_CRM_CN_Legal_Name__c') != null){
                    ASI_CRM_AccountMovement__c accountMovement = accountMap.get('ASI_CRM_CN_Legal_Name__c');
                    
                    return highlight((accountMovement.ASI_CRM_OldValue__c == null?'[Empty]':accountMovement.ASI_CRM_OldValue__c) + ' --> ' + (accountMovement.ASI_CRM_NewValue__c == null?'':accountMovement.ASI_CRM_NewValue__c)) ;
                }else{
                    return accountAdditional.ASI_CRM_CN_Legal_Name__c;
                }
            }
        }
        
        public String address{
            get{
                if(accountMap.get('ASI_CRM_CN_Address__c') != null){
                    ASI_CRM_AccountMovement__c accountMovement = accountMap.get('ASI_CRM_CN_Address__c');
                    
                    return highlight((accountMovement.ASI_CRM_OldValue__c == null?'[Empty]':accountMovement.ASI_CRM_OldValue__c) + ' --> ' + (accountMovement.ASI_CRM_NewValue__c == null?'':accountMovement.ASI_CRM_NewValue__c));
                }else{
                    return accountAdditional.ASI_CRM_CN_Address__c;
                }
            }
        } 

        public String warehouseAddress{
            get{
                if(accountMap.get('ASI_CRM_TW_Warehouse_Address__c') != null){
                    ASI_CRM_AccountMovement__c accountMovement = accountMap.get('ASI_CRM_TW_Warehouse_Address__c');
                    
                    return highlight((accountMovement.ASI_CRM_OldValue__c == null?'[Empty]':accountMovement.ASI_CRM_OldValue__c) + ' --> ' + (accountMovement.ASI_CRM_NewValue__c == null?'':accountMovement.ASI_CRM_NewValue__c));
                }else{
                    return accountAdditional.ASI_CRM_TW_Warehouse_Address__c;
                }
            }
        } 

        public String invoiceAddress{
            get{
                if(accountMap.get('ASI_CRM_TW_Invoice_Address__c') != null){
                    ASI_CRM_AccountMovement__c accountMovement = accountMap.get('ASI_CRM_TW_Invoice_Address__c');
                    
                    return highlight((accountMovement.ASI_CRM_OldValue__c == null?'[Empty]':accountMovement.ASI_CRM_OldValue__c) + ' --> ' + (accountMovement.ASI_CRM_NewValue__c == null?'':accountMovement.ASI_CRM_NewValue__c));
                }else{
                    return accountAdditional.ASI_CRM_TW_Invoice_Address__c;
                }
            }
        } 

        public String activation{
            get{
                if(accountMap.get('ASI_CRM_CN_Inactive_Flag__c') != null){
                    ASI_CRM_AccountMovement__c accountMovement = accountMap.get('ASI_CRM_CN_Inactive_Flag__c');
                    
                    return highlight((accountMovement.ASI_CRM_OldValue__c == null?'[Empty]':(accountMovement.ASI_CRM_OldValue__c == 'true'?'Z':'D')) + ' --> ' + (accountMovement.ASI_CRM_NewValue__c == null?'':(accountMovement.ASI_CRM_NewValue__c == 'true'?'Z':'D')));
                }else{
                    return (accountAdditional.ASI_CRM_CN_Inactive_Flag__c == true ? 'Z' : 'D');
                }
            }
        } 
 
         public String isParentAccount{
            get{
                if(accountMap.get('ASI_CRM_IsParentAccount__c') != null){
                    ASI_CRM_AccountMovement__c accountMovement = accountMap.get('ASI_CRM_IsParentAccount__c');
                    
                    return highlight((accountMovement.ASI_CRM_OldValue__c == null?'[Empty]':(accountMovement.ASI_CRM_OldValue__c == 'true'?'Yes':'No')) + ' --> ' + (accountMovement.ASI_CRM_NewValue__c == null?'':(accountMovement.ASI_CRM_NewValue__c == 'true'?'Yes':'No')));
                }else{
                    return (accountAdditional.ASI_CRM_IsParentAccount__c == true?'Yes':'No');
                }
            }
        }
        
        public String owner{
            get{
                if(accountMap.get('Owner') != null){
                    ASI_CRM_AccountMovement__c accountMovement = accountMap.get('Owner');
                    
                    return highlight((accountMovement.ASI_CRM_OldValueName__c == null?'[New Account]':accountMovement.ASI_CRM_OldValueName__c ) + ' --> ' + (accountMovement.ASI_CRM_NewValueName__c == null?'':accountMovement.ASI_CRM_NewValueName__c ));
                }else{
                    return accountAdditional.ASI_CRM_Account__r.Owner.Name;
                }
            }
        }
        
        public String ModifiedBy {get;set;}
        
        public String outletType{
            get{
                if(accountMap.get('ASI_TH_CRM_OutletType__c') != null){
                    ASI_CRM_AccountMovement__c accountMovement = accountMap.get('ASI_TH_CRM_OutletType__c');
                    
                    return highlight((accountMovement.ASI_CRM_OldValueName__c == null?'[Empty]':accountMovement.ASI_CRM_OldValueName__c ) + ' --> ' + (accountMovement.ASI_CRM_NewValueName__c == null?'':accountMovement.ASI_CRM_NewValueName__c ));
                }else{
                    return accountAdditional.ASI_TH_CRM_OutletType__r.Name;
                }
            }
        }
        
        //Added by Twinkle Li 20150417
        public String outletImage{
            get{
                if(accountMap.get('ASI_TH_CRM_OutletImage__c') != null){
                    ASI_CRM_AccountMovement__c accountMovement = accountMap.get('ASI_TH_CRM_OutletImage__c');
                    
                    return highlight((accountMovement.ASI_CRM_OldValueName__c == null?'[Empty]':accountMovement.ASI_CRM_OldValueName__c ) + ' --> ' + (accountMovement.ASI_CRM_NewValueName__c == null?'':accountMovement.ASI_CRM_NewValueName__c ));
                }else{
                    return accountAdditional.ASI_TH_CRM_OutletImage__r.Name;
                }
            }
        }
        //End by Twinkle Li 20150417
        
        public String rejectReason{
            get{
                if(accountMap.get('Name') != null){
                    ASI_CRM_AccountMovement__c accountMovement = accountMap.get('Name');
                    return accountMovement.ASI_CRM_RejectedReason__c;
                }
                return null;                
            }
        }                                                
    }
}