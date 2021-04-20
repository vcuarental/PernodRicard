<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>FI CAI Total Gross Sales</label>
    <protected>false</protected>
    <values>
        <field>EUR_CRM_Country_Code__c</field>
        <value xsi:type="xsd:string">FI</value>
    </values>
    <values>
        <field>EUR_CRM_Destination_API_Name_Fields__c</field>
        <value xsi:type="xsd:string">EUR_CRM_Total_Gross_Sales__c</value>
    </values>
    <values>
        <field>EUR_CRM_Destination_Object_API_Name__c</field>
        <value xsi:type="xsd:string">EUR_CRM_Contract_Activity_Item__c</value>
    </values>
    <values>
        <field>EUR_CRM_Destination_Query__c</field>
        <value xsi:type="xsd:string">EUR_CRM_Mechanic_Type__c.EUR_CRM_Grouping_Name__c = &quot;Finland - Pouring&quot; OR EUR_CRM_Mechanic_Type__c.EUR_CRM_Grouping_Name__c = &quot;Finland - Selection&quot;</value>
    </values>
    <values>
        <field>EUR_CRM_Operation__c</field>
        <value xsi:type="xsd:string">Sum</value>
    </values>
    <values>
        <field>EUR_CRM_Source_API_Name_Field__c</field>
        <value xsi:type="xsd:string">EUR_CRM_Gross_SalesBtl__c</value>
    </values>
    <values>
        <field>EUR_CRM_Source_Object_API_Name__c</field>
        <value xsi:type="xsd:string">EUR_CRM_Contract_Product_Item__c</value>
    </values>
    <values>
        <field>EUR_CRM_Source_Query__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>EUR_CRM_Source_Reference_API_Name_Field__c</field>
        <value xsi:type="xsd:string">EUR_CRM_Contract_Activity_Item__c</value>
    </values>
</CustomMetadata>
