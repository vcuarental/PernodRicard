public class ASI_CRM_HK_AccountRelatedListController {
    public ApexPages.StandardController standardController {get;set;}
    public Account Header {get;set;}
    private String init_soql {get;set;}
    public transient List<ASI_MFM_PO__c> lineItem{get;set;}
    public transient List<ASI_MFM_PO_Line_Item__c> polineItem{get;set;}
    
    public Map<string, List<ASI_MFM_PO_Line_Item__c>> POLinesMap {set;get;}{ POLinesMap = new Map<string, List<ASI_MFM_PO_Line_Item__c>>(); }
    public String mapPOlineJSON {get{return JSON.serialize(POLinesMap);}}
    public Set<Id> childAc = new Set<Id>(); //20160704, added by Leo
    
    public Class interimData{
        public ASI_MFM_PO__c po {get; set;}
        public List<ASI_MFM_PO_Line_Item__c> pol{set;get;} //related po line
        
    }
    public List<interimData> poitems {set;get;}{poitems = new List<interimData>();}
    
    public ASI_CRM_HK_AccountRelatedListController(ApexPages.StandardController controller){
        this.standardController = controller;
        this.Header = (Account) this.standardController.getRecord();   
        if(this.Header !=null && this.Header.Id !=null){
            for(Account outlet : [Select id FROM Account where Id =: this.Header.Id limit 1]){
                this.Header = outlet;
            }
            //20160704, added by Leo
            List<Account> childL = new List<Account>([SELECT id FROM Account WHERE parentId =: this.Header.Id]);
            for(Account da: childL)
            {
                childAc.add(da.Id);
            }
            //20160704, added by Leo
            init(); 
        }  
    }
    
    public Set<id> poSet {set; get;}
    public void init() {
        poSet = new set<id>();
                
        List<ASI_MFM_PO_Line_Item__c> POLines = new List<ASI_MFM_PO_Line_Item__c>();
        POLines = [select id, ASI_MFM_PO__c from ASI_MFM_PO_Line_Item__c WHERE createddate>=LAST_N_MONTHS:24 and (ASI_MFM_Customer_Name__c = :header.id OR ASI_MFM_Customer_Name__c IN: childAc)]; //20160704, edited by Leo, add child set id
        for (ASI_MFM_PO_Line_Item__c pol : POLines){
            poSet.add(pol.ASI_MFM_PO__c);
        }
        init_soql='select ' +
                        '(select id' +
                        ', name,ASI_MFM_PO__c' +
                        ', ASI_MFM_List_Item_Description__c' + 
                        ',ASI_MFM_Amount__c' +
                        ',ASI_MFM_Customer_Name__r.name' +
                        ',ASI_MFM_Complete__c ' + 
                        ',ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_A_C_Code__r.name ' + 
                        ',ASI_MFM_AP_Code__r.name' + 
                        ',ASI_MFM_CN_Remaining_Receipt_Balance__c' + 
                        ',ASI_MFM_G_L_Date__c from PO_Line_Items__r)' +
                    ', id' + 
                    ',name' + 
                    ',Owner.name'+ 
                    ',ASI_MFM_PAF_Number__r.Name' +
                    ',ASI_MFM_Supplier_Name__r.name' +
                    ',ASI_MFM_GL_Date__c' +
                    ',ASI_MFM_Plan__r.name' +
                    ',ASI_MFM_BU_Code__r.name' + 
                    ',ASI_MFM_PO_Name__c' +
                    ',ASI_MFM_BU_Code__c' + 
                    //',ASI_MFM_PO_Raised_Date__c ' +
                    ',ASI_MFM_Plan__c' +
                    ',ASI_MFM_Sys_Plan_Amount__c' + 
                    ',ASI_MFM_Plan_Balance__c' + 
                    ',ASI_MFM_Sys_Plan_Name__c' +
                    ',ASI_MFM_VAT__c' + 
                    ',ASI_MFM_Supplier_Name__c' + 
                    ',ASI_MFM_Supplier_Number__c' + 
                    ',ASI_MFM_Currency__c' + 
                    ',ASI_MFM_Exchange_Rate__c' + 
                    ',ASI_MFM_PO_Raised_Date__c' + 
                    ',ASI_MFM_Remarks__c' +
                    ',ASI_MFM_PO_Start_Date__c' + 
                    ',ASI_MFM_PO_End_Date__c' + 
                    ',ASI_MFM_Status__c' +
                    ',ASI_MFM_PO_Amount__c' +
                    //',ASI_MFM_HK_PO_Amount_HKD__c ' +
                    ',ASI_MFM_HK_PO_Remaining_Amount_HKD__c' +
                    ',ASI_MFM_PO_Balance__c' +
                    ',ASI_MFM_Remaining_Balance__c ' +
                    ',ASI_MFM_Payment_Request_Amount__c' + 
                    ',ASI_MFM_Paid_Amount_in_PO_Currency__c' + 
                    ',ASI_MFM_Base_Currency_Amount__c '+ 
                    ',ASI_MFM_Is_FOC_PO__c '+ //20160418, added by Leo
                'from ASI_MFM_PO__c ' +
                'where id IN :poSet'+
                ' Order by ASI_MFM_PO_Start_Date__c DESC';
        runQuery();
    }
 
 
     public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {                
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(init_soql));
            }
            setCon.setPageSize(1000);//20160823 Ben @ Elufa
            return setCon;
        }
        set;
    }


    // Initialize setCon and return a list of record    
     
    public List<ASI_MFM_PO__c> getPOHeaders() {
         return (List<ASI_MFM_PO__c>) setCon.getRecords();
    }    
    
    public void runQuery() {
            
            LineItem = new  List<ASI_MFM_PO__c>();
            polineItem = new List<ASI_MFM_PO_Line_Item__c>();
            
            LineItem = getPOHeaders();
            
            List<ASI_MFM_PO__c> POTEST= NEW list<ASI_MFM_PO__c>();
            
            for(ASI_MFM_PO__c pos:LineItem ){
               // POTEST.add(pos);
                List<ASI_MFM_PO_Line_Item__c> Templine= new List<ASI_MFM_PO_Line_Item__c>();
                interimData temp= new interimData();
                temp.po=pos;
                polineItem = pos.getSObjects('PO_Line_Items__r'); 
                
                for(ASI_MFM_PO_Line_Item__c pol:polineItem){ 
                    if(pol.ASI_MFM_PO__c== pos.id){
                        Templine.add(pol);
                    }
                }
                
                temp.pol=Templine;
                POLinesMap.put(pos.name, Templine);
                poitems.add(temp);
            }
   
    }

}