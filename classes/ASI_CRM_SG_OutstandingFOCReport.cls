/*********************************************************************************
 * Name: ASI_CRM_SG_OutstandingFOCReport
 * Description: Controller class for ASI_CRM_SG_OutstandingFOCReport
 * Test Class: ASI_CRM_SG_OutstandingFOCReport_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-01-09		Laputa: Vincent			Create
 * 2019-05-22		Wilken					[WL 1.0] INC0084233  Update report to cater RTM Contract A&P Fund incentive
 */

public class ASI_CRM_SG_OutstandingFOCReport {
	
    private Id contractId;
	private ASI_TH_CRM_Contract__c contract;
    
    public ASI_CRM_SG_OutstandingFOCReport(ApexPages.StandardController stdController) {
        contractId = APexPages.currentPage().getParameters().get('Id');
		
		/*[WL 1.0] BEGIN*/
		contract = [SELECT Id, ASI_CRM_Contract_Exist_Before_RTM__c FROM ASI_TH_CRM_Contract__c WHERE Id = :contractId];
		
		if (contract.ASI_CRM_Contract_Exist_Before_RTM__c){	//Non-RTM Contract
			map_focType_number = new map<string, string> {
				'Events'=>'1',
				'Anniversary'=>'2',
				'Signages New - TOT'=>'3',
				'Signages Recurrent - TOT / Advertising Spot'=>'3',
				'Singages New - MOT'=>'3',
				'Signages New - MOT'=>'3',
				'Contract Sponsorship/Target Incentive'=>'4',
				'Cash Sponsorship'=>'5',
				'Advertising Spot'=>'6',
				'Management Incentive'=>'7'
			};
			
			map_number_focType = new map<string, string> {
				'1'=>'Events',
				'2'=>'Anniversary',
				'3'=>'Signages',
				'4'=>'Contract Sponsorship/Target Incentive',
				'5'=>'Cash Sponsorship',
				'6'=>'Advertising Spot',
				'7'=>'Management Incentive'
			};
		}
		else {	//RTM Contract
			map_focType_number = new map<string, string> {
				'A&P Fund'=>'2',
				'Adhoc Promotion/Sponsorship'=>'8',
				'Replacement Bottle'=>'9'
			};
			
			map_number_focType = new map<string, string> {
				'2'=>'A&P Fund',
				'8'=>'Adhoc Promotion/Sponsorship',
				'9'=>'Replacement Bottle'
			};
		}
		/*[WL 1.0] END*/
    }
    
    public string ContractNo {get;set;}
    public string ContractOutlet {get;set;}
    public string ContractPeriod {get;set;}
    
	/*[WL 1.0] BEGIN*/
	private map<string, string> map_focType_number = new map<string, string>();
	private map<string, string> map_number_focType = new map<string, string>();
	
    /*private map<string, string> map_focType_number = new map<string, string> {
        'Events'=>'1',
        'Anniversary'=>'2',
        'Signages New - TOT'=>'3',
        'Signages Recurrent - TOT / Advertising Spot'=>'3',
        'Singages New - MOT'=>'3',
        'Signages New - MOT'=>'3',
        'Contract Sponsorship/Target Incentive'=>'4',
        'Cash Sponsorship'=>'5',
        'Advertising Spot'=>'6',
        'Management Incentive'=>'7'
    };
    
    private map<string, string> map_number_focType = new map<string, string> {
        '1'=>'Events',
        '2'=>'Anniversary',
        '3'=>'Signages',
        '4'=>'Contract Sponsorship/Target Incentive',
        '5'=>'Cash Sponsorship',
        '6'=>'Advertising Spot',
        '7'=>'Management Incentive'
    };*/
	/*[WL 1.0] END*/
    
    public map<string, map<string, wrapper_data>> map_subBrand_type_data {get;set;}
    private map<string, string> map_subBrandId_name {get;set;}
    public map<string, integer> map_subBrand_count {get;set;}
    
