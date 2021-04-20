/*********************************************************************************
 * Name: ASI_CRM_HK_EDI_SO_Header_TriggerClass
 * Description: 
 * Test Class: ASI_HK_CRM_EDISORegenHelperCtrlTest, ASI_CRM_HK_EDISO_To_Invoice_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-08-07       Wilken Lee             [WL 1.0] Exception handling for parsing Order and Delivery Date
 * 2018-08-10       Kelvin Chan            [KC 1.0] Assign SO Header Owner as the Customer DA's Owner
 * 2018-09-24       Wilken Lee             [WL 2.0] Calculcate EDI Price based on Customer's UOM
 * 2018-09-24       Wilken Lee             [WL 3.0] Additional handling to cater Watson's Wine cellar uses same GLN as ParkNShop
 * 2018-10-12       Wilken Lee             [WL 4.0] Assign as Urgent Order if Delivery Date is current day
 * 2018-10-12       Wilken Lee             [WL 5.0] Add "Has Error" checkbox in order to filter in list view
 * 2018-10-30       Wilken Lee             [WL 6.0] Add an extra step for SA to review EDI SO before confirm generate SO
 * 2018-11-02       Wilken Lee             [WL 7.0] Skip SO item if Sales Admin selected "Not Fulfilled"
 * 2018-11-08       Wilken Lee             [WL 8.0] Apply Advance Pricing to JDE Price
 * 2019-03-05		Alvin Wu			   [AW 9.0] Code Cleaning
 * 2019-03-08       Wilken Lee             [WL 9.0] Cannot call SetError at the beginning of iteration as it will automatically update ASI_CRM_CRM_SO_Completed__c to true 
													(we want to keep it as false to let user to verify and confirm by themselves)
 * 2019-03-13		Wilken Lee			   [WL 10.0] Allow user to manually select PR SKU after indicating the item is "SKU Reassigned"
 * 2019-04-05		Wilken Lee			   [WL 11.0] Issue Log #3 System should assign SKU if Available Quantity >= Order Quantity. 
													Currently it is only checking Available Quantity > 0 which caused order item to be partially cancelled
 * 2019-04-08		Wilken Lee			   [WL 12.0] Fix incorrect SKU assigned problem
 */
