public without sharing class ASI_CRM_CN_DashBoardController {
    
    //public ASI_CRM_CN_DashBoardController(ApexPages.StandardController stdController) {}
    
    Public static List<dataClass> getRecord(){
        
        List<dataClass> dataList = new List<dataClass>();
        
        List<ASI_CRM_AccountsAdditionalField__c> customerList = new List<ASI_CRM_AccountsAdditionalField__c>([SELECT id
                                                                                                              , Name
                                                                                                              , ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c
                                                                                                              , ASI_CRM_CN_Area_Name__c
                                                                                                              , ASI_CRM_T1_Depletion_M0__c
                                                                                                              , ASI_CRM_PR_Direct_M0__c
                                                                                                              , ASI_CRM_PR_Direct_M1__c
                                                                                                              , ASI_CRM_T1_Depletion_M1__c
                                                                                                              FROM ASI_CRM_AccountsAdditionalField__c
                                                                                                              USING SCOPE TEAM
                                                                                                              WHERE recordType.DeveloperName LIKE 'ASI_CRM_Outlet_CN'
                                                                                                              OR recordType.DeveloperName LIKE 'ASI_CRM_CN_WS'
                                                                                                             ]);
        Set<String> areaID = new Set<STring>();
        Map<String, Double> MTDGroupByArea = new Map<String, Double>();
        Map<String, List<ASI_CRM_AccountsAdditionalField__c>> customerGroupByArea = new Map<String, List<ASI_CRM_AccountsAdditionalField__c>>();
        set<ASI_CRM_CN_Area__c> areaSet = new Set<ASI_CRM_CN_Area__c>();
        
        for(ASI_CRM_AccountsAdditionalField__c obj : customerList){
            
            areaID.add(obj.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c);
            if(obj.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c != NULL)
            	areaSet.add(new ASI_CRM_CN_Area__c(id = obj.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c, Name = obj.ASI_CRM_CN_Area_Name__c));
            
            if(MTDGroupByArea.containsKey(obj.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c)){
                Double a;
                Double b;
                if(date.today().day() >= 6){
                    a = obj.ASI_CRM_T1_Depletion_M0__c == NULL ? 0 : obj.ASI_CRM_T1_Depletion_M0__c;
                    b = obj.ASI_CRM_PR_Direct_M0__c == NULL ? 0 : obj.ASI_CRM_PR_Direct_M0__c;
                }else{
                    a = obj.ASI_CRM_T1_Depletion_M1__c == NULL ? 0 : obj.ASI_CRM_T1_Depletion_M1__c;
                    b = obj.ASI_CRM_PR_Direct_M1__c == NULL ? 0 : obj.ASI_CRM_PR_Direct_M1__c;
                }
                MTDGroupByArea.put(obj.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c, MTDGroupByArea.get(obj.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c) + a + b);
                
                List<ASI_CRM_AccountsAdditionalField__c> tmp = customerGroupByArea.get(obj.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c);
                tmp.add(obj);
                customerGroupByArea.put(obj.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c, tmp);
            }else{
                
                Double a;
                Double b;
                if(date.today().day() >= 6){
                    a = obj.ASI_CRM_T1_Depletion_M0__c == NULL ? 0 : obj.ASI_CRM_T1_Depletion_M0__c;
                    b = obj.ASI_CRM_PR_Direct_M0__c == NULL ? 0 : obj.ASI_CRM_PR_Direct_M0__c;
                }else{
                    a = obj.ASI_CRM_T1_Depletion_M1__c == NULL ? 0 : obj.ASI_CRM_T1_Depletion_M1__c;
                    b = obj.ASI_CRM_PR_Direct_M1__c == NULL ? 0 : obj.ASI_CRM_PR_Direct_M1__c;
                }
                
                MTDGroupByArea.put(obj.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c, ( a + b ) );
                
                List<ASI_CRM_AccountsAdditionalField__c> tmp = new List<ASI_CRM_AccountsAdditionalField__c>();
                tmp.add(obj);
                customerGroupByArea.put(obj.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c, tmp);
            }
        }
        
        List<ASI_CRM_City_Sales_Target__c> citySalesTargetList;
        
        if(date.today().day() >= 6){
            
            citySalesTargetList = new List<ASI_CRM_City_Sales_Target__c>([SELECT 
                                                                          id
                                                                          , ASI_CRM_Target_Date__c
                                                                          , ASI_CRM_Target_Qty_9L__c
                                                                          , ASI_CRM_City__r.ASI_CRM_CN_Area__c
                                                                          , ASI_CRM_City__r.ASI_CRM_CN_Area__r.Name 
                                                                          FROM ASI_CRM_City_Sales_Target__c 
                                                                          WHERE recordType.DeveloperName LIKE 'ASI_CRM_CN_City_Sales_Target'
                                                                          AND ASI_CRM_City__r.ASI_CRM_CN_Area__c IN : areaID
                                                                          AND ASI_CRM_Target_Date__c = THIS_MONTH
                                                                         ]);
        }else{
            
            citySalesTargetList = new List<ASI_CRM_City_Sales_Target__c>([SELECT 
                                                                      id
                                                                      , ASI_CRM_Target_Date__c
                                                                      , ASI_CRM_Target_Qty_9L__c
                                                                      , ASI_CRM_City__r.ASI_CRM_CN_Area__c
                                                                      , ASI_CRM_City__r.ASI_CRM_CN_Area__r.Name 
                                                                      FROM ASI_CRM_City_Sales_Target__c 
                                                                      WHERE recordType.DeveloperName LIKE 'ASI_CRM_CN_City_Sales_Target'
                                                                      AND ASI_CRM_City__r.ASI_CRM_CN_Area__c IN : areaID
                                                                      AND ASI_CRM_Target_Date__c = LAST_MONTH
                                                                     ]);
        }
        Map<String, Double> salesTargetGroupByArea = new Map<String, Double>();
        
        for(ASI_CRM_City_Sales_Target__c obj : citySalesTargetList){
            
            if(salesTargetGroupByArea.containsKey(obj.ASI_CRM_City__r.ASI_CRM_CN_Area__c)){
                
                obj.ASI_CRM_Target_Qty_9L__c = obj.ASI_CRM_Target_Qty_9L__c == NULL ? 0 :obj.ASI_CRM_Target_Qty_9L__c;
                salesTargetGroupByArea.put(obj.ASI_CRM_City__r.ASI_CRM_CN_Area__c, salesTargetGroupByArea.get(obj.ASI_CRM_City__r.ASI_CRM_CN_Area__c) + obj.ASI_CRM_Target_Qty_9L__c);
            }else{
                
                obj.ASI_CRM_Target_Qty_9L__c = obj.ASI_CRM_Target_Qty_9L__c == NULL ? 0 :obj.ASI_CRM_Target_Qty_9L__c;
                salesTargetGroupByArea.put(obj.ASI_CRM_City__r.ASI_CRM_CN_Area__c, obj.ASI_CRM_Target_Qty_9L__c);
            }
        }
        
        For(ASI_CRM_CN_Area__c obj : areaSet){
            
            dataClass tmpDataClass = new dataClass();
            
            if(salesTargetGroupByArea.containsKey(obj.id) && MTDGroupByArea.containsKey(obj.id)){
                
            	tmpDataClass.areaName = obj.Name;
                tmpDataClass.monthlyTarget = salesTargetGroupByArea.get(obj.id);
            	tmpDataClass.MTDVolume = MTDGroupByArea.get(obj.id);
            	tmpDataClass.volumeVsTarget = ( tmpDataClass.MTDVolume/tmpDataClass.monthlyTarget );// * 100;
                tmpDataClass.lineItem = new List<lineItemClass>();
                
                /*if(customerGroupByArea.containsKey(obj.id)){
                    for(ASI_CRM_AccountsAdditionalField__c customer : customerGroupByArea.get(obj.id)){
                        
                        lineItemClass tmpLineItem = new lineItemClass();
                        
                        customer.ASI_CRM_T1_Depletion_M0__c = customer.ASI_CRM_T1_Depletion_M0__c == NULL ? 0 : customer.ASI_CRM_T1_Depletion_M0__c;
                		customer.ASI_CRM_PR_Direct_M0__c = customer.ASI_CRM_PR_Direct_M0__c == NULL ? 0 : customer.ASI_CRM_PR_Direct_M0__c;
                        
                        tmpLineItem.customerName = customer.Name;
                        tmpLineItem.customerMTDVolume = customer.ASI_CRM_T1_Depletion_M0__c + customer.ASI_CRM_PR_Direct_M0__c;
                        
                        tmpDataClass.lineItem.add(tmpLineItem);
                    }
                }*/
                
                dataList.add(tmpDataClass);
            }else{
                continue;
            }
        }
        
        return dataList;
    }
    
    Public class dataClass{
        
        Public String areaName { get; set; }
        Public Decimal monthlyTarget { get; set; }
        Public Decimal MTDVolume { get; set; }
        Public Decimal volumeVsTarget { get; set; }
        Public List<lineItemClass> lineItem { get; set; }
    }
    Public class lineItemClass{
        Public String customerName { get; set; }
        Public Decimal customerMTDVolume { get; set; }
    }
}