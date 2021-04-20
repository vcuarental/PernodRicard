//Test class implemented at ASI_CRM_SG_FreeGoodsRequest_Test class, testSplitFOCByOutlet_Controller  test method
//***************************************************************************************************************************//
//2016-12-19 Wilken: Default Child Outlet Address Line 1-3 to FOC Delivery Address

public without sharing class ASI_CRM_SG_SplitFOCByOutlet_Controller {
    
	public class focItemWrapper {
		//Wilken 20161118, original FOC might have multiple lines with same SKU. Changed to use FOC Item ID as unique key in map
		public ID focItemId {get;set;}
		public ID skuID {get;set;}
		public String skuName {get;set;}
		public Integer originalQty {get;set;}
		public Integer outlet0Qty {get;set;}
		public Integer outlet1Qty {get;set;}
		public Integer outlet2Qty {get;set;}
		public Integer outlet3Qty {get;set;}
		public Integer outlet4Qty {get;set;}
		public Integer outlet5Qty {get;set;}
		public Integer outlet6Qty {get;set;}
		public Integer outlet7Qty {get;set;}
		public Integer outlet8Qty {get;set;}
		public Integer outlet9Qty {get;set;}
		public Integer outlet10Qty {get;set;}
		public Integer outlet11Qty {get;set;}
		public Integer outlet12Qty {get;set;}
		public Integer outlet13Qty {get;set;}
		public Integer outlet14Qty {get;set;}
		public Integer outlet15Qty {get;set;}
		public Integer outlet16Qty {get;set;}
		public Integer outlet17Qty {get;set;}
		public Integer outlet18Qty {get;set;}
		public Integer outlet19Qty {get;set;}
		
	}
	
    public ASI_FOC_Free_Goods_Request__c header {get;set;}
    public List<ASI_FOC_Request_Item__c> headerLines {get;set;}

	public Set<String> offtakeCustomerName {get;set;}
    public List<focItemWrapper> focItemWrapperList {get;set;}
	public Boolean renderSplitButton {get;set;}
	public Map<String,String> outletNameMap{get;set;}
	private Map<String,ID> skuNameIDMap = new Map<String,ID>();
	private Map<String,Map<Integer,String>> custNameAddressMap = new Map<String,Map<Integer,String>>();
	
    public ASI_CRM_SG_SplitFOCByOutlet_Controller(ApexPages.StandardController stdController) {
        
		offtakeCustomerName = new Set<String>();
		focItemWrapperList = new List<focItemWrapper>();
		outletNameMap = new Map<String,String>();
		renderSplitButton = true;
		
		for (Integer i=0; i<20;i++){
			outletNameMap.put(String.valueOf(i),'');
		}
		
        List<ASI_FOC_Free_Goods_Request__c> headerList = (List<ASI_FOC_Free_Goods_Request__c>)queryAll(((ASI_FOC_Free_Goods_Request__c)stdController.getRecord()).id, 'ASI_FOC_Free_Goods_Request__c', '', 'ID', '');
        
        if(headerList.size() > 0) {   
            Header = headerList.get(0);
            headerLines = (List<ASI_FOC_Request_Item__c>)queryAll(Header.id, 'ASI_FOC_Request_Item__c', 'ASI_CRM_Wholesaler__r.name,', 'ASI_FOC_Request_Order__c', '');
			
			List<ASI_TH_CRM_Actual_Offtake__c> offtakeList = [select id, Name, ASI_CRM_SG_Customer__c, ASI_CRM_SG_Customer__r.Name, ASI_CRM_SG_Customer__r.ASI_CRM_JP_City_Ward__c, ASI_CRM_SG_Customer__r.ASI_CRM_JP_Town__c, ASI_CRM_SG_Customer__r.ASI_CRM_Street_Number__c
				from ASI_TH_CRM_Actual_Offtake__c where ASI_CRM_Contract__c = :Header.ASI_CRM_Contract__c and ASI_TH_CRM_Year__c = :Header.ASI_CRM_SG_Year__c 
					and ASI_TH_CRM_Month__c = :Header.ASI_CRM_SG_Month__c];
			
			for (ASI_TH_CRM_Actual_Offtake__c offtake:offtakeList){
				system.debug('offtake: ' + offtake.Name + ' customer: ' + offtake.ASI_CRM_SG_Customer__r.Name);
				offtakeCustomerName.add(offtake.ASI_CRM_SG_Customer__r.Name);
				
				//20161219 Wilken: Prepare a map containing Customer ID with a map of Address Line 1 to 3, for assignment when spliting FOC
				Map<Integer,String> addressMap = new Map<Integer,String>();
				addressMap.put(1,offtake.ASI_CRM_SG_Customer__r.ASI_CRM_JP_City_Ward__c);
				addressMap.put(2,offtake.ASI_CRM_SG_Customer__r.ASI_CRM_JP_Town__c);
				addressMap.put(3,offtake.ASI_CRM_SG_Customer__r.ASI_CRM_Street_Number__c);
				
				if (custNameAddressMap == null || custNameAddressMap.get(offtake.ASI_CRM_SG_Customer__r.Name) == null){
					custNameAddressMap.put(offtake.ASI_CRM_SG_Customer__r.Name, addressMap);
				}
			}
			
			system.debug('Customer Name-Address Map: ' + custNameAddressMap);
			
			for (ASI_FOC_Request_Item__c focLine:headerLines){
				focItemWrapper itemWrapper = new focItemWrapper();
				
				itemWrapper.focItemId = focLine.Id;
				itemWrapper.skuID = focLine.ASI_FOC_SKU__c;
				itemWrapper.skuName = focLine.ASI_FOC_SKU_Description__c;
				itemWrapper.originalQty = Integer.valueOf(focLine.ASI_FOC_Request_Quantity_Bottle__c);
				
				focItemWrapperList.add(itemWrapper);
				
				skuNameIDMap.put(focLine.ASI_FOC_SKU_Description__c, focLine.ASI_FOC_SKU__c);
			}
			
			system.debug('focItemWrapperList: ' + focItemWrapperList + ' offtakeCustomerName: ' + offtakeCustomerName);
			
			Integer counter = 0;
			for (String cusName:offtakeCustomerName){
				outletNameMap.put(String.valueOf(counter),cusName);
				counter++;
			}
			
			system.debug('outletNameMap: ' + outletNameMap);
        }
    }
    
	public PageReference init() {
		if (header.ASI_CRM_SG_System_Generated__c == false){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Only System Generated Free Goods Request can be split by Offtake Outlets'));
			renderSplitButton = false;
		}
		
		return null;
	}
	
    public PageReference split() {
		Map<String,List<Map<ID,Integer>>> outletSKUMap = new Map<String,List<Map<ID,Integer>>>();

		PageReference ref;
				
		for (focItemWrapper itemWrapper:focItemWrapperList){
			Integer total = 0;
			
			if (itemWrapper.outlet0Qty != null) total += itemWrapper.outlet0Qty;
			if (itemWrapper.outlet1Qty != null) total += itemWrapper.outlet1Qty;
			if (itemWrapper.outlet2Qty != null) total += itemWrapper.outlet2Qty;
			if (itemWrapper.outlet3Qty != null) total += itemWrapper.outlet3Qty;
			if (itemWrapper.outlet4Qty != null) total += itemWrapper.outlet4Qty;
			if (itemWrapper.outlet5Qty != null) total += itemWrapper.outlet5Qty;
			if (itemWrapper.outlet6Qty != null) total += itemWrapper.outlet6Qty;
			if (itemWrapper.outlet7Qty != null) total += itemWrapper.outlet7Qty;
			if (itemWrapper.outlet8Qty != null) total += itemWrapper.outlet8Qty;
			if (itemWrapper.outlet9Qty != null) total += itemWrapper.outlet9Qty;
			if (itemWrapper.outlet10Qty != null) total += itemWrapper.outlet10Qty;
			if (itemWrapper.outlet11Qty != null) total += itemWrapper.outlet11Qty;
			if (itemWrapper.outlet12Qty != null) total += itemWrapper.outlet12Qty;
			if (itemWrapper.outlet13Qty != null) total += itemWrapper.outlet13Qty;
			if (itemWrapper.outlet14Qty != null) total += itemWrapper.outlet14Qty;
			if (itemWrapper.outlet15Qty != null) total += itemWrapper.outlet15Qty;
			if (itemWrapper.outlet16Qty != null) total += itemWrapper.outlet16Qty;
			if (itemWrapper.outlet17Qty != null) total += itemWrapper.outlet17Qty;
			if (itemWrapper.outlet18Qty != null) total += itemWrapper.outlet18Qty;
			if (itemWrapper.outlet19Qty != null) total += itemWrapper.outlet19Qty;
				
			if (itemWrapper.originalQty != total){
				system.debug('SKU: ' + itemWrapper.skuName + ' Original Qty: ' + itemWrapper.originalQty + ' Total Qty After Split: ' + total);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'SKU: ' + itemWrapper.skuName + ' Total Quantity of ' + total + ' after split does not match original Request Quantity of ' + itemWrapper.originalQty));
				return null;
			}
		}
		
		//Wilken 20161118, original FOC might have multiple lines with same SKU. Changed to use FOC Item ID as unique key in map. Map<Outlet Counter<FOC Item ID, Quantity>>  
		//Map<Integer,Map<ID,Integer>> skuQtyMap = new Map<Integer,Map<ID,Integer>>();
		Map<Integer,Map<ID,Integer>> outlet_ItemIdQtyMap = new Map<Integer,Map<ID,Integer>>();
		List<ASI_FOC_Free_Goods_Request__c> newHeaderList = new List<ASI_FOC_Free_Goods_Request__c>();
		
		for (focItemWrapper itemWrapper:focItemWrapperList){
			if (itemWrapper.outlet0Qty != null && itemWrapper.outlet0Qty > 0){
				if (outlet_ItemIdQtyMap.get(0) == null)
					outlet_ItemIdQtyMap.put(0,new Map<ID,Integer>{itemWrapper.focItemId => itemWrapper.outlet0Qty});
				else 
					outlet_ItemIdQtyMap.get(0).put(itemWrapper.focItemId,itemWrapper.outlet0Qty);
			}
			
			if (itemWrapper.outlet1Qty != null && itemWrapper.outlet1Qty > 0){
				if (outlet_ItemIdQtyMap.get(1) == null)
					outlet_ItemIdQtyMap.put(1,new Map<ID,Integer>{itemWrapper.focItemId => itemWrapper.outlet1Qty});
				else 
					outlet_ItemIdQtyMap.get(1).put(itemWrapper.focItemId,itemWrapper.outlet1Qty);
			}

			if (itemWrapper.outlet2Qty != null && itemWrapper.outlet2Qty > 0){
				if (outlet_ItemIdQtyMap.get(2) == null)
					outlet_ItemIdQtyMap.put(2,new Map<ID,Integer>{itemWrapper.focItemId => itemWrapper.outlet2Qty});
				else 
					outlet_ItemIdQtyMap.get(2).put(itemWrapper.focItemId,itemWrapper.outlet2Qty);
			}

			if (itemWrapper.outlet3Qty != null && itemWrapper.outlet3Qty > 0){
				if (outlet_ItemIdQtyMap.get(3) == null)
					outlet_ItemIdQtyMap.put(3,new Map<ID,Integer>{itemWrapper.focItemId => itemWrapper.outlet3Qty});
				else 
					outlet_ItemIdQtyMap.get(3).put(itemWrapper.focItemId,itemWrapper.outlet3Qty);
			}
			
			if (itemWrapper.outlet4Qty != null && itemWrapper.outlet4Qty > 0){
				if (outlet_ItemIdQtyMap.get(4) == null)
					outlet_ItemIdQtyMap.put(4,new Map<ID,Integer>{itemWrapper.focItemId => itemWrapper.outlet4Qty});
				else 
					outlet_ItemIdQtyMap.get(4).put(itemWrapper.focItemId,itemWrapper.outlet4Qty);
			}

			if (itemWrapper.outlet5Qty != null && itemWrapper.outlet5Qty > 0){
				if (outlet_ItemIdQtyMap.get(5) == null)
					outlet_ItemIdQtyMap.put(5,new Map<ID,Integer>{itemWrapper.focItemId => itemWrapper.outlet5Qty});
				else 
					outlet_ItemIdQtyMap.get(5).put(itemWrapper.focItemId,itemWrapper.outlet5Qty);
			}

			if (itemWrapper.outlet6Qty != null && itemWrapper.outlet6Qty > 0){
				if (outlet_ItemIdQtyMap.get(6) == null)
					outlet_ItemIdQtyMap.put(6,new Map<ID,Integer>{itemWrapper.focItemId => itemWrapper.outlet6Qty});
				else 
					outlet_ItemIdQtyMap.get(6).put(itemWrapper.focItemId,itemWrapper.outlet6Qty);
			}

			if (itemWrapper.outlet7Qty != null && itemWrapper.outlet7Qty > 0){
				if (outlet_ItemIdQtyMap.get(7) == null)
					outlet_ItemIdQtyMap.put(7,new Map<ID,Integer>{itemWrapper.focItemId => itemWrapper.outlet7Qty});
				else 
					outlet_ItemIdQtyMap.get(7).put(itemWrapper.focItemId,itemWrapper.outlet7Qty);
			}

			if (itemWrapper.outlet8Qty != null && itemWrapper.outlet8Qty > 0){
				if (outlet_ItemIdQtyMap.get(8) == null)
					outlet_ItemIdQtyMap.put(8,new Map<ID,Integer>{itemWrapper.focItemId => itemWrapper.outlet8Qty});
				else 
					outlet_ItemIdQtyMap.get(8).put(itemWrapper.focItemId,itemWrapper.outlet8Qty);
			}

			if (itemWrapper.outlet9Qty != null && itemWrapper.outlet9Qty > 0){
				if (outlet_ItemIdQtyMap.get(9) == null)
					outlet_ItemIdQtyMap.put(9,new Map<ID,Integer>{itemWrapper.focItemId => itemWrapper.outlet9Qty});
				else 
					outlet_ItemIdQtyMap.get(9).put(itemWrapper.focItemId,itemWrapper.outlet9Qty);
			}

			if (itemWrapper.outlet10Qty != null && itemWrapper.outlet10Qty > 0){
				if (outlet_ItemIdQtyMap.get(10) == null)
					outlet_ItemIdQtyMap.put(10,new Map<ID,Integer>{itemWrapper.focItemId => itemWrapper.outlet10Qty});
				else 
					outlet_ItemIdQtyMap.get(10).put(itemWrapper.focItemId,itemWrapper.outlet10Qty);
			}

			if (itemWrapper.outlet11Qty != null && itemWrapper.outlet11Qty > 0){
				if (outlet_ItemIdQtyMap.get(11) == null)
					outlet_ItemIdQtyMap.put(11,new Map<ID,Integer>{itemWrapper.focItemId => itemWrapper.outlet11Qty});
				else 
					outlet_ItemIdQtyMap.get(11).put(itemWrapper.focItemId,itemWrapper.outlet11Qty);
			}

			if (itemWrapper.outlet12Qty != null && itemWrapper.outlet12Qty > 0){
				if (outlet_ItemIdQtyMap.get(12) == null)
					outlet_ItemIdQtyMap.put(12,new Map<ID,Integer>{itemWrapper.focItemId => itemWrapper.outlet12Qty});
				else 
					outlet_ItemIdQtyMap.get(12).put(itemWrapper.focItemId,itemWrapper.outlet12Qty);
			}

			if (itemWrapper.outlet13Qty != null && itemWrapper.outlet13Qty > 0){
				if (outlet_ItemIdQtyMap.get(13) == null)
					outlet_ItemIdQtyMap.put(13,new Map<ID,Integer>{itemWrapper.focItemId => itemWrapper.outlet13Qty});
				else 
					outlet_ItemIdQtyMap.get(13).put(itemWrapper.focItemId,itemWrapper.outlet13Qty);
			}

			if (itemWrapper.outlet14Qty != null && itemWrapper.outlet14Qty > 0){
				if (outlet_ItemIdQtyMap.get(14) == null)
					outlet_ItemIdQtyMap.put(14,new Map<ID,Integer>{itemWrapper.focItemId => itemWrapper.outlet14Qty});
				else 
					outlet_ItemIdQtyMap.get(14).put(itemWrapper.focItemId,itemWrapper.outlet14Qty);
			}

			if (itemWrapper.outlet15Qty != null && itemWrapper.outlet15Qty > 0){
				if (outlet_ItemIdQtyMap.get(15) == null)
					outlet_ItemIdQtyMap.put(15,new Map<ID,Integer>{itemWrapper.focItemId => itemWrapper.outlet15Qty});
				else 
					outlet_ItemIdQtyMap.get(15).put(itemWrapper.focItemId,itemWrapper.outlet15Qty);
			}

			if (itemWrapper.outlet16Qty != null && itemWrapper.outlet16Qty > 0){
				if (outlet_ItemIdQtyMap.get(16) == null)
					outlet_ItemIdQtyMap.put(16,new Map<ID,Integer>{itemWrapper.focItemId => itemWrapper.outlet16Qty});
				else 
					outlet_ItemIdQtyMap.get(16).put(itemWrapper.focItemId,itemWrapper.outlet16Qty);
			}

			if (itemWrapper.outlet17Qty != null && itemWrapper.outlet17Qty > 0){
				if (outlet_ItemIdQtyMap.get(17) == null)
					outlet_ItemIdQtyMap.put(17,new Map<ID,Integer>{itemWrapper.focItemId => itemWrapper.outlet17Qty});
				else 
					outlet_ItemIdQtyMap.get(17).put(itemWrapper.focItemId,itemWrapper.outlet17Qty);
			}

			if (itemWrapper.outlet18Qty != null && itemWrapper.outlet18Qty > 0){
				if (outlet_ItemIdQtyMap.get(18) == null)
					outlet_ItemIdQtyMap.put(18,new Map<ID,Integer>{itemWrapper.focItemId => itemWrapper.outlet18Qty});
				else 
					outlet_ItemIdQtyMap.get(18).put(itemWrapper.focItemId,itemWrapper.outlet18Qty);
			}

			if (itemWrapper.outlet19Qty != null && itemWrapper.outlet19Qty > 0){
				if (outlet_ItemIdQtyMap.get(19) == null)
					outlet_ItemIdQtyMap.put(19,new Map<ID,Integer>{itemWrapper.focItemId => itemWrapper.outlet19Qty});
				else 
					outlet_ItemIdQtyMap.get(19).put(itemWrapper.focItemId,itemWrapper.outlet19Qty);
			}			
		}

		System.Savepoint pSavepoint = Database.setSavepoint();
		
		try {
			ID contractID = header.ASI_CRM_Contract__c;
			
			//Iterate the list to create FOC Header
			for (Integer i=0;i<20;i++){
				if (outlet_ItemIdQtyMap.get(i) != null){
					ASI_FOC_Free_Goods_Request__c newHeader = header.clone(false, true, false, false);
					newHeader.ASI_FOC_Delivery_Remarks__c = outletNameMap.get(String.valueOf(i));
					newHeader.ASI_CRM_SG_External_Id__c = null;
					newHeader.ASI_CRM_External_ID__c = null;
					newHeader.ASI_FOC_Request_Status__c = 'Draft';
					newHeader.ASI_FOC_Deliver_to_Address_Line_1__c = custNameAddressMap.get(outletNameMap.get(String.valueOf(i))).get(1);
					newHeader.ASI_FOC_Deliver_to_Address_Line_2__c = custNameAddressMap.get(outletNameMap.get(String.valueOf(i))).get(2);
					newHeader.ASI_FOC_Deliver_to_Address_Line_3__c = custNameAddressMap.get(outletNameMap.get(String.valueOf(i))).get(3);
					newHeaderList.add(newHeader);
				}
			}
			
			insert newHeaderList;
			
			List<ASI_FOC_Request_Item__c> newLineList = new List<ASI_FOC_Request_Item__c>();
			
			system.debug('Original FOC Item Size: ' + headerLines.size() + ' outlet_ItemIdQtyMap: ' + outlet_ItemIdQtyMap);
			
			for(ASI_FOC_Request_Item__c headerLine : headerLines) {
				for (Integer i=0;i<20;i++){
					system.debug('Item ' + i + ' SKU:' + headerLine.ASI_FOC_SKU_Description__c + ' SKU Quantity Map: ' + outlet_ItemIdQtyMap.get(i));
					if (outlet_ItemIdQtyMap.get(i) != null && outlet_ItemIdQtyMap.get(i).get(headerLine.Id) != null && outlet_ItemIdQtyMap.get(i).get(headerLine.Id) > 0){
						ASI_FOC_Request_Item__c newLine = headerLine.clone(false, true, false, false);
						newLine.ASI_FOC_Request_Quantity_Bottle__c = outlet_ItemIdQtyMap.get(i).get(headerLine.Id);
						newLine.ASI_FOC_Actual_Quantity_Bottle__c = outlet_ItemIdQtyMap.get(i).get(headerLine.Id);
						
						ID newHeaderID;
						for (ASI_FOC_Free_Goods_Request__c newHeader:newHeaderList){
							if (newHeader.ASI_FOC_Delivery_Remarks__c == outletNameMap.get(String.valueOf(i))) newHeaderID = newHeader.ID;
						}
						newLine.ASI_FOC_Request_Order__c = newHeaderID;
						newLine.ASI_FOC_Sys_Unique_Key__c = null;
						newLineList.add(newLine);
					}
				}
			}			
			
			insert newLineList;
			
			delete header;
			
			ref = new PageReference('/'+contractID);
		}
		catch (exception e) {
            ref = null;
            Database.rollback(pSavepoint);      
            String strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
        }
		
        return ref;
    }
    
    private List<sObject> queryAll(ID filterID, String sObjectName, String extraField, String filteringField, String extraQuery) {
    
        List<sObject> sObjectList = new List<sObject>();
        Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();  
        Schema.sObjectType sObjType = globalDescription.get(sObjectName);  
        Schema.DescribeSObjectResult r1 = sObjType.getDescribe();  
        
        Map<String, Schema.SObjectField> sObjectFieldMap = r1.fields.getMap();
        String theQuery = 'Select ' + extraField + ' ';
        
        for(String fields  : sObjectFieldMap.keySet()){
            theQuery += fields + ' ,';
        }
        thequery = theQuery.subString(0,theQuery.length()-1);
        thequery +=' From '+sObjectName+' where '+filteringField+' = \''+ filterID + '\' ' + extraQuery;
                
        sObjectList = Database.query(theQuery);
        
        return sObjectList;
    }

}