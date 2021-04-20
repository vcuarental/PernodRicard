public with sharing class ASI_CRM_KR_PVADisplayController {
    
    public ApexPages.StandardController standardController {get;set;}
    public Account AccountHeader { get; set; }
    public List<ASI_CRM_KR_PVA__c> VPALine {get;set;} {VPALine = new List<ASI_CRM_KR_PVA__c>();}  
    public List<ASI_CRM_AccountsAdditionalField__c> AdditonalFieldsList {get;set;} {AdditonalFieldsList = new List<ASI_CRM_AccountsAdditionalField__c>();}  
    public Account header{get;set;}
    public boolean HasVPALine {set;get;}
 
    
    //Customer Object - Additional Fields
    public ASI_CRM_AccountsAdditionalField__c accountAdditionalField  { get; set; }
    
	public ASI_CRM_KR_PVADisplayController(ApexPages.StandardController standardController){
        this.standardController = standardController;
        this.header = (Account)standardController.getRecord();
        
        AccountHeader = new Account();
        this.VPALine = new List<ASI_CRM_KR_PVA__c>();   
        
        if(header.id != null){
            AccountHeader = [SELECT id, NAME,ASI_KOR_Venue_Name__pc,ASI_KOR_Venue_Channel__c, 
                             ASI_KOR_Venue_Pillar__c ,ASI_KOR_Venue_Type__c, RecordTypeid,
                             ASI_KOR_Wholesaler_Channel__c
                             FROM Account WHERE Id =: header.id];   
             
            
            List<ASI_CRM_AccountsAdditionalField__c> AdditonalFieldsList = [SELECT id, NAME, ASI_CRM_Outlet_Image__c, 
                                                                            ASI_CRM_KR_Venue_Type__c, ASI_CRM_Strategic_Outlet_Mapping__c,
                                                                            ASI_CRM_Account__c,RecordTypeid
                                                from  ASI_CRM_AccountsAdditionalField__c 
                                                where ASI_CRM_Account__c =: header.id];    
                           
            //system.assertEquals(AdditonalFieldsList, null);
            
          
            if(AdditonalFieldsList.isEmpty()){
            accountAdditionalField = new ASI_CRM_AccountsAdditionalField__c();
            //accountAdditionalField.RecordType.DeveloperName = '';
            accountAdditionalField.RecordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue');
            accountAdditionalField.Name = AccountHeader.name;
            accountAdditionalField.ASI_CRM_Account__c = standardController.getRecord().id;
            //AdditonalFieldsList.add(accountAdditionalField);    
            }
            
            else{
                for(ASI_CRM_AccountsAdditionalField__c listcust : AdditonalFieldsList){
                    accountAdditionalField = new ASI_CRM_AccountsAdditionalField__c();
                    //accountAdditionalField.RecordType.DeveloperName = '';
                    accountAdditionalField.RecordTypeid = listcust.RecordTypeid;
                    accountAdditionalField.Name = listcust.name;
                    accountAdditionalField.ASI_CRM_Outlet_Image__c = listcust.ASI_CRM_Outlet_Image__c;
                    accountAdditionalField.ASI_CRM_KR_Venue_Type__c = listcust.ASI_CRM_KR_Venue_Type__c;
                    accountAdditionalField.ASI_CRM_Strategic_Outlet_Mapping__c = listcust.ASI_CRM_Strategic_Outlet_Mapping__c;
                    accountAdditionalField.ASI_CRM_Account__c = standardController.getRecord().id;
                }
                
            }
           
          
        } 
        
    }  
    
    
    public void init() {
        
        HasVPALine = TRUE;
                
        if(this.header !=null && this.header.Id !=null){
           
            VPALine = [SELECT ASI_CRM_KR_Brand__c,ASI_CRM_KR_Brand__r.name, ASI_CRM_KR_Check__c, ASI_CRM_KR_PVA__c,
                       	ASI_CRM_KR_Channel__c, 	ASI_CRM_KR_Outlet_Image__c,ASI_CRM_KR_Brand__r.ASI_KOR_Brand_Code__c
                        FROM ASI_CRM_KR_PVA__c 
                        WHERE ASI_CRM_KR_Check__c = true AND 
                      	ASI_CRM_KR_Outlet_Image__c =: accountAdditionalField.ASI_CRM_Outlet_Image__c AND
                        ASI_CRM_KR_Channel__c =: AccountHeader.ASI_KOR_Wholesaler_Channel__c
                        Order by ASI_CRM_KR_Brand__r.ASI_KOR_Sequence__c //ASI_CRM_KR_Brand__r.name, 
                      ];
            
        }   
        
        if(VPALine.isEmpty() || VPALine == NULL || VPALine.SIZE()==0){
               HasVPALine = FALSE;
        }   
      
    }
}