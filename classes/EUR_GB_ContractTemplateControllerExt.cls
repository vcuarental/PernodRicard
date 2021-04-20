public with sharing class EUR_GB_ContractTemplateControllerExt {
	private final static String LUMP_SUM_OR_PER_BQ = 'LUMP_SUM_OR_PER_BQ';
    private final static String BOTH_LUMP_SUM_AND_PER_BQ = 'BOTH';
    
	private ApexPages.StandardController standardController {get;set;}
	private Id contractId {
            get{if (this.standardController!=null){
                    return this.standardController.getId();                                 
            }
            return null;
    }}
    public EUR_CRM_ContractClass contractClassObj {get; private set;}
	public EUR_CRM_Contract__c contractObject{
        get{if (contractClassObj!=null){return contractClassObj.contractDetails;}
            else{ return new EUR_CRM_Contract__c();}}
        set;
    }
    
    public List<EUR_CRM_Mechanic_Type__c> contractMechanicTypeList{get{
	    if(contractClassObj!=null){
	            return contractClassObj.contractMechanicTypeMap.values();
	    }
	    return null;
    }}
    
    public Map<String, MechanicTypeWrapper> mechanicItems{get;set;}{mechanicItems = new Map<String, MechanicTypeWrapper>();}
    
    public EUR_GB_ContractTemplateControllerExt(ApexPages.StandardController standardController){
    	this.standardController = standardController;
        System.debug('Flag - Check Standard Controller:' + this.standardController + ' - ' + contractId);
        if (contractId == null){
	        //TODO Handle missing ID EUR_CRM_MissingIdMessage
	        //addMessage(ApexPages.Severity.ERROR, Label.EUR_CRM_MissingIdMessage);
        }
        else{
	        initContract();
	        initContractContent();
        }
    }
    
    public void initContract(){
    	 contractClassObj = new EUR_CRM_ContractClass(contractId);
         System.debug('Flag - Check Mechanic Type:' + contractClassObj.contractMechanicTypeMap);
    }
    
    public void initContractContent(){
    	System.debug('FLag - INIT Contract Content');
                
		mechanicItems = new Map<String, MechanicTypeWrapper>();
		for (EUR_CRM_Mechanic_Type__c cMechanicType: contractMechanicTypeList){
	        String mechanicTypeName = cMechanicType.Name;
	        MechanicTypeWrapper mechanicTypeWrapper = new MechanicTypeWrapper(cMechanicType);
                        
            if (cMechanicType.EUR_CRM_Mechanic_Process_Type__c.equalsIgnoreCase(LUMP_SUM_OR_PER_BQ)){
                    mechanicTypeWrapper.hasMechanicTypeChoice = true;
            }
                        
            if (cMechanicType.EUR_CRM_Mechanic_Process_Type__c.equalsIgnoreCase(BOTH_LUMP_SUM_AND_PER_BQ)){
                    mechanicTypeWrapper.hasBothMechanicType = true;
            }
                        
            //Set data content                      
            List<EUR_CRM_Contract_Line_Item__c> contractLineItems = (contractClassObj.contractLineItemMap.containsKey(cMechanicType.Id))?contractClassObj.contractLineItemMap.get(cMechanicType.Id):new List<EUR_CRM_Contract_Line_Item__c>();
            
            if (cMechanicType.EUR_CRM_Mechanic_Process_Type__c.equalsIgnoreCase(BOTH_LUMP_SUM_AND_PER_BQ)){
                //Parse Contract Line Item if Mechanic Type Processing is Both
                mechanicTypeWrapper.hasBothMechanicType = true;

                EUR_CRM_Contract_Line_Item__c cliLumpSum = new EUR_CRM_Contract_Line_Item__c();
                List<EUR_CRM_Contract_Line_Item__c> cliList = new List<EUR_CRM_Contract_Line_Item__c>();
                                
                System.debug('Flag - Init Contract Content - Check Line Items:' + contractLineItems);
                for (EUR_CRM_Contract_Line_Item__c cli: contractLineItems){
                        if (cli.EUR_CRM_Process_Option_Lump_Sum__c == true){
                                cliLumpSum = cli;
                        }else{
                                cliList.add(cli);
                        }
                }
                //Set Lump Sum Contract Line Item
                System.debug('Flag - Init Contract Content - Check Lump Sum Line Item:' + cliLumpSum);
                mechanicTypeWrapper.contractLineItemLumpSum =(cliLumpSum.Id!=null)?cliLumpSum:null;//createLumpSumContractLineItem(cMechanicType);
                System.debug('Flag - Init Contract Content - Check Lump Sum Line Item 2:' + mechanicTypeWrapper.contractLineItemLumpSum);

                //Set BQ Contract Line Items
                //mechanicTypeWrapper.setContractLineItemMap(cliList);
                //contractLineItems = cliList;
                //setContractLineItemContent(cMechanicType.Id, cliList);
                mechanicTypeWrapper.contractLineItemsBQ = cliList;
            }
            else{
            	//setContractLineItemContent(cMechanicType.Id, contractLineItems);
            	mechanicTypeWrapper.contractLineItemsBQ = contractLineItems;
            }
                                                
    		mechanicTypeWrapper.contractLineItemList = contractLineItems;
                    
            mechanicItems.put(mechanicTypeName, mechanicTypeWrapper);
            //mechanicTypeId.put(mechanicTypeName, cMechanicType.Id);
    	}
    }
    
     public class MechanicTypeWrapper{
        public EUR_CRM_Mechanic_Type__c mechanicType{get;set;}
        public String mechanicTypeName {get;set;}
        public Id mechanicId{get;set;}
        public Decimal lumpSumAmount {get;set;}
        public boolean hasMechanicTypeChoice{get;set;}{hasMechanicTypeChoice=false;}
        public boolean hasBothMechanicType{get;set;}{hasBothMechanicType=false;}
        public String mechanicTypeChoice {get;set;} //From Picklist: Lump Sum or Per BQ
                    
        public EUR_CRM_Contract_Line_Item__c contractLineItemLumpSum{get;set;}
        public List<EUR_CRM_Contract_Line_Item__c> contractLineItemsBQ {get;set;}{contractLineItemsBQ = new List<EUR_CRM_Contract_Line_Item__c>();}
        public List<EUR_CRM_Contract_Line_Item__c> contractLineItemList {get;set;}{contractLineItemList=new List<EUR_CRM_Contract_Line_Item__c>();}
        
        public Double totalValue{get{
            totalValue = 0;
            //set value
            for (EUR_CRM_Contract_Line_Item__c cli: contractLineItemList){
                    Double tValue = (cli.EUR_CRM_Total_Value_Reference__c!=null)?cli.EUR_CRM_Total_Value_Reference__c:0;
                    if (tValue<=0 && cli.EUR_CRM_Value__c>0){
                            tValue = cli.EUR_CRM_Value__c;
                            cli.EUR_CRM_Total_Value_Reference__c = tValue;
                    }
                    totalValue += tValue;
            }                
            return totalValue;
        }private set;}{totalValue = 0;}
        
        
        public Integer contractLineItemsSize{get{return contractLineItemList.size();}}
        
        
        public MechanicTypeWrapper(String mechanicTypeName){
                this.mechanicTypeName = mechanicTypeName;
        }
        
        public MechanicTypeWrapper(EUR_CRM_Mechanic_Type__c mechanicType){
            this.mechanicType = mechanicType;
            this.mechanicTypeName = mechanicType.Name;
            this.mechanicId = mechanicType.Id;
        }
	}
}