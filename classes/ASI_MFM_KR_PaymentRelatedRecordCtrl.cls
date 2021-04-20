/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Elufa                                                               
+-----------------------+------------------------------------------------------------------------------------+
| Description           | For ASI Korea user                                                                              
|                       |                                                                                    
|     - Object(s)       | Payment                                                                                
|     - Description     | Show all reltaed Plan/PR/PO/PO Receipt in ome payment                              
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 31/12/2016                                                                        
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
*/

public class ASI_MFM_KR_PaymentRelatedRecordCtrl {
    public ApexPages.StandardController standardController {get;set;}
    public ASI_MFM_Payment__c Header {get;set;}
    
    public transient List<Plan> Plans =new List<Plan>();
    public transient List<PurchaseRequest> PurchaseRequests =new List<PurchaseRequest>();
    public transient List<PO> POs {get;set;} 
    public transient List<POReceipt> POReceipts =new List<POReceipt>();
    
    
    public transient String PlanJSON  {set;get;}{PlanJSON=null;} 
    public transient String PRJSON  {set;get;}{PRJSON=null;} 
    public transient String POJSON  {set;get;}{POJSON=null;} 
    public transient String PORJSON  {set;get;}{PORJSON=null;} 
       
    private set<String> PlanSet = new set<String>();
    private set<String> PRSet = new set<String>();
    private set<String> POSet = new set<String>();
    private set<String> POLineSet = new set<String>();
    private set<String> PORSet = new set<String>();
    
    public ASI_MFM_KR_PaymentRelatedRecordCtrl(ApexPages.StandardController controller){
        this.standardController = controller;
        this.Header = (ASI_MFM_Payment__c) this.standardController.getRecord();
        POLineSet = new set<String>();
        POSet = new set<String>();
        PORSet = new set<String>();
        
        if(this.Header !=null && this.Header.Id !=null){
            for(ASI_MFM_Payment__c Payment : [Select Id,Name,ASI_MFM_Is_Direct_Payment__c, ASI_MFM_Offset_Payment__c, ASI_MFM_Cash_Out_Payment__c FROM ASI_MFM_Payment__c  where Id =: this.Header.Id limit 1]){//20180125 Introv
                this.Header = Payment;    
            } 
            
            for(ASI_MFM_Payment_Line_Item__c pl:[select Id,Name,ASI_MFM_PO_Line_Item__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c,ASI_MFM_PO_Receipt_Item__r.ASI_MFM_PO_Receipt__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c =:this.Header.Id ]){
                POLineSet.add(pl.ASI_MFM_PO_Line_Item__c);
                POSet.add(pl.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c);
                if(pl.ASI_MFM_PO_Receipt_Item__r.ASI_MFM_PO_Receipt__c!=null){
                    PORSet.add(pl.ASI_MFM_PO_Receipt_Item__r.ASI_MFM_PO_Receipt__c);
                }
            }
            
            initalize();
        }
    }
    
