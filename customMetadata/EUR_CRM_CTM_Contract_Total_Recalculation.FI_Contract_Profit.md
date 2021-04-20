<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>FI Contract Profit</label>
    <protected>false</protected>
    <values>
        <field>EUR_CRM_Country_Code__c</field>
        <value xsi:type="xsd:string">FI</value>
    </values>
    <values>
        <field>EUR_CRM_Destination_API_Name_Fields__c</field>
        <value xsi:type="xsd:string">EUR_CRM_Contract_Profit__c</value>
    </values>
    <values>
        <field>EUR_CRM_Destination_Object_API_Name__c</field>
        <value xsi:type="xsd:string">EUR_CRM_Contract__c</value>
    </values>
    <values>
        <field>EUR_CRM_Destination_Query__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>EUR_CRM_Operation__c</field>
        <value xsi:type="xsd:string">Sum</value>
    </values>
    <values>
        <field>EUR_CRM_Source_API_Name_Field__c</field>
        <value xsi:type="xsd:string">EUR_CRM_Contract_Profit_per_Activity__c</value>
    </values>
    <values>
        <field>EUR_CRM_Source_Object_API_Name__c</field>
        <value xsi:type="xsd:string">EUR_CRM_Contract_Activity_Item__c</value>
    </values>
    <values>
        <field>EUR_CRM_Source_Query__c</field>
        <value xsi:type="xsd:string">EUR_CRM_Mechanic_Type__c.EUR_CRM_Exclude_From_Contract_Actual_Amt__c != 1</value>
    </values>
    <values>
        <field>EUR_CRM_Source_Reference_API_Name_Field__c</field>
        <value xsi:type="xsd:string">EUR_CRM_Contract__c</value>
    </values>
</CustomMetadata>
