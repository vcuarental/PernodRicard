<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_HK_SOItem_ReqReleaseQty_Update</fullName>
        <field>ASI_CRM_Request_Release_Qty__c</field>
        <formula>IF( 
	ISBLANK(ASI_HK_CRM_Reserve_Stock_No__c ) ,	
	null ,  
	IF(
		ISBLANK(ASI_CRM_Request_Release_Qty__c),
		ASI_HK_CRM_Quantity__c ,
		ASI_CRM_Request_Release_Qty__c 
	)
)</formula>
        <name>ASI_CRM_HK_SOItem_ReqReleaseQty_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_HK_SOItem_ReqReleaseQty_Rule</fullName>
        <actions>
            <name>ASI_CRM_HK_SOItem_ReqReleaseQty_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_HK_CRM_Sales_Order_Item__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>HK CRM Sales Order Item</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_HK_CRM_Sales_Order__c.ASI_HK_CRM_Order_Status_Name__c</field>
            <operation>equals</operation>
            <value>Draft</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