    public void initalize(){
        
        //
        initalizePO();
        initalizePLan();
        initalizePR();
        initalizePOReceipts(); 
        // initalizePayments();
    }
    
    
    
    
    public void initalizePO(){
        PRSet = new set<String>();
        PlanSet = new set<String>();
        POs =new List<PO>();
        if(POSet.size()>0){
            List<ASI_MFM_PO__c> POList= [select Id,Name,ASI_MFM_PO_Amount__c,ASI_MFM_PO_Raised_Date__c,ASI_MFM_Status__c,ASI_MFM_Plan__c,ASI_MFM_Purchase_Request__c,ASI_MFM_Currency__c, 
                                         (select Id,Name,ASI_MFM_PO_Amount__c,ASI_MFM_PO_Remark__c,ASI_MFM_G_L_Date__c,ASI_MFM_Amount__c  FROM PO_Line_Items__r) 
                                         from ASI_MFM_PO__c where id in : POSet ];
            for(ASI_MFM_PO__c PurchaseOrder:POList){
                PlanSet.add(PurchaseOrder.ASI_MFM_Plan__c);
                PRSet.add(PurchaseOrder.ASI_MFM_Purchase_Request__c);
                List<ASI_MFM_PO_Line_Item__c> POLineList = new List<ASI_MFM_PO_Line_Item__c>();
                for(ASI_MFM_PO_Line_Item__c pol:PurchaseOrder.PO_Line_Items__r){
                    POLineList.add(pol);
                }//end of for loop
                POs.add(new PO(PurchaseOrder,POLineList));
            }
            if(POs.size()>0){
                if(!Header.ASI_MFM_Is_Direct_Payment__c && !Header.ASI_MFM_Cash_Out_Payment__c && !Header.ASI_MFM_Offset_Payment__c){//20180125 Introv
                    POJSON=JSON.serialize(POs);
                }
            }
            
        }
    }
    
    
    public void initalizePLan(){
        // this part need to changed later
        Plans =new List<Plan>();
        if(PlanSet.size()>0){
            List<ASI_MFM_Plan__c> PlanList= [select Id,Name,ASI_MFM_Plan_Raised_Date__c,ASI_MFM_Plan_Name__c,ASI_MFM_Status__c,ASI_MFM_Plan_Amount__c,ASI_MFM_Currency__c,
                                             ASI_MFM_Budget_Type__c,ASI_MFM_Project_Code__c,ASI_MFM_Project_Code__r.Name,   
                                             (select Id,Name,ASI_MFM_Total_Cost__c,ASI_MFM_List_Item_Description__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_brand_Code__r.Name
                                              FROM Plan_Line_Items__r) 
                                             from ASI_MFM_Plan__c where id in : PlanSet];
            
            for(ASI_MFM_Plan__c PlanItem:PlanList){
                
                ASI_MFM_KR_ActSpendWrapClass ResultData=ASI_MFM_KR_PlanToolBarController.calculateActualSpendingAmount(PlanItem.Id);
                Plan tempPlan = new Plan(PlanItem,PlanItem.Plan_Line_Items__r);
                tempPlan.ActSpendingAmount=ResultData.ASI_MFM_Amount.SetSCale(0);
                tempPlan.PRB=PlanItem.ASI_MFM_Plan_Amount__c-tempPlan.ActSpendingAmount;
                Plans.add(tempPlan);
            }//End of for loop
            if(Plans.size()>0){
                PlanJSON=JSON.serialize(Plans);
            }
        }
    }
    
    
    public void initalizePR(){
        PurchaseRequests =new List<PurchaseRequest>();
        if(PRSet.size()>0){
            List<ASI_MFM_Purchase_Request__c> PRList= [select Id,Name,ASI_MFM_Service_Item_POSM__c,ASI_MFM_Total_Amount__c,ASI_MFM_Status__c,ASI_MFM_PR_Name__c,ASI_MFM_Currency__c,
                                                       (select Id,Name,ASI_MFM_Account_Number__c,ASI_MFM_Description__c,ASI_MFM_Estimated_PR_budget__c
                                                        FROM Purchase_Request_Lines__r) from ASI_MFM_Purchase_Request__c where id in : PRSet];
            
            for(ASI_MFM_Purchase_Request__c PurR:PRList){
                List<ASI_MFM_Purchase_Request_Line__c> PRLineList = new List<ASI_MFM_Purchase_Request_Line__c>();
                for(ASI_MFM_Purchase_Request_Line__c prl:PurR.Purchase_Request_Lines__r){
                    PRLineList.add(prl);
                }
                PurchaseRequests.add(new PurchaseRequest(PurR,PRLineList));
            }//End of for loop
            
            if(PurchaseRequests.size()>0){
                PRJSON=JSON.serialize(PurchaseRequests);
            }
        }
    }
    
    public void initalizePOReceipts (){
        POReceipts =new List<POReceipt>();
        if(PORSet.size()>0){
            List<ASI_MFM_PO_Receipt__c> PORList= [select Id,Name,ASI_MFM_Amount__c,ASI_MFM_Receipt_Date__c,ASI_MFM_Status__c,ASI_MFM_PO__r.ASI_MFM_Currency__c,
                                                  (select Id,Name,ASI_MFM_PO_Line_Item__c,ASI_MFM_ETL_Date__c,ASI_MFM_Venue_Where__c,ASI_MFM_AccountsAdditionalField__c,ASI_MFM_PO__c ,ASI_MFM_Quantity__c,ASI_MFM_Marketing_Verify__c,ASI_MFM_Receipt_Date__c,ASI_MFM_Remark__c,ASI_MFM_ETL__c,
                                                   ASI_MFM_Amount__c,ASI_MFM_PO_Receipt__r.ASI_MFM_Receipt_Date__c,ASI_MFM_PO_Receipt__c, ASI_MFM_ACC_Verify__c, ASI_MFM_PO_Receipt__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_UOM__c,
                                                   ASI_MFM_PO_Line_Item__r.name from PO_Receipt_Items__r)
                                                  from ASI_MFM_PO_Receipt__c where id in : PORSet];
            for(ASI_MFM_PO_Receipt__c por:PORList){
                List<ASI_MFM_PO_Receipt_Item__c> PORLineList = new List<ASI_MFM_PO_Receipt_Item__c>();
                for(ASI_MFM_PO_Receipt_Item__c porl:por.PO_Receipt_Items__r){
                    PORLineList.add(porl);
                }
                POReceipts.add(new POReceipt(por,PORLineList)); 
            }
            
            if(POReceipts.size()>0){
                PORJSON=JSON.serialize(POReceipts);
            }
            
        }
        
    }
    
    
    
