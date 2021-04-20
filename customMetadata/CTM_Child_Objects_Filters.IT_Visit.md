<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>IT Visit</label>
    <protected>false</protected>
    <values>
        <field>EUR_CRM_Country_Code__c</field>
        <value xsi:type="xsd:string">IT</value>
    </values>
    <values>
        <field>EUR_CRM_Filter__c</field>
        <value xsi:type="xsd:string">WHERE CreatedDate=LAST_N_DAYS:365 AND (EUR_CRM_Status__c=&apos;Finished&apos; OR EUR_CRM_Status__c=&apos;Planned&apos;)</value>
    </values>
    <values>
        <field>EUR_CRM_Object_API_Name__c</field>
        <value xsi:type="xsd:string">EUR_CRM_Visit__c</value>
    </values>
</CustomMetadata>