    public List<ASI_CRM_ContractTarget__c> getContractTarget(){
        List<ASI_CRM_ContractTarget__c> ctList = [
            select id, 
            ASI_CRM_Contract__r.name,
            ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.name,
            ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c,
            ASI_CRM_Contract__r.ASI_TH_CRM_End_Date__c,
            ASI_CRM_SKU__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.name, 
            ASI_CRM_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c, ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c,
            ASI_CRM_SG_Events_Free_Bottles__c, 
            ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c,
            ASI_CRM_SG_Cont_Sponsor_Target_Incentive__c,
            ASI_CRM_SG_Anniversary_Free_Bottles__c,
            ASI_CRM_Advertising_Spot_Free_Bottles__c,
            ASI_CRM_SG_Management_Incentives__c,
            ASI_CRM_Total_Management_Incentives__c,
            ASI_CRM_SG_Btls_Per_Case__c, ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c,
            ASI_CRM_SG_Good_in_Kinds__c
            FROM ASI_CRM_ContractTarget__c
            WHERE ASI_CRM_Contract__c = : contractId
            AND recordtype.developername = 'ASI_CRM_SG_Contract_Target'
            AND ASI_CRM_SKU__c != null
            ORDER BY ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.name
        ];
        
        ContractNo = ctList[0].ASI_CRM_Contract__r.name;
        ContractOutlet = ctList[0].ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.name;
		contractPeriod = (ctList[0].ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c == null ? '' : ctList[0].ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c.format())
							+ ' - ' 
							+ (ctList[0].ASI_CRM_Contract__r.ASI_TH_CRM_End_Date__c == null ? '' : ctList[0].ASI_CRM_Contract__r.ASI_TH_CRM_End_Date__c.format());
        
        return ctList;
    }
    
    public list<ASI_FOC_Request_Item__c> getFOCitems(){
        list<ASI_FOC_Request_Item__c> focItemList = [
            SELECT ID, Name, ASI_FOC_Request_Order__c, 
            ASI_FOC_SKU__c, ASI_FOC_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c,
            ASI_FOC_SKU__r.ASI_MFM_Sub_brand__c, ASI_FOC_SKU__r.ASI_MFM_Sub_brand__r.name,
            ASI_CRM_SG_FOC_Type__c, ASI_FOC_Request_Quantity_Bottle__c,
            ASI_CRM_SG_Unit_Price__c, ASI_CRM_Selling_Price_Btl_WS_On_Trade__c
            FROM ASI_FOC_Request_Item__c
            WHERE ASI_FOC_Request_Order__r.ASI_CRM_Contract__c = : contractId
            AND ASI_FOC_SKU__c <> null
            AND ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c = 'Approved'
            ORDER BY ASI_FOC_SKU__r.ASI_MFM_Sub_brand__r.name
        ];
        return focItemList;
    }
    
    public class wrapper_data {
    
        public String foc_type {get;set;}
        public Decimal target_value {get;set;}
        public Decimal actual_value {get;set;}
        public Decimal remain_value;
        public Decimal target_9L {get;set;}
        public Decimal actual_9L {get;set;}
        public Decimal remain_9L;
        
        public Decimal getremain_value() {return this.target_value - this.actual_value;}
        public void setremain_value() {this.remain_value = this.target_value - this.actual_value;}
        public Decimal getremain_9L() {return this.target_9L - this.actual_9L;}
        public void setremain_9L() {this.remain_9L = this.target_9L - this.actual_9L;}
        
        /*
        public wrapper_data(String foc_type, Decimal target_value, Decimal actual_value, Decimal target_9L, Decimal actual_9L ) {
            
            this.foc_type = foc_type;
            this.target_value = target_value;
            this.actual_value = actual_value;
            this.target_9L = target_9L;
            this.actual_9L = actual_9L;
        }
        
        public wrapper_data(String foc_type, Decimal value, Decimal volume, Boolean target ) {
            
            this.foc_type = foc_type;
            if (target){
                this.target_value = target_value;
                this.target_9L = target_9L;
            	this.actual_value = 0;
            	this.actual_9L = 0;
            } else {
            	this.actual_value = actual_value;
            	this.actual_9L = actual_9L;
            }
        }
        */
        
        public wrapper_data(String foc_type ) {
            
            this.foc_type = foc_type;
            
            this.actual_value = 0;
            this.actual_9L = 0;
            this.target_value = 0;
            this.target_9L = 0;
        }
    }
    