    /*specialized format for organizing and storing data*/
    
    //ASI_MFM_Plan__c and ASI_MFM_Plan_Line_Item__c
    public Class Plan{
        public ASI_MFM_Plan__c Plan {set;get;}
        public List<ASI_MFM_Plan_Line_Item__c> Planline{set;get;}
        public Decimal ActSpendingAmount {set;get;} {ActSpendingAmount=0;}
        public Decimal PRB {set;get;} {PRB=0;}
        public String formatString(String InputString){
            String TempStr='';
            if(InputString.contains('\'')){
                List<String> parts = InputString.split('\'');
                String str='';
                for(String s: parts) {
                    str = str+s;
                }//system.assertEquals(null, str);
                TempStr=str;
            }else{
                TempStr=InputString;
            }
            return TempStr;
        }
        
        
        public Plan(ASI_MFM_Plan__c Plan,List<ASI_MFM_Plan_Line_Item__c> Planlines){
            this.Plan = Plan;
            List<ASI_MFM_Plan_Line_Item__c> TempPlanLineList = new List<ASI_MFM_Plan_Line_Item__c>();
            for(ASI_MFM_Plan_Line_Item__c pl:Planlines){
                TempPlanLineList.add(New ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c=Plan.Id,
                                                                    Id=pl.Id,
                                                                    ASI_MFM_Remarks__c=pl.Name,
                                                                    ASI_MFM_Total_Cost__c=pl.ASI_MFM_Total_Cost__c,
                                                                    ASI_MFM_List_Item_Description__c=pl.ASI_MFM_List_Item_Description__c,
                                                                    ASI_MFM_Sub_brand_Code__c=pl.ASI_MFM_Sub_brand_Code__c,
                                                                    ASI_MFM_Justification__c=formatString(pl.ASI_MFM_Sub_brand_Code__r.Name)));
            }
            
            this.Planline=TempPlanLineList;
        }
        
    }
    
    
    //ASI_MFM_Purchase_Request__c and ASI_MFM_Purchase_Request_Line__c
    public Class PurchaseRequest{
        public ASI_MFM_Purchase_Request__c PurchaseRequest {set;get;}
        public List<ASI_MFM_Purchase_Request_Line__c> PRLine{set;get;}
        public String formatString(String InputString){
            String TempStr='';
            if(InputString.contains('\'')){
                List<String> parts = InputString.split('\'');
                String str='';
                for(String s: parts) {
                    str = str+s;
                }//system.assertEquals(null, str);
                TempStr=str;
            }else{
                TempStr=InputString;
            }
            return TempStr;
        }

        
        public PurchaseRequest (ASI_MFM_Purchase_Request__c PurchaseRequest,List<ASI_MFM_Purchase_Request_Line__c> PRLine){
            this.PurchaseRequest = PurchaseRequest;
            this.PurchaseRequest.ASI_MFM_PR_Name__c=formatString(PurchaseRequest.ASI_MFM_PR_Name__c);
            this.PRLine=PRLine;
        }
        
    }
    
    
    //ASI_MFM_PO__c and ASI_MFM_PO_Line_Item__c
    public Class PO{
        public ASI_MFM_PO__c PO {set;get;}
        public List<ASI_MFM_PO_Line_Item__c> poline{set;get;}
        public PO (ASI_MFM_PO__c PO,List<ASI_MFM_PO_Line_Item__c> poline){
            this.PO = PO;
            this.poline=poline;
        }
        
    }
    
    //ASI_MFM_PO_Receipt__c  and  ASI_MFM_PO_Receipt_Item__c
    public Class POReceipt{
        public ASI_MFM_PO_Receipt__c POReceipt {set;get;}
        public List<ASI_MFM_PO_Receipt_Item__c> pori{set;get;}
        public POReceipt (ASI_MFM_PO_Receipt__c POReceipt,List<ASI_MFM_PO_Receipt_Item__c> pori){
            this.POReceipt = POReceipt;
            this.pori=pori;
        }
        
    }
    
}