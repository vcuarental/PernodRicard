<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EUR_CRM_Update_Quantity_field</fullName>
        <field>EUR_CRM_Quantity__c</field>
        <formula>EUR_CRM_Volume_lt__c</formula>
        <name>Update Quantity field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EUR_CRM_Update Quantity field</fullName>
        <actions>
            <name>EUR_CRM_Update_Quantity_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( RecordType.DeveloperName = &apos;EUR_DE_Contract_Product_Item&apos;, EUR_CRM_Quantity__c = 0 )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
