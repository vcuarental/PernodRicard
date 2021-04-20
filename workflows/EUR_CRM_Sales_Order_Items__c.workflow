<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EUR_BG_Update_Unit_Price_Field</fullName>
        <description>This is a Workflow Field Update to get the Unit Price (EUR_CRM_Sales_Order_Items__c.EUR_CRM_Unit_Price__c) populated automatically</description>
        <field>EUR_CRM_Unit_Price__c</field>
        <formula>EUR_CRM_SKU__r.EUR_CRM_List_Price__c</formula>
        <name>EUR BG Update Unit Price Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_MA_Update_SOI_Unit_Price_Field</fullName>
        <description>Updates the SOI Unit Price field according to the Sales order Price List picklist&apos;s value</description>
        <field>EUR_CRM_Unit_Price__c</field>
        <formula>CASE( TEXT(EUR_CRM_Sales_Order__r.EUR_CRM_Price_List__c), 
&apos;T1&apos;, EUR_CRM_SKU__r.EUR_CRM_T1_Price__c, 
&apos;T2&apos;, EUR_CRM_SKU__r.EUR_CRM_T2_Price__c, 
&apos;T3&apos;, EUR_CRM_SKU__r.EUR_CRM_T3_Price__c,
 NULL  )</formula>
        <name>EUR_CRM_MA_Update_SOI_Unit_Price_Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_Update_Sales_Order_Item_Unit_Pri</fullName>
        <field>EUR_CRM_Unit_Price__c</field>
        <formula>CASE( EUR_CRM_Sales_Order__r.RecordType.DeveloperName,
&apos;EUR_NG_Off_Trade_Traditional_Sales_Order&apos;, EUR_CRM_SKU__r.EUR_CRM_Retail_Price__c ,
&apos;EUR_NG_On_Trade_Sales_Order&apos;,EUR_CRM_SKU__r.EUR_CRM_Retail_Price__c,
&apos;EUR_NG_On_Trade_Reminder&apos;,EUR_CRM_SKU__r.EUR_CRM_Retail_Price__c,
 EUR_CRM_SKU__r.EUR_CRM_Modern_Trade_Price__c )</formula>
        <name>EUR_CRM_Update_Sales_Order_Item_Unit_Pri</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_NG_Update_SalesOrderItem_UnitPrice</fullName>
        <field>EUR_CRM_Unit_Price__c</field>
        <formula>CASE( EUR_CRM_Sales_Order__r.RecordType.DeveloperName,
&apos;EUR_NG_Off_Trade_Traditional_Sales_Order&apos;, EUR_CRM_SKU__r.EUR_CRM_Retail_Price__c,
&apos;EUR_NG_Off_Trade_Bulk_Breaker_Sales_Order&apos;, EUR_CRM_SKU__r.EUR_CRM_Wholesale_Price__c,
&apos;EUR_NG_On_Trade_Sales_Order&apos;,EUR_CRM_SKU__r.EUR_CRM_Retail_Price__c,
&apos;EUR_NG_On_Trade_Reminder&apos;,EUR_CRM_SKU__r.EUR_CRM_Retail_Price__c,
 EUR_CRM_SKU__r.EUR_CRM_Modern_Trade_Price__c )</formula>
        <name>EUR_NG_Update_SalesOrderItem_UnitPrice</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EUR BG Pre-populate Unit Price in Sales Order Items</fullName>
        <actions>
            <name>EUR_BG_Update_Unit_Price_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Sales_Order_Items__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR BG Direct Sales Order Item,EUR BG Marketing Product Sales Order Item</value>
        </criteriaItems>
        <description>This is a workflow rule to pre-populate the value in Unit Price Field in Sales Order Item for 
EUR BG Direct Sales Order from Wholesaler. 
EUR BG Marketing Product Sales Order</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR_CRM_MA_Update_Sales_Order_Item_Unit_Price</fullName>
        <actions>
            <name>EUR_CRM_MA_Update_SOI_Unit_Price_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Sales_Order__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR MA Indirect On Trade Sales Order,EUR MA Direct On Trade Sales Order,EUR MA Indirect Off Trade Sales Order,EUR MA Indirect Regional WS Sales Order,EUR MA Indirect On Trade Reminder,EUR MA Direct On Trade Reminder</value>
        </criteriaItems>
        <description>updates the unit price for MA Sales Order Item (EU)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR_CRM_NG_Update_Sales_Order_Item_Unit_Price</fullName>
        <actions>
            <name>EUR_NG_Update_SalesOrderItem_UnitPrice</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Sales_Order__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR NG On Trade Sales Order,EUR NG On Trade Reminder,EUR NG Off Trade Modern Sales Order,EUR NG Off Trade Traditional Sales Order</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Sales_Order__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR NG Off Trade Bulk Breaker Sales Order</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR_CRM_Update_Sales_Order_Item_Unit_Price</fullName>
        <actions>
            <name>EUR_CRM_Update_Sales_Order_Item_Unit_Pri</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Sales_Order__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR NG On Trade Sales Order,EUR NG On Trade Reminder,EUR NG Off Trade Modern Sales Order,EUR NG Off Trade Traditional Sales Order</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