public without sharing class ASI_CRM_HK_EDI_SO_Header_TriggerClass extends ASI_HK_CRM_TriggerAbstract
{
	public ASI_CRM_HK_EDI_SO_Header_TriggerClass() {
		super('ASI_CRM_HK_EDI_SO_Header_TriggerClass');
	}
	
	public Map<ID, ASI_HK_CRM_Customer_Product_Price__c> productMap = new Map<ID, ASI_HK_CRM_Customer_Product_Price__c>();

	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap)
	{
		List<ASI_CRM_EDI_SO_Header__c> soHeaders = (List<ASI_CRM_EDI_SO_Header__c>)sObjList;
	
		//20181221 Wilken: No need to write soql to select EDI SO Header again
		//Set<Id> soIds = new Set<Id>();
		List<ASI_CRM_EDI_SO_Header__c> headerList = new List<ASI_CRM_EDI_SO_Header__c>();
		for (ASI_CRM_EDI_SO_Header__c soHeader : soHeaders)
		{
			if (soHeader.ASI_CRM_ETL_Complete__c == true && soHeader.ASI_CRM_Trigger_Processed__c == false && soHeader.ASI_HK_CRM_EDI_Invoice__c == null)
				headerList.add(soHeader);
			//soIds.add(soHeader.Id);
		}

		/*List<ASI_CRM_EDI_SO_Header__c> headerList = [
			select
			Id,
			Name,
			ASI_CRM_Customer_PO__c,
			ASI_CRM_Buyer_ID__c,
			ASI_CRM_Buyer_Name__c,
			ASI_CRM_Buyer_Name_2__c,
			ASI_CRM_Order_Date__c,
			ASI_CRM_Delivery_Date__c,
			ASI_CRM_Delivery_Party__c,
			ASI_CRM_ETL_Complete__c,
			ASI_HK_Generated_SO__c,
			ASI_CRM_Sender_Identification__c,
			ASI_CRM_SO_Generation_Error__c,
			ASI_CRM_Trigger_Processed__c,
			ASI_CRM_CRM_SO_Completed__c,
			ASI_CRM_Address_Line_1__c,
			ASI_CRM_Address_Line_2__c,
			ASI_CRM_Address_Line_3__c,
			ASI_CRM_Address_Line_4__c,
			ASI_CRM_Has_Error__c 
			from ASI_CRM_EDI_SO_Header__c
			where Id in :soIds
			and ASI_CRM_ETL_Complete__c = true
			and ASI_CRM_Trigger_Processed__c = false
			and ASI_HK_CRM_EDI_Invoice__c = null
		];*/
		
		if (headerList.size() > 0)
		{
			generateSO(headerList);
		}
	}
	
	public void generateSO(list<ASI_CRM_EDI_SO_Header__c> headerList)
	{
		Set<Id> headerIDs = new Set<Id>();
		Set<String> buyIDs = new Set<String>();
		
		for (ASI_CRM_EDI_SO_Header__c header: headerList)
		{
			headerIDs.add(header.Id);
			buyIDs.add(header.ASI_CRM_Buyer_ID__c);
		}


		List<ASI_CRM_Customer_Mapping__c> custList = [
			select ASI_CRM_Buyer_ID__c, ASI_CRM_Account__c,ASI_CRM_HK_Email_Notification__c, ASI_CRM_Account__r.OwnerId, ASI_CRM_Account__r.ParentId, ASI_CRM_Account__r.ASI_HK_CRM_Customer_Code__c, //[KC 1.0]
			ASI_CRM_UOM__c, ASI_CRM_Account__r.ASI_HK_CRM_Customer_Type__c //[WL 2.0]
			from ASI_CRM_Customer_Mapping__c
			where ASI_CRM_Buyer_ID__c in :buyIDs
			and recordType.DeveloperName = 'ASI_CRM_HK_EDI_Customer_Mapping'//[WL 3.0]
		];
		System.Debug('custList: ' + custList);

		/*Set<ID> parentIDs = new Set<ID>();
		for (ASI_CRM_Customer_Mapping__c m : custList)
		{
			parentIDs.add(m.ASI_CRM_Account__r.ParentId);
		}*/
		
		/*List<Account> accList = [
			select ID, ASI_HK_CRM_Customer_Code__c
			from Account
			where ID in :parentIDs
		];*/

		/*[WL 3.0] BEGIN*/
		List<ASI_CRM_Customer_Mapping__c> additionalCustList = [
			select ASI_CRM_Delivery_Party_Keyword__c, ASI_CRM_Account__c, ASI_CRM_HK_Email_Notification__c,ASI_CRM_Account__r.OwnerId, ASI_CRM_Account__r.ParentId, ASI_CRM_Account__r.ASI_HK_CRM_Customer_Code__c,
			ASI_CRM_UOM__c 
			from ASI_CRM_Customer_Mapping__c
			where recordType.DeveloperName = 'ASI_CRM_HK_EDI_Additional_Customer_Mapping'
		];
		/*[WL 3.0] END*/
		
		List<ASI_CRM_EDI_SO_Item__c> itemList = [
			select 
			Id, Name, ASI_CRM_EDI_Sales_Order_Header__c,
			ASI_CRM_SKU_Reassigned__c, ASI_CRM_PR_SKU__c, ASI_CRM_PR_SKU__r.ASI_HK_CRM_Packaging_Size__c, //[WL 10.0]
			ASI_CRM_Order_Quantity__c, ASI_CRM_Price__c, ASI_CRM_SKU_Code__c, ASI_CRM_Not_Fulfilled__c,
			ASI_CRM_SKU_Description__c, ASI_CRM_SKU_Description_2__c, ASI_CRM_Item_Line_Number__c, ASI_CRM_UOM_Factor__c 
			from ASI_CRM_EDI_SO_Item__c
			where ASI_CRM_EDI_Sales_Order_Header__c in :headerIDs
			and ASI_CRM_Not_Fulfilled__c = false //[WL 7.0]
			order by ASI_CRM_EDI_Sales_Order_Header__c asc, ASI_CRM_Item_Line_Number__c asc
		];
		System.Debug('itemList: ' + itemList);

		Set<String> skuCodes = new Set<String>();

		for (ASI_CRM_EDI_SO_Item__c item : itemList)
		{
			skuCodes.add(item.ASI_CRM_SKU_Code__c);
		}

		List<ASI_CRM_SKU_Mapping__c> skuList = [
			select Name, ASI_CRM_SKU__c, ASI_CRM_Account__c, ASI_CRM_Item_Number__c, ASI_CRM_SKU__r.ASI_HK_CRM_Available_Quantity__c,
			ASI_CRM_Preferred__c, ASI_CRM_Item_Group_Mapping__r.ASI_CRM_Preferred__c, ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c,
			ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c //[WL 2.0]
			from ASI_CRM_SKU_Mapping__c
			where ASI_CRM_Item_Number__c in :skuCodes
			and RecordType.DeveloperName = 'ASI_CRM_HK_EDI_SKU_Mapping'
			and ASI_CRM_SKU__r.ASI_HK_CRM_Available_Quantity__c > 0
			and ASI_CRM_Inactive__c = false
			order by ASI_CRM_SKU__c asc
		];
		System.Debug('skuList: ' + skuList);

		List<ASI_HK_CRM_Sales_Order__c> insertHeader = new List<ASI_HK_CRM_Sales_Order__c>();
		List<ASI_HK_CRM_Sales_Order_Item__c> insertItem = new List<ASI_HK_CRM_Sales_Order_Item__c>();

		for (ASI_CRM_EDI_SO_Header__c header : headerList)
		{
			//setHeaderError(header, '');	//[WL 9.0]
			header.ASI_CRM_SO_Generation_Error__c = ''; //[WL 9.0]
			header.ASI_CRM_Has_Error__c = false; //[WL 9.0]
		
			List<ASI_HK_CRM_Sales_Order__c> tmpHeader = new List<ASI_HK_CRM_Sales_Order__c>();
			List<ASI_HK_CRM_Sales_Order_Item__c> tempItem = new List<ASI_HK_CRM_Sales_Order_Item__c>();

			ASI_CRM_Customer_Mapping__c cust = getCustMapping(custList, header.ASI_CRM_Buyer_ID__c);
			System.Debug('cust: ' + cust);
			
			/*[WL 3.0] BEGIN*/
			for (ASI_CRM_Customer_Mapping__c addCust: additionalCustList){
				if (header.ASI_CRM_Delivery_Party__c != null && header.ASI_CRM_Delivery_Party__c.contains(addCust.ASI_CRM_Delivery_Party_Keyword__c))
					cust = addCust;
			}
			/*[WL 3.0] END*/

			if (cust == null)
			{
				setHeaderError(header, 'BuyerID: ' + header.ASI_CRM_Buyer_ID__c + ' not found');
			}
			else
			{
				/*[WL 1.0] BEGIN*/
				Date orderDate;
				Date deliveryDate;
				
				List<String> orderDateList = header.ASI_CRM_Order_Date__c.split('-');
				List<String> deliveryDateList = header.ASI_CRM_Delivery_Date__c.split('-');
				
				if (orderDateList.size() == 3){
					orderDate = Date.newInstance(
						Integer.valueOf(orderDateList.get(0)), 
						Integer.valueOf(orderDateList.get(1)), 
						Integer.valueOf(orderDateList.get(2))
					);
				}
				
				if (deliveryDateList.size() == 3){
					deliveryDate = Date.newInstance(
						Integer.valueOf(deliveryDateList.get(0)), 
						Integer.valueOf(deliveryDateList.get(1)), 
						Integer.valueOf(deliveryDateList.get(2))
					);
				}
				
				if (orderDate < System.today())
					orderDate = System.today();
				if (deliveryDate < System.today())
					deliveryDate = System.today();	
				/*[WL 1.0] END*/
				
				ASI_HK_CRM_Sales_Order__c newHeader = new ASI_HK_CRM_Sales_Order__c(
					ASI_HK_CRM_EDI_SO__c = header.Id,
					ASI_HK_CRM_Cust_PO__c = header.ASI_CRM_Customer_PO__c,
					ASI_HK_CRM_Customer_DA__c = cust.ASI_CRM_Account__c,
                    ASI_CRM_HK_Email_Notification__c = cust.ASI_CRM_HK_Email_Notification__c,
					ASI_HK_CRM_Order_Date__c = orderDate,
					ASI_HK_CRM_Delivery_Date__c = deliveryDate,
					//ASI_HK_CRM_Alternate_Delivery_Address_1__c = header.ASI_CRM_Address_Line_1__c,
					//ASI_HK_CRM_Alternate_Delivery_Address_2__c = header.ASI_CRM_Address_Line_2__c,
					//ASI_HK_CRM_Alternate_Delivery_Address_3__c = header.ASI_CRM_Address_Line_3__c,
					//ASI_HK_CRM_Alternate_Delivery_Address_4__c = header.ASI_CRM_Address_Line_4__c,
					OwnerId = cust.ASI_CRM_Account__r.OwnerId, //[KC 1.0]
					CurrencyISOCode = 'HKD', //[WL 3.0]
					ASI_HK_CRM_Attention__c = header.ASI_CRM_Delivery_Party__c //[WL 3.0]
				);
				
				/*[WL 4.0] BEGIN*/
				if (newHeader.ASI_HK_CRM_Delivery_Date__c == System.Today())
					newHeader.ASI_HK_CRM_Urgent_Order__c = true;
				/*[WL 4.0] END*/
				
				/*[WL 8.0] BEGIN*/						
				Date todayDate = Date.today();
				
				List<ASI_HK_CRM_Customer_Product_Price__c> productList = [
					SELECT Id, Name, ASI_HK_CRM_SKU_Lookup__c, ASI_HK_CRM_SKU_Lookup__r.Name, ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__c ,
					ASI_HK_CRM_Bottle_Price__c, ASI_HK_CRM_Case_Price__c, ASI_CRM_Percentage_Discount__c, ASI_CRM_Fix_Discount__c 
					FROM ASI_HK_CRM_Customer_Product_Price__c
					WHERE RecordType.DeveloperName = 'ASI_HK_CRM_Customer_Product_Price' AND ASI_HK_CRM_Customer_Name__c = :cust.ASI_CRM_Account__c 
						AND (ASI_HK_CRM_Effective_Date__c = NULL OR ASI_HK_CRM_Expiry_Date__c = NULL
							OR (ASI_HK_CRM_Effective_Date__c <= :todayDate AND ASI_HK_CRM_Expiry_Date__c >= :todayDate))
				];
				
				//[WL 8.0] Assign Advance Pricing to SKU JDE Bottle Price
				/*List<ASI_CRM_Advance_Pricing__c> advPricingList = [SELECT ASI_CRM_Basis_Code__c, ASI_CRM_Factor_Value__c, ASI_CRM_Account__c, ASI_CRM_Effective_Date__c, ASI_CRM_Expiry_Date__c, ASI_CRM_Item_Group__c 
																	FROM ASI_CRM_Advance_Pricing__c WHERE RecordType.DeveloperName = 'ASI_CRM_HK_Advance_Pricing' AND ASI_CRM_Account__c = :cust.ASI_CRM_Account__c  AND ASI_CRM_Effective_Date__c <= TODAY AND ASI_CRM_Expiry_Date__c> TODAY];
															
				if (advPricingList.size() == 0){	//No advance pricing setup for Customer DA, look for Parent Outlet Advance Pricing
					advPricingList = [SELECT ASI_CRM_Basis_Code__c, ASI_CRM_Factor_Value__c, ASI_CRM_Account__c, ASI_CRM_Effective_Date__c, ASI_CRM_Expiry_Date__c, ASI_CRM_Item_Group__c 
										FROM ASI_CRM_Advance_Pricing__c WHERE RecordType.DeveloperName = 'ASI_HK_CRM_Customer_Product_Price' AND  ASI_CRM_Account__c = :cust.ASI_CRM_Account__r.ParentId  AND ASI_CRM_Effective_Date__c <= TODAY AND ASI_CRM_Expiry_Date__c> TODAY];
					system.debug('No advance pricing for customer, search for Parent Outlet Advance Pricing.  Parent Outlet List size: ' + advPricingList.size());
					
					if (advPricingList.size() == 0){	//No advance pricing setup for Parent Outlet, look for Channel Advance Pricing
						String customerCatCode7 = cust.ASI_CRM_Account__r.ASI_HK_CRM_Customer_Type__c.left(3);
						advPricingList = [SELECT ASI_CRM_Basis_Code__c, ASI_CRM_Factor_Value__c, ASI_CRM_Account__c, ASI_CRM_Effective_Date__c, ASI_CRM_Expiry_Date__c, ASI_CRM_Item_Group__c 
										FROM ASI_CRM_Advance_Pricing__c WHERE RecordType.DeveloperName = 'ASI_CRM_HK_Channel_Advance_Pricing' AND ASI_CRM_Category_Code_7__c = :customerCatCode7 AND ASI_CRM_Effective_Date__c <= TODAY AND ASI_CRM_Expiry_Date__c> TODAY];
						system.debug('No advance pricing for Parent Outlet, search for Channel Advance Pricing.  Channel adv price List size: ' + advPricingList.size() + ' Cat Code 7: ' + customerCatCode7);
					}
				}*/

				for (ASI_HK_CRM_Customer_Product_Price__c product : productList) {
					if (product.ASI_HK_CRM_Bottle_Price__c != null){
						if (product.ASI_CRM_Fix_Discount__c!= null){	//Fix $ Dis
							product.ASI_HK_CRM_Bottle_Price__c = product.ASI_HK_CRM_Bottle_Price__c + product.ASI_CRM_Fix_Discount__c;
							//system.debug('SKU: ' + product.ASI_HK_CRM_SKU_Lookup__r.Name + ' Discounted Bt Price: ' + product.ASI_HK_CRM_Bottle_Price__c);
						}
						
						if (product.ASI_CRM_Percentage_Discount__c != null){	//% of GS discount
							product.ASI_HK_CRM_Bottle_Price__c = product.ASI_HK_CRM_Bottle_Price__c * (100 - product.ASI_CRM_Percentage_Discount__c) / 100;
							//system.debug('SKU: ' + product.ASI_HK_CRM_SKU_Lookup__r.Name + ' Discounted % Price: ' + product.ASI_HK_CRM_Bottle_Price__c);
						}
							
						productMap.put(product.ASI_HK_CRM_SKU_Lookup__c, product);
					}
				}
				/*[WL 8.0] END*/
				
				tmpHeader.add(newHeader);

				List<ASI_CRM_EDI_SO_Item__c> items = getItems(itemList, header.Id);

				if (items.size() == 0)
				{
					setHeaderError(header, 'No SO items found');
				}
				/*[WL 1.0] BEGIN*/ //Do not validate order date and delivery date
				/*else if (orderDate < System.Today()){
					setHeaderError(header, 'Order date cannot be earlier than today');
				}
				else if (deliveryDate < System.Today()){
					setHeaderError(header, 'Delivery date cannot be earlier than today');
				}*/
				/*[WL 1.0] END*/
				else
				{
					for (ASI_CRM_EDI_SO_Item__c item : items)
					{
						if (!item.ASI_CRM_Not_Fulfilled__c){
							/*[WL 2.0*] BEGIN*/
							Decimal ediPrice;
							Integer orderQtyBottle;
							
							/*[WL 10.0] BEGIN*/
							Id skuId;
							Decimal packSize;
							
							//WL 12.0 First SKU Mapping check for SKU mapping exist with >0 quantity
							ASI_CRM_SKU_Mapping__c sku = getSkuMapping(skuList, cust.ASI_CRM_Account__c, item.ASI_CRM_SKU_Code__c, 1);	//WL 11.0
							
							if (sku == null)
							{
								sku = getSkuMapping(skuList, cust.ASI_CRM_Account__r.ParentId, item.ASI_CRM_SKU_Code__c, 1);	//WL 11.0
							}
							
							/*[WL 10.0] BEGIN*/
							//if (sku == null)
							if (sku == null && !item.ASI_CRM_SKU_Reassigned__c)
							/*[WL 10.0] END*/
							{
								setHeaderError(header, 'Line Item: ' + item.Name + ' Sku code: ' + item.ASI_CRM_SKU_Code__c + ' not found or no available quantity');
							}
							else
							{	
								//WL 12.0 Use first iteration SKU Mapping to obtain Pack Size in order to get correct order quantity to get real SKU mapping
								if (item.ASI_CRM_SKU_Reassigned__c)
									packSize = item.ASI_CRM_PR_SKU__r.ASI_HK_CRM_Packaging_Size__c;
								else 
									packSize = sku.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c;
								
								//WL 12.0 Second SKU Mapping check again for SKU mapping exist with real order quantity quantity
								if (cust.ASI_CRM_UOM__c == 'Bottle'){
									orderQtyBottle = Integer.valueOf(item.ASI_CRM_Order_Quantity__c);
								}
								else if (cust.ASI_CRM_UOM__c == 'Case'){
									orderQtyBottle = Integer.valueOf(item.ASI_CRM_Order_Quantity__c) * Integer.valueOf(packSize);	//[WL 10.0]
								}
								else if (cust.ASI_CRM_UOM__c == 'UOM Factor'){
									orderQtyBottle = Integer.valueOf(item.ASI_CRM_Order_Quantity__c) * Integer.valueOf(item.ASI_CRM_UOM_Factor__c);
								}
								
								ASI_CRM_SKU_Mapping__c skuForOrderQty = getSkuMapping(skuList, cust.ASI_CRM_Account__c, item.ASI_CRM_SKU_Code__c, orderQtyBottle);	//WL 11.0
								
								if (skuForOrderQty == null)
									skuForOrderQty = getSkuMapping(skuList, cust.ASI_CRM_Account__r.ParentId, item.ASI_CRM_SKU_Code__c, orderQtyBottle);	//WL 11.0

								//WL 12.0 If SKU Mapping for real order quantity is null, then use SKU Mapping of >1 quantity to partially fulfill the order
								if (skuForOrderQty != null)
									sku = skuForOrderQty;
							
								if (item.ASI_CRM_SKU_Reassigned__c){
									skuId = item.ASI_CRM_PR_SKU__c;
									packSize = item.ASI_CRM_PR_SKU__r.ASI_HK_CRM_Packaging_Size__c;
								}
								else {
									skuId = sku.ASI_CRM_SKU__c;
									packSize = sku.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c;
								}
							/*[WL 10.0] END*/
							
								if (cust.ASI_CRM_UOM__c == 'Bottle'){
									ediPrice = Decimal.valueOf(item.ASI_CRM_Price__c);
								}
								else if (cust.ASI_CRM_UOM__c == 'Case'){
									ediPrice = Decimal.valueOf(item.ASI_CRM_Price__c) / packSize;	//[WL 10.0]
								}
								else if (cust.ASI_CRM_UOM__c == 'UOM Factor'){
									ediPrice = Decimal.valueOf(item.ASI_CRM_Price__c) / item.ASI_CRM_UOM_Factor__c;
								}
							/*[WL 2.0*] END*/

						
								ASI_HK_CRM_Sales_Order_Item__c newItem = new ASI_HK_CRM_Sales_Order_Item__c(
									ASI_HK_CRM_EDI_SO__c = header.Id,
                                    ASI_CRM_EDI_Sales_Order_Item__c= item.Id,
									ASI_HK_CRM_Doc_Line_Num__c = Decimal.valueOf(item.ASI_CRM_Item_Line_Number__c),
									ASI_HK_CRM_SKU__c = skuId, 	//[WL 10.0]
									//ASI_HK_CRM_Price__c = Decimal.valueOf(item.ASI_CRM_Price__c), [WL 4.0] Price will be auto assigned based on Customer Product Price
									ASI_HK_CRM_EDI_Price__c = ediPrice, //[WL 2.0]
									ASI_HK_CRM_Quantity__c = orderQtyBottle //[WL 3.0]
								);
								
								/*[WL 10.0] BEGIN*/
								if (item.ASI_CRM_SKU_Reassigned__c)
									newItem.ASI_HK_CRM_Reserve_Stock_No__c = '????????';								
								/*[WL 10.0] END*/
								
								tempItem.add(newItem);
								
								/*[WL 6.0] BEGIN*/
								item.ASI_CRM_EDI_Per_Bottle_Price__c = ediPrice;
								item.ASI_CRM_PR_SKU__c = skuId; //[WL 10.0]

								ASI_HK_CRM_Customer_Product_Price__c productPrice = productMap.get(skuId);		//[WL 10.0]				
								system.debug('Item: ' + item.Name + ' SKU: ' + skuId + ' productPrice:' + productPrice);

								item.ASI_CRM_CRM_Per_Bottle_Price__c = productPrice != null ? productPrice.ASI_HK_CRM_Bottle_Price__c : 0;
								item.ASI_CRM_Qty_Btl__c = orderQtyBottle;
								/*[WL 6.0] END*/
							}
						}
					}
					
					update items; //[WL 6.0]
				}
				
				header.ASI_CRM_Customer_DA__c = cust.ASI_CRM_Account__c;
			}

			if (header.ASI_CRM_SO_Generation_Error__c == ''
				 && header.ASI_CRM_CRM_SO_Completed__c)//[WL 6.0]
			{
				if (tempItem.size() > 0)
				{
					for (ASI_HK_CRM_Sales_Order__c h : tmpHeader)
					{
						insertHeader.add(h);
					}

					for (ASI_HK_CRM_Sales_Order_Item__c i : tempItem)
					{
						insertItem.add(i);
					}
				}
				else
				{
					setHeaderError(header, 'No sku code can be found valid');
				}
			}

			if (header.ASI_CRM_SO_Generation_Error__c == '')
				header.ASI_CRM_Trigger_Processed__c = true;
			
		}

		System.Savepoint sp = database.setSavepoint();
		try {
			if (insertHeader.size() > 0)
			{
				insert insertHeader;

				for (ASI_CRM_EDI_SO_Header__c header : headerList)
				{
					ASI_HK_CRM_Sales_Order__c soHeader = getSO(insertHeader, header.Id);

					if (soHeader != null)
					{
						header.ASI_HK_Generated_SO__c = soHeader.Id;
						header.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_EDI_SO_Header__cASI_CRM_HK_EDI_SO_Header_RO'); 
					}
				}
			}

			//update headerList;

			if (insertItem.size() > 0)
			{
				for (ASI_HK_CRM_Sales_Order_Item__c soItem : insertItem)
				{
					ASI_HK_CRM_Sales_Order__c soHeader = getSO(insertHeader, soItem.ASI_HK_CRM_EDI_SO__c);

					if (soHeader != null)
					{
						soItem.ASI_HK_CRM_Sales_Order__c = soHeader.Id;
					}
				}
				
				insert insertItem;
			}
		} catch (DmlException dmle) {
			database.rollback(sp);

			String errMsg = '';
			Integer size = dmle.getNumDml();
			for (Integer i = 0; i < size; i++) {
				errMsg += (dmle.getDmlMessage(i) + '\n');
			}

			headerList[0].addError(errMsg);
			system.debug('generateSO Error: ' + errMsg); //[WL 4.0]
			
		} catch (Exception e) {
			database.rollback(sp);
			headerList[0].addError(e.getMessage());
			system.debug('generateSO Error: ' + e.getMessage()); //[WL 4.0]
		}
	}

	/*[WL 8.0] BEGIN*/
	/*public Decimal getAdvancePricingSKUPrice(Id customerID, Id skuID){
		Map<Id, Id> skuItemGroupIDMap = new Map<Id, Id>();
		
		List<ASI_MFM_SKU_Code__c> skuList = [SELECT ]
		List<ASI_CRM_Advance_Pricing__c> advPricingList = [SELECT ASI_CRM_Basis_Code__c, ASI_CRM_Factor_Value__c, ASI_CRM_Account__c, ASI_CRM_Effective_Date__c, ASI_CRM_Expiry_Date__c, ASI_CRM_Item_Group__c FROM ASI_CRM_Advance_Pricing__c 
															WHERE ASI_CRM_Account__c = :customerID AND ]
	}*/
	/*[WL 8.0] END*/

	// [AW 9.0]
	public void setHeaderError(ASI_CRM_EDI_SO_Header__c header, String error)
	{
		header.ASI_CRM_SO_Generation_Error__c = error;
		header.ASI_CRM_Has_Error__c = error != '';
		header.ASI_CRM_Trigger_Processed__c = error == '';
		header.ASI_CRM_CRM_SO_Completed__c = error == '';
	}

	public ASI_HK_CRM_Sales_Order__c getSO(List<ASI_HK_CRM_Sales_Order__c> headerList, Id headerID)
	{
		ASI_HK_CRM_Sales_Order__c soHeader;

		for (ASI_HK_CRM_Sales_Order__c header : headerList)
		{
			if (header.ASI_HK_CRM_EDI_SO__c == headerID)
			{
				soHeader = header;
				break;
			}
		}

		return soHeader;
	}

	public ASI_CRM_Customer_Mapping__c getCustMapping(List<ASI_CRM_Customer_Mapping__c> custList, String buyerID)
	{
		ASI_CRM_Customer_Mapping__c custMap;

		for (ASI_CRM_Customer_Mapping__c cust : custList)
		{
			if (cust.ASI_CRM_Buyer_ID__c == buyerID)
			{
				custMap = cust;
				break;
			}
		}

		return custMap;
	}
	
	public List<ASI_CRM_EDI_SO_Item__c> getItems(List<ASI_CRM_EDI_SO_Item__c> itemList, Id headerID)
	{
		List<ASI_CRM_EDI_SO_Item__c> retList = new List<ASI_CRM_EDI_SO_Item__c>();

		for (ASI_CRM_EDI_SO_Item__c item : itemList)
		{
			if (item.ASI_CRM_EDI_Sales_Order_Header__c == headerID)
			{
				retList.add(item);
			}
		}

		return retList;
	}
	
	/*[WL 11.0] BEGIN*/
	//public ASI_CRM_SKU_Mapping__c getSkuMapping(List<ASI_CRM_SKU_Mapping__c> skuList, Id custId, String skuCode)
	public ASI_CRM_SKU_Mapping__c getSkuMapping(List<ASI_CRM_SKU_Mapping__c> skuList, Id custId, String skuCode, Integer orderQuantity)
	{
		ASI_CRM_SKU_Mapping__c skuMap;

		/*[WL 9.0] Apply new SKU Mapping logic */
		for (ASI_CRM_SKU_Mapping__c sku : skuList)
		{
			//First iteration to assign non-Preferred Pricing Item Mapping
			if (sku.ASI_CRM_Account__c == custId && sku.ASI_CRM_Item_Number__c == skuCode && !sku.ASI_CRM_Item_Group_Mapping__r.ASI_CRM_Preferred__c)
			{
				//Assign if it is the first mapping matched, or currently assigned non-Preferred SKU mapping and found  a Preferred Mapping
				if ((skuMap == null && sku.ASI_CRM_SKU__r.ASI_HK_CRM_Available_Quantity__c >= orderQuantity) 
						|| (skuMap != null && !skuMap.ASI_CRM_Preferred__c && sku.ASI_CRM_Preferred__c && sku.ASI_CRM_SKU__r.ASI_HK_CRM_Available_Quantity__c >= orderQuantity //WL 11.0
										) //Assign for preferred SKU
					|| (skuMap != null && !skuMap.ASI_CRM_Preferred__c && sku.ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c < skuMap.ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c && sku.ASI_CRM_SKU__r.ASI_HK_CRM_Available_Quantity__c >= orderQuantity //WL 11.0
						)){	//Assign if min SKU Code for non-preferred item
					skuMap = sku;
					system.debug('Non-Preferred Item Group....Selected Mapping: ' + sku);
				}
			}
		}

		for (ASI_CRM_SKU_Mapping__c sku : skuList)
		{
			//Second iteration to assign Preferred Pricing Item Mapping
			if (sku.ASI_CRM_Account__c == custId && sku.ASI_CRM_Item_Number__c == skuCode && sku.ASI_CRM_Item_Group_Mapping__r.ASI_CRM_Preferred__c)
			{
				system.debug('Preferred Item Group....Item #: ' + sku.ASI_CRM_Item_Number__c + ' SKU Mapping: ' + skuMap);
				//Assign if it is the first mapping matched, or currently assigned non-Preferred SKU mapping and found  a Preferred Mapping
				if ((skuMap == null && sku.ASI_CRM_SKU__r.ASI_HK_CRM_Available_Quantity__c >= orderQuantity) 
						|| (skuMap != null && !skuMap.ASI_CRM_Preferred__c && sku.ASI_CRM_Preferred__c && sku.ASI_CRM_SKU__r.ASI_HK_CRM_Available_Quantity__c >= orderQuantity) //WL 11.0
							|| (skuMap != null && !skuMap.ASI_CRM_Preferred__c && sku.ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c < skuMap.ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c && sku.ASI_CRM_SKU__r.ASI_HK_CRM_Available_Quantity__c >= orderQuantity) //WL 11.0
					){	//Assign if min SKU Code for non-preferred item
					skuMap = sku;
					system.debug('Preferred Item Group....Selected Mapping: ' + sku);
				}
			}
		}

		return skuMap;
	}

	//WL 20181220 Uses Parent ID instead of Parent Customer Code
	/*public String getParentCode(List<Account> accList, ID parentID)
	{
		String parentCode;
		
		for (Account a : accList)
		{
			if (a.ID == parentID)
			{
				parentCode = a.ASI_HK_CRM_Customer_Code__c;
				break;
			}
		}

		return parentCode;
	}*/
}