    public void init(){
        map_subBrand_type_data = new map<string, map<string, wrapper_data>>();
        map_subBrandId_name = new map<string, string>();
		map_subBrand_count = new map<string, integer>();
        
		/*[WL 1.0] BEGIN*/	//Assign Sub-brand to be displayed in report based on FOC Request Sub-brand
		for (ASI_FOC_Request_Item__c line : getFOCitems()){
			string foc_type = line.ASI_CRM_SG_FOC_Type__c;
			string subBrandName = line.ASI_FOC_SKU__r.ASI_MFM_Sub_brand__r.name;
			
			if (map_focType_number.containsKey(foc_type)){
				if (map_subBrand_type_data.containsKey(subBrandName)) {
					map<string, wrapper_data> wData_subBrand = map_subBrand_type_data.get(subBrandName);
					map_subBrand_type_data.put(subBrandName,wData_subBrand);
				}
			}
		}
		/*[WL 1.0] END*/
		
        // get contract target A&P data
        for (ASI_CRM_ContractTarget__c line : getContractTarget()){
            string subBrandId = line.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c;
            string subBrandName = line.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.name;
            decimal volume9L_per_case = line.ASI_CRM_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c * line.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c / 900;
            decimal priceWSOT = line.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c == null ? 0 : line.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c;
            decimal priceWSOT_per_case = priceWSOT * line.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c;
            //for (integer i=1; i<8; i++){ //WL 1.0
			for (integer i=1; i<10; i++){
                string foc_type = map_number_focType.get(string.valueOf(i));
                decimal focCase = 0;
                map<string, wrapper_data> wData_subBrand = map_subBrand_type_data.containsKey(subBrandName) ? map_subBrand_type_data.get(subBrandName) : new map<string, wrapper_data>();
                
                if (i==1){
                    focCase = line.ASI_CRM_SG_Events_Free_Bottles__c == null ? 0 : line.ASI_CRM_SG_Events_Free_Bottles__c;
                } else 
                if (i==2){
                    focCase = line.ASI_CRM_SG_Anniversary_Free_Bottles__c == null ? 0 : line.ASI_CRM_SG_Anniversary_Free_Bottles__c;
                } else 
                if (i==3){
                    focCase = line.ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c == null ? 0 : line.ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c;
                } else 
                if (i==4){
                    focCase = line.ASI_CRM_SG_Cont_Sponsor_Target_Incentive__c == null ? 0 : line.ASI_CRM_SG_Cont_Sponsor_Target_Incentive__c;
                } else 
                if (i==5){
                    focCase = line.ASI_CRM_SG_Good_in_Kinds__c == null ? 0 : (line.ASI_CRM_SG_Good_in_Kinds__c / priceWSOT_per_case);
                } else 
                if (i==6){
                    focCase = line.ASI_CRM_Advertising_Spot_Free_Bottles__c == null ? 0 : line.ASI_CRM_Advertising_Spot_Free_Bottles__c;
                } else 
                if (i==7){
                    focCase = line.ASI_CRM_Total_Management_Incentives__c == null ? 0 : line.ASI_CRM_Total_Management_Incentives__c;
                }
				//if (focCase>0){	//WL 1.0
				if (focCase>0 || (!contract.ASI_CRM_Contract_Exist_Before_RTM__c && i>7 && map_subBrand_type_data.get(subBrandName) != null)){	//WL 1.0
					wrapper_data wData = wData_subBrand.containsKey(string.valueOf(i)) ? wData_subBrand.get(string.valueOf(i)) : new wrapper_data(foc_type);
					wData.target_value += focCase * priceWSOT_per_case;
					wData.target_9L += focCase * volume9L_per_case;
					wData_subBrand.put(string.valueOf(i),wData);
					map_subBrand_type_data.put(subBrandName,wData_subBrand);	
					map_subBrand_count.put(subBrandName,wData_subBrand.keySet().size()+1);				
				}
            }
            map_subBrandId_name.put(line.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, line.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.name);
        }
        system.debug(map_subBrand_type_data);
        
        // get FOC data
        for (ASI_FOC_Request_Item__c line : getFOCitems()){
            string foc_type = line.ASI_CRM_SG_FOC_Type__c;
            if (map_focType_number.containsKey(foc_type)){
                string subBrandId = line.ASI_FOC_SKU__r.ASI_MFM_Sub_brand__c;
                string subBrandName = line.ASI_FOC_SKU__r.ASI_MFM_Sub_brand__r.name;
                string focTypeNo = map_focType_number.get(foc_type);
                if (map_subBrand_type_data.containsKey(subBrandName)) {
                    decimal volume9L_per_bottle = line.ASI_FOC_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c / 900;
                    decimal priceWSOT = line.ASI_CRM_Selling_Price_Btl_WS_On_Trade__c == null ? 0 : line.ASI_CRM_Selling_Price_Btl_WS_On_Trade__c;
                    decimal focBottle = line.ASI_FOC_Request_Quantity_Bottle__c == null ? 0 : line.ASI_FOC_Request_Quantity_Bottle__c;
                    map<string, wrapper_data> wData_subBrand = map_subBrand_type_data.get(subBrandName);
					if (wData_subBrand.containsKey(focTypeNo)){
						wrapper_data wData = wData_subBrand.get(focTypeNo);
						wData.actual_value += focBottle * priceWSOT;
						wData.actual_9L += focBottle * volume9L_per_bottle;
						wData_subBrand.put(focTypeNo,wData);
						map_subBrand_type_data.put(subBrandName,wData_subBrand);
					}
                }     
            }
        }
    }    
}