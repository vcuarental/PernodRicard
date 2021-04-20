/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Tony Ren                                                                  
+-----------------------+------------------------------------------------------------------------------------+
| Description           | For ASI Korea user                                                                              
|                       |                                                                                    
|     - Object(s)       | POSM Order Request
|     - Description     |  High value POSM Email  
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 26/01/2017                                                                       
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
*/
public class ASI_MFM_KR_HVPOSM_ApprovalEmailCtrl {
    public Id receiptID {get;set;}
    public ASI_KOR_POSM_Order_Request__c POSMheader {get;set;}
    public List<interimData> LineItems {get;set;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public integer TotalQuanity {get;set;} {TotalQuanity=0;}
    
    public Class interimData{
        public ASI_KOR_POSM_Order_Detail__c line {get;set;}{line = new ASI_KOR_POSM_Order_Detail__c();}
        public boolean Show{get;set;}{Show=false;}
        public interimData(ASI_KOR_POSM_Order_Detail__c inputline, boolean inputflag){
            this.line=inputline;
            this.Show=inputflag;
        }
    }
    
    public ASI_MFM_KR_HVPOSM_ApprovalEmailCtrl (){}    
    public boolean init(){
        TotalQuanity=0;
        POSMheader = [SELECT Id, Name,ASI_MFM_Current_Approver_Number__c,ASI_MFM_Total_Quantity__c,ASI_MFM_Approver_1__c , ASI_MFM_Approver_10__c , ASI_MFM_Approver_11__c , ASI_MFM_Approver_2__c , ASI_MFM_Approver_3__c , ASI_MFM_Approver_4__c , ASI_MFM_Approver_5__c , ASI_MFM_Approver_6__c , ASI_MFM_Approver_7__c , ASI_MFM_Approver_8__c , ASI_MFM_Approver_9__c
                      FROM ASI_KOR_POSM_Order_Request__c 
                      WHERE Id = :receiptID LIMIT 1];
        
        List<ASI_KOR_POSM_Order_Detail__c> TempList=[select id,ASI_MFM_Venue__r.Owner.ASI_KOR_User_Branch_Name__c,ASI_MFM_Venue__r.Name,
                                                     ASI_MFM_Venue__r.Owner.ASI_KOR_User_Branch_Code__c,ASI_MFM_KR_C_S__c,ASI_KOR_Quantity__c,
                                                     ASI_MFM_Venue__r.ASI_KOR_Venue_Capacity__c,ASI_KOR_SubBrand__r.ASI_MFM_Brand__r.Name,
                                                     ASI_MFM_Venue__r.Owner.Name,ASI_MFM_Total_PRK_Capa__c,ASI_MFM_Venue__c
                                                     ,ASI_KOR_Item_Name__c,ASI_KOR_Item_Name__r.ASI_MFM_Product_Owner__c ,ASI_KOR_Item_Name__r.Name
                                                     from ASI_KOR_POSM_Order_Detail__c where ASI_KOR_POSM_Order_Request__c =: receiptID ];
        
        set<String> VenueIDSet=new set<String>();
        for(ASI_KOR_POSM_Order_Detail__c posml: TempList){
            VenueIDSet.add(posml.ASI_MFM_Venue__c);
        }
        
        Map<ID, ASI_CRM_AccountsAdditionalField__c> mapCustomer = new Map<ID,ASI_CRM_AccountsAdditionalField__c>();
        List<ASI_CRM_AccountsAdditionalField__c> CustomerList = [select Id,Name,ASI_CRM_Account__c,ASI_CRM_Outlet_Image__c 
                                                                 from ASI_CRM_AccountsAdditionalField__c
                                                                 where ASI_CRM_Account__c in : VenueIDSet 
                                                                 and RecordType.DeveloperName like 'ASI_CRM_KR%' ];
        for(ASI_CRM_AccountsAdditionalField__c cus:CustomerList){
            if(!mapCustomer.containsKey(cus.ASI_CRM_Account__c)){
                mapCustomer.put(cus.ASI_CRM_Account__c, cus);
            }
        }
        
        
        LineItems= new List<interimData>();
        String ApproverNumNow = String.valueOf(POSMheader.ASI_MFM_Current_Approver_Number__c);
        
        String ProductOwnerId;
        if(POSMheader.ASI_MFM_Current_Approver_Number__c!=0 && POSMheader.get('ASI_MFM_Approver_'+ApproverNumNow+'__c')!=null){
            ProductOwnerId = String.valueOf(POSMheader.get('ASI_MFM_Approver_'+ApproverNumNow+'__c')) ;
        }
        
        for(ASI_KOR_POSM_Order_Detail__c pl:TempList){
            if(pl.ASI_MFM_Venue__c!=null && mapCustomer.containsKey(pl.ASI_MFM_Venue__c)){
                pl.ASI_KOR_UOM__c=mapCustomer.get(pl.ASI_MFM_Venue__c).ASI_CRM_Outlet_Image__c;
            }else{
                pl.ASI_KOR_UOM__c='';
            }
            
            if(POSMheader.ASI_MFM_Current_Approver_Number__c==0){// all true
                LineItems.add(new interimData (pl,true));
                TotalQuanity+=integer.valueOf(pl.ASI_KOR_Quantity__c);
            }else{
                if(ProductOwnerId==pl.ASI_KOR_Item_Name__r.ASI_MFM_Product_Owner__c){
                    LineItems.add(new interimData (pl,true));
                      TotalQuanity+=integer.valueOf(pl.ASI_KOR_Quantity__c);
                }
            }
        }
        
        return true;  
    }
}