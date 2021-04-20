/***************************************************************************************************************************
 * Name:        ASI_CRM_OffGroupShuttle
 * Description: Controller for Page ASI_CRM_CN_OffGroupShuttleCmp
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-11-23       Hector Tsang          Created
 ****************************************************************************************************************************/
public class ASI_CRM_CN_OffGroupShuttleCmpCtrl {
    public String PageId {set;get;}
    public string strPDF {set;get;}{strPDF='1';}
    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator GroupContractFI  {set;get;} { GroupContractFI = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();}
    public Map<String, ChildWrapper> childWrapperMap {get; set;} {childWrapperMap = new Map<String, ChildWrapper>();}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public class ChildWrapper{
    	public String promotionType {get; set;}
    	public Integer NumberOfContract {get; set;}
    	public Decimal ContractTotal {get; set;}
    	
    	public ChildWrapper(String inputPromotionType, Integer inputNumberOfContract, Decimal inputContractTotal){
    		promotionType = inputPromotionType;
    		NumberOfContract = inputNumberOfContract;
    		if (inputContractTotal != null)
    			ContractTotal = inputContractTotal.SetScale(2);
    	} 
    }
    
    
    public boolean init(){
    	if (PageId != null){
            try{
            	//Setup default value for the table
            	ChildWrapper defaultValue = new ChildWrapper('TOT/MOT Contract', 0, 0);
            	childWrapperMap.put('TOT/MOT Contract', defaultValue);
            	
            	AggregateResult[] childContractAggResult = [SELECT ASI_TH_CRM_Promotion_Type__c,
            														COUNT(Id),
            														SUM(ASI_CRM_CN_Total_Contract_Amount__c)
            												 FROM ASI_TH_CRM_Contract__c
            												 WHERE ASI_CRM_CN_Group_Contract__c = :PageId
            												 AND (ASI_CRM_CN_Status__c = 'Approved'
    																OR ASI_CRM_CN_Status__c = 'Final')
            												 GROUP BY ASI_TH_CRM_Promotion_Type__c
            												 ORDER BY ASI_TH_CRM_Promotion_Type__c];
            	for (AggregateResult ar : childContractAggResult){
            		String key = (String)ar.get('ASI_TH_CRM_Promotion_Type__c');
            		ChildWrapper result = new ChildWrapper(key, (Integer)ar.get('expr0'), (Decimal)ar.get('expr1'));
            		childWrapperMap.put(key, result);
            	}											 
                List<ASI_Attachment__c> AttachmentList = [SELECT id,
																ASI_CRM_Historical_Financial_Data__c,
																ASI_CRM_Contract__c,
																ASI_CRM_Type__c 
															FROM ASI_Attachment__c 
															WHERE ASI_CRM_Contract__c = :PageId 
															AND ASI_CRM_Type__c = 'Group Contract Data'];
													
				for(ASI_Attachment__c att:AttachmentList){
		       		system.debug('AttachmentList:' + att.Id);
					String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
					ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ContractData =(ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator)System.JSON.deserialize(JsonString,ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator.class);
					
					if (att.ASI_CRM_Contract__c == PageId){
						groupContractFI = ContractData;
					}
				}
				groupContractFI.DataRounding();
						
            }catch(exception e){
                system.debug(e.getMessage());
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_OffGroupShuttleCmpCtrl in init class have Error  '+'Save Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_OffGroupShuttleCmpCtrl','PDF function failed! with contract Id: '+PageId );
            }
    	}
    	return true;
    }
    
}